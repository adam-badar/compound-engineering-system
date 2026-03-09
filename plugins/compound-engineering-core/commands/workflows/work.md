---
name: workflows:work
description: Execute an approved plan with real-time tracking, epic delta loops, and mandatory PR review gates
argument-hint: "[approved plan path]"
---

# Execute Approved Plan

Use this command after a plan has passed planning gates.

Never re-plan from scratch during execution. Use delta loops for material scope changes.

## Inputs

<approved_plan_path> #$ARGUMENTS </approved_plan_path>

If empty, ask: "Which approved plan should I execute?"

Optional runtime flag in arguments:

- `teams=on|off` (default `off`) to forward teammate fan-out requirement into `/compound-engineering-core:workflows:pr-review`
- `frontend_env=auto|local|staging` (default `auto`) to forward browser-validation environment choice into the configured `frontend_validation_command`

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
   - If `require_frontend_validation_for_frontend_changes: true` and the batch touches qualifying frontend/browser validation changes (including backend/API changes that materially alter rendered UI or state recovery), ensure the configured frontend validation target is reachable (`frontend_local_url` or `frontend_staging_url`).
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

1. Run `/compound-engineering-core:workflows:epic-delta-loop "<approved-plan-path> | <delta request>"`.
2. Wait for PM + teammate + Codex approvals on the delta.
3. Merge approved delta updates into the parent plan/tracker.
4. Resume execution.

### 4. PR gate enforcement

Before any merge:

1. Open/update PR for current work batch.
2. Capture current PR head SHA.
3. If `require_frontend_validation_for_frontend_changes: true` and the batch touches qualifying frontend/browser validation changes, run the configured `frontend_validation_command` automatically using the current head SHA.
   - Default command: `/compound-engineering-core:workflows:frontend-validate "<pr-number-or-url> sha=<head-sha> env=<frontend_env|auto> playwright=auto"`.
   - Record the frontend artifact path in the execution tracker.
   - If frontend validation returns `FAIL` or `STALE`, do not proceed to PR review or merge until rerun passes on the current SHA.
   - If policy explicitly disables frontend validation, record `N/A` with rationale in the execution tracker and continue instead of invoking the gate.
4. Run `/compound-engineering-core:workflows:pr-review "<pr-number-or-url> approve_sha=<head-sha> [teams=on|teams=off]"` automatically from this workflow using the current head SHA.
5. If PR review fails, do not proceed to merge. Fix blockers or rerun on the same SHA only when the failure was environmental and the SHA has not changed.
6. If PR head SHA changes at any time (new push/force-push), invalidate prior gate result and rerun required gates on the new head SHA before making merge decisions.
   - For qualifying frontend/browser validation changes, rerun the configured `frontend_validation_command` on the new head SHA first.
   - Default rerun command: `/compound-engineering-core:workflows:frontend-validate "<pr-number-or-url> sha=<new-head-sha> env=<frontend_env|auto> playwright=auto"`.
   - Then rerun `/compound-engineering-core:workflows:pr-review "<pr-number-or-url> approve_sha=<new-head-sha> [teams=on|teams=off]"`.
7. Treat any late/stale background-agent review output as non-authoritative when SHA does not match current head.
8. Triage non-blockers from PR review output:
   - implement_now
   - defer (owner + follow-up PR/task + rationale)
   - reject (rationale)
9. For consensus non-blockers (`support_count >= consensus_threshold_for_promotion`), require counterevidence and PM signoff for `defer`/`reject`.
10. If policy requires PM signoff for deferred high-value non-blockers, capture signoff before merge.
11. Merge only when gate status is `PASS` for current PR head SHA, both Codex reviewer gates are green, test/CI gate is green, frontend/browser validation gate is green or `N/A`, and non-blocker triage is complete (including consensus rules).
12. After merge, run a post-merge CI/CD confirmation gate before proceeding:
   - Identify target branch and merged SHA.
   - Wait for merge-triggered CI/CD workflows on that branch/SHA to finish (tests + deployment where configured).
   - If no merge-triggered CI/CD workflow exists, record `N/A` with rationale and continue.
   - Do not start the next implementation batch or close the epic while these runs are pending.
   - If any merge-triggered CI/CD workflow fails, stop and treat as an open blocker until remediated.
   - Continue only when required post-merge workflows are green.
13. After post-merge CI/CD is green, auto-run `/compound-engineering-core:workflows:compound "<approved-plan-path> | pr=<pr-number-or-url> | merged_sha=<merged-sha>"` before starting the next slice:
   - For `status: created|updated`, record artifact path(s) in the execution tracker.
   - For `status: skipped`, record the returned rationale in the execution tracker.
   - If compound capture errors (workflow/tool failure), default to stop + remediate + rerun before continuing execution.
   - Exception path: proceed only with explicit PM signoff captured in tracker/review evidence (`compound_capture_exception` + rationale + signoff reference).

### 5. Closeout

After PM acceptance, successful post-merge CI/CD confirmation, and post-merge compound capture:

1. Update plan status to `implemented`.
2. Update tracker summary/outcomes (including compound capture status and evidence path/rationale).
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
- frontend validation status/evidence
- post-merge compound status/evidence
- next step
