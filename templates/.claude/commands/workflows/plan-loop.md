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

## Required Review Sources

- **Teammate reviewers:** `plan_review_agents` from `compound-engineering.local.md`
  - Fallback: `architecture-strategist`, `security-sentinel`, `performance-oracle`, `code-simplicity-reviewer`
- **External reviewer:** `external_plan_review_gate` from `compound-engineering.local.md` (must resolve to `codex-extra-high`)

## Workflow

### 1. Establish plan source

If argument points to an existing plan file, use it.
Otherwise run `/workflows:plan <planning_input>` and use the generated `docs/plans/*-plan.md`.

Ensure the plan file exists before continuing.

### 2. Teammate review loop (required)

Run iterative rounds until blockers are cleared:

1. Read the current plan and list unresolved assumptions, risks, and decisions.
2. Run teammate plan-review agents in parallel.
3. If reviewers request more evidence, run research agents in parallel:
   - `repo-research-analyst`
   - `learnings-researcher`
   - Optional: `framework-docs-researcher`
4. Consolidate findings into:
   - blockers
   - non-blocking improvements
   - decision questions for PM
5. Ask PM only decision-critical questions.
6. Update plan in place.

### 3. Codex Extra High gate (required)

When the plan reaches a candidate state (no obvious internal blockers), run external Codex review in **Extra High** mode.

Write review evidence to:

`docs/reviews/plans/<plan-slug>-codex-extra-high.md`

Evidence must include:

- review date
- exact prompt/context sent
- findings by severity
- unresolved blockers
- pass/fail recommendation

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
2. Create execution tracker:
   - template: `docs/plans/templates/execution-status-template.md`
   - output: replace `-plan.md` with `-execution.md`
3. Update `docs/knowledge/plans-index.md` with latest gate statuses.

### 7. Handoff

Present:

- approved plan path
- Codex review evidence path
- execution tracker path
- next command: `/workflows:work <approved-plan-path>`
