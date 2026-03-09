---
name: workflows:pr-review
description: Enforce teammate + dual Codex xhigh PR review gates and write evidence
argument-hint: "[pr number, pr url, or branch name]"
---

# PR Review Gate

Use this command for every code PR before merge.

Required gates:

1. Teammate review agents
2. Codex PR correctness review
3. Codex PR edge-case review
4. Test and CI verification for code PRs
5. Frontend/browser validation for qualifying PRs

## Inputs

<pr_input> #$ARGUMENTS </pr_input>

If empty, ask: "Which PR should I review?"

Optional runtime flag in arguments:

- `teams=on` to require agent teams for teammate review fan-out in this run
- `teams=off` (default) to run without a hard agent-teams requirement
- `approve_sha=<sha>` SHA authorization token for this run (required for `code_pr`)

Agent ID resolution:

- If you are invoking the shared plugin command (`/compound-engineering-core:workflows:pr-review`), normalize unqualified IDs from `compound-engineering.local.md` to `compound-engineering-core:<agent-id>`.
- If you are invoking this repo-local copied command (`/workflows:pr-review`), keep unqualified IDs local and do not auto-prefix them with the plugin namespace.

Policy defaults (override in `compound-engineering.local.md`):

- `require_tests_for_code_prs` (default: `true`)
- `require_integration_tests_for_boundary_changes` (default: `true`)
- `require_frontend_validation_for_frontend_changes` (default: `true`)
- `allow_conditional_pass_for_code_prs` (default: `false`)
- `unit_test_command` (default: `pytest -q tests/unit`)
- `integration_test_command` (default: `pytest -q tests/integration`)
- `frontend_validation_command` (default: `/workflows:frontend-validate`) -- custom validators must still write `docs/reviews/frontend/pr-<number>-frontend-validate.md` for PR-based runs
- `frontend_validation_mode` (default: `codex-devtools`)
- `frontend_local_url` (default: `http://localhost:3000`)
- `frontend_staging_url` (default: `""`)
- `frontend_validation_use_staging_fallback` (default: `false`)
- `frontend_local_revision_check_command` (default: `""`)
- `frontend_staging_revision_check_command` (default: `""`)
- `playwright_command` (default: `""`)
- `require_non_blocker_triage` (default: `true`)
- `require_pm_signoff_for_non_blocker_deferrals` (default: `true`)
- `auto_promote_high_impact_non_blockers` (default: `true`)
- `auto_promote_consensus_non_blockers` (default: `true`)
- `consensus_threshold_for_promotion` (default: `2`)
- `require_counterevidence_for_non_blocker_reject` (default: `true`)
- `require_pm_signoff_for_consensus_non_blocker_deferrals` (default: `true`)
- `codex_pr_review_agents` (default: `[codex-pr-correctness-reviewer, codex-pr-edgecase-reviewer]`)

## Workflow

### 1. Collect PR context

Resolve PR number, branch, diff, touched files, and prior review status.
Capture the current PR head SHA. All gate outcomes must be pinned to this SHA.
Classify PR type:

- `docs_only`: documentation/changelog/commentary changes only, with no executable policy/config/workflow surface changes
- `code_pr`: any runtime, data, API, infra, migration, CI, workflow, agent, executable plugin surface, manifest, or policy change that can affect execution, review, deployment, or trust boundaries

Treat these as `code_pr` even if they are Markdown/JSON/YAML:

- `.claude/**`
- `.claude-plugin/**`
- `plugins/**/commands/**`
- `plugins/**/agents/**`
- `plugins/**/.claude-plugin/**`
- `templates/.claude/**`
- `templates/docs/process/**`
- `templates/docs/reviews/**`
- workflow/CI manifests
- scripts or automation policies

Write or update review evidence file:

`docs/reviews/prs/pr-<number>-review.md`

Evidence migration rule:

- If legacy `docs/reviews/prs/pr-<number>-triple-review.md` exists and the canonical `pr-<number>-review.md` does not, rename the legacy file to the canonical path before continuing.
- If both files exist, treat `pr-<number>-review.md` as canonical, copy forward any still-relevant context from the legacy file, and mark the legacy file as superseded instead of continuing to update both.
- When loading prior review context, normalize legacy reviewer IDs before computing `supporting_reviewers` or `support_count`:
  - `codex_correctness` -> `codex:correctness`
  - `codex_edgecase` -> `codex:edgecase`
  - `codex` -> `legacy:codex-aggregate`
- Preserve legacy aggregate reviewer labels as stable migrated reviewer IDs when raw identities are unavailable:
  - `teammate` -> `legacy:teammate-aggregate`
  - `ci` -> `legacy:ci-aggregate`
  - `greptile` -> `legacy:greptile-aggregate`
