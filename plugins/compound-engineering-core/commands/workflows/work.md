---
name: workflows:work
description: Execute an approved plan with real-time tracking, epic delta loops, and mandatory PR triple review gates
argument-hint: "[approved plan path]"
---

# Execute Approved Plan

Use this command after a plan has passed planning gates.

Never re-plan from scratch during execution. Use delta loops for material scope changes.

## Inputs

<approved_plan_path> #$ARGUMENTS </approved_plan_path>

If empty, ask: "Which approved plan should I execute?"

## Workflow

### 1. Validate plan context

1. Confirm the plan file exists under `docs/plans/*-plan.md`.
2. Confirm plan status is `approved` or `in_progress`.
3. Resolve tracker path by replacing `-plan.md` with `-execution.md`.

If tracker is missing, create it with:

`scripts/init-plan-tracker.sh <approved-plan-path>`

### 2. Start execution loop

Work from the approved plan's acceptance criteria and scope boundaries.

For each implementation batch:

1. Select the next planned PR-sized slice from the plan's Epic PR Ladder.
2. Implement only that slice (one concern per PR).
3. Add or update tests in the same batch for changed behavior.
4. Run relevant tests and checks before opening/updating PR.
5. Update execution tracker in real time:
   - task status
   - test evidence
   - decisions and risks
   - current branch/PR references

Do not defer tests to a later "testing-only" PR for code already merged in this epic.

### 3. Handle mid-epic scope changes

When new information materially changes acceptance criteria, architecture, dependencies, risk model, or rollout:

1. Run `/compound-engineering-core:workflows:epic-delta-loop "<approved-plan-path> | <delta request>"`.
2. Wait for PM + teammate + Codex approvals on the delta.
3. Merge approved delta updates into the parent plan/tracker.
4. Resume execution.

### 4. PR gate enforcement

Before any merge:

1. Open/update PR for current work batch.
2. Run `/compound-engineering-core:workflows:pr-triple-review "<pr-number-or-url>"`.
3. Merge only when gate status is `PASS` for current PR head SHA and test/CI gate is green.

### 5. Closeout

After PM acceptance and deployment:

1. Update plan status to `implemented`.
2. Update tracker summary/outcomes.
3. Update `docs/knowledge/plans-index.md`:
   - status `implemented`
   - links to plan/tracker/review evidence
   - implemented date

## Output

Return:

- execution status
- updated tracker path
- open blockers or risks
- PR/gate status
- next step
