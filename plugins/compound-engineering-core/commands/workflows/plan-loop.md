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
- **External gate runner agent:** `codex_gate_agent` from `compound-engineering.local.md` (default: `compound-engineering-core:codex-gate-runner`)
- **Codex MCP server:** `codex_mcp_server` from `compound-engineering.local.md` (default: `codex-xhigh`)
- **Agent ID normalization:** if an agent ID from `compound-engineering.local.md` has no namespace prefix, resolve it as `compound-engineering-core:<agent-id>` before invocation.

## Workflow

### 1. Establish plan source

If argument points to an existing plan file, use it.
Otherwise run `/compound-engineering-core:workflows:plan <planning_input>` and use the generated `docs/plans/*-plan.md`.

Ensure the plan file exists before continuing.

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

### 2. Teammate review loop (required)

Run iterative rounds until blockers are cleared:

1. Read the current plan and list unresolved assumptions, risks, and decisions.
2. Run teammate plan-review agents.
   - If `teams=on`, run in parallel via agent teams.
   - If `teams=off`, run sequentially.
3. If reviewers request more evidence, run research agents in parallel:
   - `compound-engineering-core:repo-research-analyst`
   - `compound-engineering-core:learnings-researcher`
   - Optional: `compound-engineering-core:framework-docs-researcher`
4. Consolidate findings into:
   - blockers
   - non-blocking improvements
   - decision questions for PM
5. Ask PM only decision-critical questions.
6. Update plan in place.

### 3. Codex Extra High gate (required)

When the plan reaches a candidate state (no obvious internal blockers), run external Codex review in **Extra High** mode via the dedicated gate runner agent.

Invoke `codex_gate_agent` with:

- gate type: `plan`
- plan path
- plan revision metadata:
  - latest commit SHA
  - plan file hash

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