- Count each migrated aggregate label as at most one supporting reviewer.
- If fresh teammate, CI, or Codex gate evidence exists for the current PR head SHA, drop the corresponding migrated aggregate label from consensus math instead of combining old aggregate support with fresh same-gate evidence.
- `legacy:greptile-aggregate` may be retained as historical supporting evidence for same-SHA migrated findings, but it must never be treated as a required gate for PASS under the new workflow.

### 1.1 SHA authorization gate (fail-closed)

Before running any review gates for `code_pr`:

1. Parse `approve_sha=<sha>` from `pr_input`.
2. If `approve_sha` is missing, stop with `status: PENDING` and reason `awaiting_sha_authorization`.
3. If `approve_sha` does not match current PR head SHA, stop with `status: PENDING` and reason `approval_sha_mismatch`.
4. In either case above, do not run teammate/Codex/test gates and do not mark overall gate `PASS`.
5. Return required next action:
   - `/workflows:pr-review "<pr-number> approve_sha=<current-head-sha> [teams=on|teams=off]"`

For `docs_only`, this authorization token is optional.

Qualifying frontend/browser validation changes include:

- frontend pages/routes/components/layouts/styles
- client-side JS/TS state and data hydration
- auth/session/token lifecycle
- router/navigation behavior
- local storage/session storage/cache rehydration
- multi-step UX flows
- backend/API changes that materially alter rendered UI or state recovery

### 1.5 Preflight gate checks

Before running gates:

1. Parse `pr_input` for `teams=on` (default: `teams=off`).
2. If `teams=on`, validate agent teams are enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) and teammate fan-out is available for `review_agents`.
3. If `teams=on` and either team check fails, stop with `status: FAIL` and reason `agent_teams_unavailable`.
4. Validate configured `codex_mcp_server` (`codex-xhigh` default) is connected.
5. Resolve `codex_pr_review_agents` from `compound-engineering.local.md`; if missing, use both fallback agents:
   - `codex-pr-correctness-reviewer`
   - `codex-pr-edgecase-reviewer`
6. Validate both Codex PR reviewer agents are available.
7. If MCP or either reviewer agent is unavailable, stop with `status: FAIL` and reason `external_gate_unavailable`.

### 2. Teammate review gate

Run `review_agents` from `compound-engineering.local.md`.

- If `teams=on`, run in parallel via agent teams.
- If `teams=off`, run sequentially.

Fallback set:

- Prefer project-local reviewer agents configured in `compound-engineering.local.md`.
- If `review_agents` is missing or empty in repo-local mode, fail closed with `status: FAIL` and reason `review_agents_unconfigured` instead of silently assuming plugin-only agent IDs.

Capture blocker/non-blocker findings in the review evidence file.
Tag each finding with a specific source reviewer ID so consensus can be computed over unique reviewers, for example:

- `teammate:kieran-python-reviewer`
- `teammate:security-sentinel`
- `codex:correctness`
- `codex:edgecase`
- `ci:unit`
- `ci:integration`

Do not collapse all teammate findings into a single `teammate` bucket.

### 3. Dual Codex xhigh gates (required, parallel)

Run both Codex PR reviewer agents in parallel on the same PR head SHA.

#### 3a. Codex correctness reviewer

Route this through the configured correctness reviewer agent and pin findings to current PR head SHA.

Primary focus:

- correctness and user-visible behavior
- security and trust boundaries
- data integrity and migrations
- concurrency, retries, and state transitions

Capture output in:

`docs/reviews/prs/pr-<number>-codex-correctness.md`

#### 3b. Codex edge-case reviewer

Route this through the configured edge-case reviewer agent and pin findings to current PR head SHA.

Primary focus:

- fallback and error paths
- refresh, rehydrate, resume, and session expiry behavior
- frontend interaction and accessibility gaps when frontend files changed
- CI/release/workflow semantics
- operational cleanup and resilience

Capture output in:

`docs/reviews/prs/pr-<number>-codex-edgecase.md`

Summarize both pass/fail results and blockers in the review evidence file.
If PR head SHA changes after either step, mark both Codex gates stale and rerun both.

### 4. Test and CI gate (required for code PRs)

For `code_pr`, this gate is mandatory.

1. Run configured `unit_test_command` and record command + summary in the evidence file.
2. If boundary surfaces changed (API routes, DB schema/migrations, adapters, workers, auth, external integrations), run configured `integration_test_command`.
3. If the PR touches qualifying frontend/browser validation changes (frontend pages/routes/components/layouts/styles, client state/data hydration, auth/session token lifecycle, router/navigation behavior, local storage/session storage/cache rehydration, multi-step UX flows, or backend/API changes that materially alter rendered UI or state recovery), require at least one integration/e2e scenario that proves refresh/rehydrate/resume behavior.
4. If the refresh/rehydrate/resume scenario is missing for a qualifying PR, set gate status `FAIL` with explicit remediation.
5. Verify tests for changed behavior exist in the same PR.
6. If CI exists, ensure test jobs for this PR head SHA are passing.
7. If tests are missing, failing, skipped without policy exception, or CI is red, set gate status `FAIL` with explicit remediation.

