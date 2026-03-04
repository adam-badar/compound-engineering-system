---
name: workflows:pr-triple-review
description: Enforce teammate + Codex Extra High + Greptile PR review gates and write evidence
argument-hint: "[pr number, pr url, or branch name]"
---

# PR Triple Review Gate

Use this command for every code PR before merge.

Required gates:

1. Teammate review agents
2. External Codex Extra High review
3. Greptile review
4. Test and CI verification for code PRs

## Inputs

<pr_input> #$ARGUMENTS </pr_input>

If empty, ask: "Which PR should I run triple review for?"

Optional runtime flag in arguments:

- `teams=on` to require agent teams for teammate review fan-out in this run
- `teams=off` (default) to run without a hard agent-teams requirement
- `approve_sha=<sha>` SHA authorization token for this run (required for `code_pr`)

Policy defaults (override in `compound-engineering.local.md`):

- `require_tests_for_code_prs` (default: `true`)
- `require_integration_tests_for_boundary_changes` (default: `true`)
- `allow_conditional_pass_for_code_prs` (default: `false`)
- `unit_test_command` (default: `pytest -q tests/unit`)
- `integration_test_command` (default: `pytest -q tests/integration`)
- `require_non_blocker_triage` (default: `true`)
- `require_pm_signoff_for_non_blocker_deferrals` (default: `true`)
- `auto_promote_high_impact_non_blockers` (default: `true`)
- `auto_promote_consensus_non_blockers` (default: `true`)
- `consensus_threshold_for_promotion` (default: `2`)
- `require_counterevidence_for_non_blocker_reject` (default: `true`)
- `require_pm_signoff_for_consensus_non_blocker_deferrals` (default: `true`)

## Workflow

### 1. Collect PR context

Resolve PR number, branch, diff, touched files, and prior review status.
Capture the current PR head SHA. All gate outcomes must be pinned to this SHA.
Classify PR type:

- `docs_only`: docs/changelog/commentary changes only
- `code_pr`: any runtime, data, API, infra, or migration change

Write or update review evidence file:

`docs/reviews/prs/pr-<number>-triple-review.md`

### 1.1 SHA authorization gate (fail-closed)

Before running any review gates for `code_pr`:

1. Parse `approve_sha=<sha>` from `pr_input`.
2. If `approve_sha` is missing, stop with `status: PENDING` and reason `awaiting_sha_authorization`.
3. If `approve_sha` does not match current PR head SHA, stop with `status: PENDING` and reason `approval_sha_mismatch`.
4. In either case above, do not run teammate/Codex/Greptile gates and do not mark overall gate `PASS`.
5. Return required next action:
   - `/workflows:pr-triple-review "<pr-number> approve_sha=<current-head-sha> [teams=on|teams=off]"`

For `docs_only`, this authorization token is optional.

### 1.5 Preflight gate checks

Before running gates:

1. Parse `pr_input` for `teams=on` (default: `teams=off`).
2. If `teams=on`, validate agent teams are enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) and teammate fan-out is available for `review_agents`.
3. If `teams=on` and agent teams are unavailable, stop with `status: FAIL` and reason `agent_teams_unavailable`.
4. Validate configured `codex_mcp_server` (`codex-xhigh` default) is connected.
5. Validate `codex_gate_agent` (`codex-gate-runner` default) is available.
6. If either external gate check fails, stop with `status: FAIL` and reason `external_gate_unavailable`.

### 2. Teammate review gate

Run `review_agents` from `compound-engineering.local.md`.

- If `teams=on`, run in parallel via agent teams.
- If `teams=off`, run sequentially.

Fallback set:

- `architecture-strategist`
- `security-sentinel`
- `performance-oracle`
- `code-simplicity-reviewer`

Capture blocker/non-blocker findings in the review evidence file.
Tag each finding with source reviewer (`teammate|codex|greptile|ci`) so consensus can be computed.

### 3. Codex Extra High gate

Run external review from `external_pr_review_gate` in `compound-engineering.local.md`.

This must resolve to Codex in **Extra High** mode.
Route this through `codex_gate_agent` and pin findings to current PR head SHA.

Review against:

- PR summary
- full diff or high-risk slices for large diffs
- known constraints from `CLAUDE.md` and ADRs

Capture output in:

`docs/reviews/prs/pr-<number>-codex-extra-high.md`

Summarize pass/fail and blockers in the triple-review evidence file.
If PR head SHA changes after this step, mark Codex gate stale and rerun.

### 4. Test and CI gate (required for code PRs)

For `code_pr`, this gate is mandatory.

1. Run configured `unit_test_command` and record command + summary in the evidence file.
2. If boundary surfaces changed (API routes, DB schema/migrations, adapters, workers, auth, external integrations), run configured `integration_test_command`.
3. Verify tests for changed behavior exist in the same PR.
4. If CI exists, ensure test jobs for this PR head SHA are passing.
5. If tests are missing, failing, skipped without policy exception, or CI is red, set gate status `FAIL` with explicit remediation.

For `docs_only`, mark test gate `N/A` with rationale.

### 5. Greptile gate

Confirm Greptile review is present for the current PR revision.

If `greptile_required_for_code_prs: true` in `compound-engineering.local.md`, this gate is mandatory.

If missing, mark gate as pending and stop with explicit next action.

### 5.5 Non-blocker value gate (required by default)

Do not treat non-blockers as disposable. Consolidate non-blockers from teammate, Codex, Greptile, and test/CI analysis into a single triage table.
Normalize duplicate findings into canonical rows with:

- `support_count`
- `supporting_reviewers`
- `impact_tags` (correctness/security/data/performance/accuracy/maintainability)

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

- Default: one Codex pass per commit batch.
- Re-run Codex only if new commits materially change risk.
- For very large PRs, run focused Codex passes per subsystem (max 2 by default).
- Skip redundant teammate re-runs when no code changed since last run.

### 7. Gate decision

PR gate is **PASS** only when:

- teammate gate: no open blocker
- Codex Extra High gate: no open blocker
- test/CI gate: pass for `code_pr`, or N/A for `docs_only`
- Greptile gate: no open blocker
- all gate results match current PR head SHA
- `approve_sha` used for this run matches current PR head SHA
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

- gate status (PASS/FAIL/PENDING)
- evidence file paths
- blocker list (if any)
- next action
