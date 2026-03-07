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

Optional runtime flag in arguments:

- `teams=on|off` (default `off`) to forward teammate fan-out requirement into `/workflows:pr-triple-review`

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
4. Run local validation before opening/updating PR:
   - Always run unit tests (`unit_test_command` from `compound-engineering.local.md`, default `pytest -q tests/unit`).
   - If boundary surfaces changed (API routes/endpoints, DB schema/migrations, adapters/integrations, workers, auth), run integration tests (`integration_test_command`, default `pytest -q tests/integration`).
   - Run project-required lint/type/static checks.
   - If required integration tests are missing, skipped, or failing without an approved exception, stop and remediate before proceeding.
5. Update execution tracker in real time:
   - task status
   - test evidence
   - decisions and risks
   - current branch/PR references
6. Review non-blocker improvements from current and prior review rounds; implement high-value low-risk items that improve goal alignment.
7. Treat repeated non-blockers from multiple reviewers as escalation-candidates; default to `implement_now` or blocker unless counterevidence + PM signoff are captured.

Do not defer tests to a later "testing-only" PR for code already merged in this epic.

### 3. Handle mid-epic scope changes

When new information materially changes acceptance criteria, architecture, dependencies, risk model, or rollout:

1. Run `/workflows:epic-delta-loop "<approved-plan-path> | <delta request>"`.
2. Wait for PM + teammate + Codex approvals on the delta.
3. Merge approved delta updates into the parent plan/tracker.
4. Resume execution.

### 4. PR gate enforcement

Before any merge:

1. Open/update PR for current work batch.
2. Capture current PR head SHA.
3. Run `/workflows:pr-triple-review "<pr-number-or-url> approve_sha=<head-sha> [teams=on|teams=off]"` automatically from this workflow using the current head SHA.
4. Treat any late/stale background-agent review output as non-authoritative when SHA does not match current head.
5. If PR head SHA changes during or after gate runs, invalidate prior gate result and rerun triple review with the new head SHA.
6. Triage non-blockers from triple review output:
   - implement_now
   - defer (owner + follow-up PR/task + rationale)
   - reject (rationale)
7. For consensus non-blockers (`support_count >= consensus_threshold_for_promotion`), require counterevidence and PM signoff for `defer`/`reject`.
8. If policy requires PM signoff for deferred high-value non-blockers, capture signoff before merge.
9. Merge only when gate status is `PASS` for current PR head SHA, test/CI gate is green, and non-blocker triage is complete (including consensus rules).
10. After merge, run a post-merge CI/CD confirmation gate before proceeding:
   - Identify target branch and merged SHA.
   - Wait for merge-triggered CI/CD workflows on that branch/SHA to finish (tests + deployment where configured).
   - If no merge-triggered CI/CD workflow exists, record `N/A` with rationale and continue.
   - Do not start the next implementation batch or close the epic while these runs are pending.
   - If any merge-triggered CI/CD workflow fails, stop and treat as an open blocker until remediated.
   - Continue only when required post-merge workflows are green.

### 5. Closeout

After PM acceptance and successful post-merge CI/CD confirmation:

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