For `docs_only`, mark test gate `N/A` with rationale.

### 4.5 Frontend/browser validation gate (required when qualifying)

If `require_frontend_validation_for_frontend_changes: true` and the PR touches qualifying frontend/browser validation changes:

1. Require a current-SHA frontend validation artifact at:

`docs/reviews/frontend/pr-<number>-frontend-validate.md`

2. Validate that the artifact contains:
   - reviewed SHA matching current PR head SHA
   - base URL/environment used
   - target URLs/flows tested
   - target revision proof that establishes the tested target matched the reviewed SHA/current worktree
   - screenshot evidence
   - console/network findings
   - refresh/rehydrate/resume result
   - final status
3. If auth/session/token lifecycle changed, also require `Session / Auth Continuity` evidence in the artifact and treat `FAIL`, missing evidence, or unsupported `N/A` as gate failure.
4. If the artifact is missing, stale, or failed, set gate status `FAIL` with explicit remediation:
   - rerun `frontend_validation_command` on the current SHA
5. If the change does not qualify, or policy explicitly disables this gate, mark frontend validation `N/A` with rationale.

### 5. Non-blocker value gate (required by default)

Do not treat non-blockers as disposable. Consolidate non-blockers from teammate, both Codex reviewers, and test/CI analysis into a single triage table.
Normalize duplicate findings into canonical rows with:

- `support_count`
- `supporting_reviewers` (unique reviewer IDs, not reviewer classes)
- `impact_tags` (correctness/security/data/performance/accuracy/maintainability/ux/operability)

For each non-blocker, assign one disposition:

- `implement_now`
- `defer`
- `reject`

Rules:

1. If `auto_promote_high_impact_non_blockers: true`, promote non-blockers to blockers when they carry meaningful risk in correctness, security, data integrity, performance, or user-facing accuracy.
2. If `auto_promote_consensus_non_blockers: true`, any non-blocker with `support_count >= consensus_threshold_for_promotion` is escalation-candidate and should be promoted to blocker by default.
3. Escalation-candidate non-blockers may remain non-blockers only when both are present:
   - counterevidence from code/tests/benchmarks/spec references
   - explicit PM signoff in the evidence file
4. If `require_counterevidence_for_non_blocker_reject: true`, `reject` is invalid without concrete counterevidence.
5. If `require_non_blocker_triage: true`, every non-blocker must have disposition + rationale before overall gate can pass.
6. For `defer`, record owner, target milestone/PR, and explicit rationale.
7. If `require_pm_signoff_for_non_blocker_deferrals: true`, deferred high-value non-blockers require explicit PM signoff captured in evidence.
8. If `require_pm_signoff_for_consensus_non_blocker_deferrals: true`, any deferred consensus non-blocker requires PM signoff even when not high-impact.

### 6. Burden control rules

- Default: run both Codex reviewers once per commit batch.
- Re-run both Codex reviewers only if new commits materially change risk.
- For very large PRs, run focused Codex passes per subsystem (max 2 subsystems by default) but still preserve both reviewer rubrics.
- Skip redundant teammate re-runs when no code changed since last run.

### 7. Gate decision

PR gate is **PASS** only when:

- teammate gate: no open blocker
- Codex correctness gate: no open blocker
- Codex edge-case gate: no open blocker
- test/CI gate: pass for `code_pr`, or N/A for `docs_only`
- frontend/browser validation gate: pass for qualifying frontend/browser validation changes, or N/A otherwise
- refresh-resilience test requirement satisfied when the PR touches qualifying frontend/browser validation changes
- all gate results match current PR head SHA
- for `code_pr`, `approve_sha` used for this run matches current PR head SHA
- for `docs_only`, `approve_sha` may be omitted; if supplied, it must match current PR head SHA
- no gate is marked `conditional_pass` when `allow_conditional_pass_for_code_prs` is `false`
- all non-blockers are triaged with explicit disposition and rationale (if required)
- deferred high-value non-blockers have explicit PM signoff (if required)
- deferred consensus non-blockers have explicit PM signoff when policy requires it
- rejected non-blockers include counterevidence when policy requires it
- no high-impact non-blocker remains unpromoted when `auto_promote_high_impact_non_blockers` is `true`
- no consensus non-blocker remains unpromoted when `auto_promote_consensus_non_blockers` is `true`

Otherwise **FAIL** with explicit remediation checklist.

If PR head SHA changes at any point after gate execution starts:

- mark gate result `STALE`
- do not keep or report `PASS`
- require rerun with a fresh `approve_sha=<new-head-sha>`

### 8. Output

Return:

- gate status (`PASS`/`FAIL`/`PENDING`/`STALE`)
- evidence file paths
- blocker list (if any)
- next action
