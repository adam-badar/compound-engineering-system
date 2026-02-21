---
name: workflows:plan-loop
description: Iterate planning and review until PM architect and plan-review agents both approve
argument-hint: "[problem statement or existing plan path]"
---

# Planning Loop (PM + Reviewer Approval Gate)

Use this command when work is non-trivial and requires structured planning before implementation.

## Inputs

<planning_input> #$ARGUMENTS </planning_input>

If empty, ask: "What problem should this initiative solve?"

## Goal

Produce an implementation-ready plan by looping through:

1. Planning draft
2. Plan reviewer critique
3. PM/architect clarifications
4. Plan updates

Repeat until both PM/architect and plan reviewers approve.

Never write production code in this command.

## Workflow

### 1. Establish plan source

If the argument is an existing markdown plan path, use it.
Otherwise run `/workflows:plan <planning_input>` and use the generated `docs/plans/*-plan.md`.

Ensure the plan file exists before continuing.

### 2. Review loop (required)

Run rounds until exit criteria are met.

For each round:

1. Read current plan and list unresolved assumptions, open questions, and risks.
2. Run plan-review agents in parallel.
   - Preferred source: `plan_review_agents` in `compound-engineering.local.md`
   - Fallback set: `architecture-strategist`, `security-sentinel`, `performance-oracle`, `code-simplicity-reviewer`
3. If reviewers indicate missing context, run research agents in parallel:
   - `repo-research-analyst`
   - `learnings-researcher`
   - Optional: `framework-docs-researcher` for framework-specific uncertainty
4. Consolidate findings into:
   - blockers
   - non-blocking improvements
   - decisions needed from PM
5. Ask PM only the decision-critical questions.
6. Update the plan file directly:
   - resolve answered questions
   - adjust priorities/acceptance criteria
   - capture explicit tradeoffs
   - keep unresolved items with owner + follow-up date

### 3. Exit criteria (all required)

Do not exit the loop until all are true:

- PM/architect confirms priorities and acceptance criteria
- No open blocker from plan-review agents
- Scope boundaries and non-goals are explicit
- Acceptance criteria are testable
- Dependencies, rollout, and rollback are defined

### 4. Finalize planning artifacts

After exit criteria pass:

1. Mark plan frontmatter:
   - `status: approved`
   - `approved_at: YYYY-MM-DD`
2. Create execution tracker from template:
   - Template: `docs/plans/templates/execution-status-template.md`
   - Output: same basename as plan, replacing `-plan.md` with `-execution.md`
3. Update `docs/knowledge/plans-index.md`:
   - one row for the plan
   - status `approved`
   - link plan and execution tracker

### 5. Handoff

Present:

- Approved plan path
- Execution tracker path
- Open items (if any, explicitly marked non-blocking)
- Next command: `/workflows:work <approved-plan-path>`

