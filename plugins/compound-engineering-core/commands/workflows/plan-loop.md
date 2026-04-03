---
name: workflows:plan-loop
description: Iterate planning and review until PM architect, teammate reviewers, and Codex Extra High all approve
argument-hint: "[problem statement or existing plan path]"
---

# Planning Loop (PM + Dual Review Gate)

Use this command for non-trivial initiatives. It enforces two independent plan-review sources:

1. Teammate plan-review agents
2. External Codex Extra High review

Never write production code in this command.

## Inputs

<planning_input> #$ARGUMENTS </planning_input>

If empty, ask: "What problem should this initiative solve?"

Optional runtime flag in arguments:

- `teams=on` to require agent teams for teammate review fan-out in this run
- `teams=off` (default) to run without a hard agent-teams requirement

## Required Review Sources

- **Teammate reviewers:** `plan_review_agents` from `compound-engineering.local.md`
  - Fallback: `compound-engineering-core:architecture-strategist`, `compound-engineering-core:security-sentinel`, `compound-engineering-core:performance-oracle`, `compound-engineering-core:code-simplicity-reviewer`
- **Execution mode:** agent teams are optional per run (`teams=on`)
- **External reviewer:** `external_plan_review_gate` from `compound-engineering.local.md` (must resolve to `codex-extra-high`)
- **Direct invocation rule:** the current Claude agent runs the Codex Extra High pass directly through `codex_mcp_server`; legacy `codex_gate_agent` config in older repos should be ignored
- **Flow analysis agent:** `compound-engineering-core:spec-flow-analyzer` for permutation and edge-case gap detection
- **Codex MCP server:** `codex_mcp_server` from `compound-engineering.local.md` (default: `codex-xhigh`)
- **Agent ID normalization:** if an agent ID from `compound-engineering.local.md` has no namespace prefix, resolve it as `compound-engineering-core:<agent-id>` before invocation.
- **Sizing defaults (override in `compound-engineering.local.md`):**
  - `max_prs_per_epic` (default: `5`)
  - `max_net_loc_per_pr` (default: `600`)
  - `max_files_per_pr` (default: `20`)
  - `max_cycle_days_per_pr` (default: `2`)
  - `require_test_strategy_per_pr` (default: `true`)
  - `require_non_blocker_triage` (default: `true`)
  - `require_pm_signoff_for_non_blocker_deferrals` (default: `true`)
  - `auto_promote_consensus_non_blockers` (default: `true`)
  - `consensus_threshold_for_promotion` (default: `2`)
  - `require_counterevidence_for_non_blocker_reject` (default: `true`)
  - `require_pm_signoff_for_consensus_non_blocker_deferrals` (default: `true`)

## Workflow

### 1. Establish plan source

If argument points to an existing plan file, use it.
Otherwise run `/compound-engineering-core:workflows:plan <planning_input>` and use the generated `docs/plans/*-plan.md`.

Ensure the plan file exists before continuing.

Do not launch research agents or teammate reviewers until steps 1.4, 1.5, and 1.6 are satisfied.

### 1.4 Agent teams mode (optional)

Before any review loop:

1. Parse `planning_input` for `teams=on` (default: `teams=off`).
2. If `teams=on`, validate agent teams are enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) and teammate fan-out is available for `plan_review_agents`.
3. If `teams=on` and unavailable, fail closed:
   - set plan gate status to `failed`
   - record reason `agent_teams_unavailable`
   - stop and return remediation steps
4. If `teams=off`, continue without agent-teams preflight failure.

### 1.5 External gate preflight checks

Before running any external gate:

1. Validate configured MCP server exists and is connected (`codex-xhigh` by default).
2. If unavailable, fail closed:
   - set plan gate status to `failed`
   - record reason `codex_mcp_unavailable`
   - stop and return remediation steps

### 1.6 Plan sizing contract (required)

Before any approval, ensure the plan includes an **Epic PR Ladder** table with one row per planned PR and these columns:

- PR id/title
- Objective and acceptance criteria
- Test plan for that PR (unit + integration scope)
- Estimated net LOC
- Estimated files changed
- Rollback note

Sizing and decomposition rules:

1. Each PR must be independently reviewable and shippable.
2. Each PR must stay within configured size budgets.
3. If projected PR count exceeds `max_prs_per_epic`, split into child epics before approval.
4. The first PR in each epic should establish/verify test harness and CI path (if not already present).
5. "Test later" is not allowed for code paths included in this epic.

### 1.7 Flow permutations gate (required)

Before any approval, ensure the plan has a **Flow Permutations & Edge Cases** section.

Minimum coverage:

1. initial load
2. refresh/rehydrate
3. partial completion + resume
4. error + retry path
5. session expiry/re-auth path (if auth exists)
6. offline/timeout degradation (if networked)

For stateful UX changes (frontend state, auth/session, client cache/local storage, multi-step flows), this section is mandatory and must include explicit verification strategy (integration/e2e).
Any `required_tests` emitted by `spec-flow-analyzer` must be copied into either this section or the Epic PR Ladder rows before approval.

### 2. Teammate review loop (required)

Run iterative rounds until blockers are cleared:

1. Read the current plan and list unresolved assumptions, risks, and decisions.
2. **Required**: Run `compound-engineering-core:learnings-researcher` on the first iteration (and re-run after material plan revisions) to surface prior solutions, critical patterns, and historical pitfalls. Any `must-apply` findings that are not addressed in the plan are blockers. If no `docs/solutions/` exists or the researcher returns `no institutional matches`, the check is satisfied — this is not a blocker for greenfield repos.
3. Run `compound-engineering-core:spec-flow-analyzer` on the current plan to identify missing user-flow permutations and edge cases.
4. If analyzer returns `status: not_applicable`, record the rationale and continue without flow blockers.
5. If analyzer returns `status: applicable`, convert any critical flow gaps into blockers and patch the plan before teammate review.
6. Copy analyzer `required_tests` into the plan's verification strategy. Missing mapping from analyzer output to plan content is a blocker.
7. Run teammate plan-review agents.
   - If `teams=on`, run in parallel via agent teams.
   - If `teams=off`, run sequentially.
8. If reviewers request more evidence, run research agents in parallel:
   - `compound-engineering-core:repo-research-analyst`
   - `compound-engineering-core:learnings-researcher` (re-run with narrowed scope if needed)
   - Optional: `compound-engineering-core:framework-docs-researcher`
9. Consolidate findings into:
   - blockers
   - non-blocking improvements
   - decision questions for PM
10. Ask PM only decision-critical questions.
11. Update plan in place.

### 2.5 Non-blocker value triage (required by default)

Do not treat non-blockers as automatically optional. For each non-blocking finding from teammate and Codex plan review:
Normalize duplicate findings into canonical rows with:

- `support_count`
- `supporting_reviewers`
- `impact_tags`

1. Assign one disposition:
   - `implement_now` (adds meaningful quality/accuracy/risk reduction with acceptable scope impact)
   - `defer` (not required for this cycle)
   - `reject` (not aligned with goals or constraints)
2. Record rationale for each disposition in plan notes or review evidence.
3. If `auto_promote_consensus_non_blockers: true`, any item with `support_count >= consensus_threshold_for_promotion` should be promoted to blocker by default.
4. Consensus items may remain non-blockers only with documented counterevidence and PM signoff.
5. For `defer`, capture owner and intended review point.
6. If `require_pm_signoff_for_non_blocker_deferrals: true`, obtain explicit PM signoff for deferred high-value items.
7. If `require_pm_signoff_for_consensus_non_blocker_deferrals: true`, obtain PM signoff for deferred consensus non-blockers.
8. If `require_counterevidence_for_non_blocker_reject: true`, `reject` is invalid without concrete counterevidence.
9. If a non-blocker materially reduces architecture/security/data/performance risk, promote it to blocker unless PM explicitly defers with rationale.

### 3. Codex Extra High gate (required)

When the plan reaches a candidate state (no obvious internal blockers), run external Codex review in **Extra High** mode directly from the current Claude agent through `codex_mcp_server`.

Invoke Codex with a focused plan-review prompt that includes:

- gate type: `plan`
- plan path
- plan revision metadata:
  - latest commit SHA
  - plan file hash
- direct invocation requirement: do not spawn a separate Codex-only Claude sub-agent for this pass

Write review evidence to:

`docs/reviews/plans/<plan-slug>-codex-extra-high.md`

Evidence must include:

- review date
- exact prompt/context sent
- findings by severity
- unresolved blockers
- pass/fail recommendation
- reviewed revision (commit SHA + plan hash)

### 4. Burden control rules

To avoid overloading system cost/context:

- Run Codex Extra High once per stable plan version.
- Re-run Codex only on **material changes**:
  - architecture or dependency strategy changes
  - acceptance criteria changes
  - risk model/security assumptions change
  - epic boundaries/scope materially change
- Default cap: 2 Codex passes per plan cycle unless PM requests more.

### 5. Exit criteria (all required)

Do not approve the plan until all are true:

- PM confirms priorities and acceptance criteria
- Teammate plan reviewers report no open blocker
- Codex Extra High gate reports no open blocker
- Scope boundaries and non-goals are explicit
- Acceptance criteria are testable
- Dependencies, rollout, and rollback are defined
- Plan includes Epic PR Ladder that satisfies sizing budgets
- Plan includes Flow Permutations & Edge Cases coverage for relevant user journeys
- Any `required_tests` emitted by `spec-flow-analyzer` are mapped into the plan's explicit verification strategy or marked `not_applicable`
- Every planned PR includes explicit unit/integration testing intent
- Stateful UX paths (when present) include explicit refresh/rehydrate/resume verification strategy
- No deferred "test-only later epic" for already-planned code PRs
- Non-blockers are triaged (`implement_now|defer|reject`) with rationale
- High-value deferred non-blockers have explicit PM signoff when policy requires it
- Deferred consensus non-blockers have explicit PM signoff when policy requires it
- Rejected non-blockers include counterevidence when policy requires it
- No consensus non-blocker remains unpromoted when `auto_promote_consensus_non_blockers` is `true`

### 6. Finalize planning artifacts

After all gates pass:

1. Update plan frontmatter:
   - `status: approved`
   - `approved_at: YYYY-MM-DD`
   - `teammate_plan_review_gate: passed`
   - `codex_extra_high_plan_gate: passed`
   - `plan_gate_revision: <sha-or-hash>`
2. Create execution tracker:
   - template: `docs/plans/templates/execution-status-template.md`
   - output: replace `-plan.md` with `-execution.md`
3. Update `docs/knowledge/plans-index.md` with latest gate statuses.

### 7. Handoff

Present:

- approved plan path
- Codex review evidence path
- execution tracker path
- next command: `/compound-engineering-core:workflows:work <approved-plan-path>`
