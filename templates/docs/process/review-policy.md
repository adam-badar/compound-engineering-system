# Review Policy

## Plan Approval Gate

A plan can be marked `approved` only when all pass:

1. PM/architect approval
2. Teammate plan-review agents approval
3. Codex Extra High external approval
4. Gate output pinned to current revision (commit SHA + plan hash)

## PR Review Gate

A code PR can be merged only when all pass:

1. Teammate review agents
2. Codex correctness review
3. Codex edge-case review
4. Test/CI gate for code PRs
5. All gate outputs match current PR head SHA
6. SHA authorization exists for this revision before PR review is invoked (`approve_sha=<head-sha>` or auto-supplied by `/workflows:work`)
7. Non-blockers are triaged with explicit disposition and rationale
8. For qualifying frontend/browser validation changes, refresh/rehydrate/resume behavior is covered by integration/e2e validation
9. For qualifying frontend/browser validation changes, current-SHA browser validation evidence exists and passes (or is explicitly `N/A`)
10. Frontend/browser validation evidence proves the tested target matched the reviewed SHA/current worktree

Authorization rules:

- PR review is fail-closed without SHA authorization.
- Authorization must be SHA-specific; if head SHA changes, prior authorization is invalid.
- `/workflows:work` should auto-run PR review with current head SHA authorization after each pushed SHA and rerun on SHA change.
- `/workflows:work` should auto-run `/workflows:frontend-validate` before PR review when the batch touches qualifying frontend/browser validation changes.
- Frontend validation must fail closed when the target environment cannot prove it matched the reviewed SHA/current worktree.
- On any later SHA change for qualifying frontend/browser validation changes, `/workflows:work` should rerun frontend validation on the new SHA before rerunning PR review.
- Background/sub-agent output with stale SHA is invalid and must not produce `PASS`.

External reviewer rules:

- For `code_pr`, both Codex PR passes are required and fail-closed for the current SHA.
- Codex correctness and edge-case passes must both run against the same head SHA; default execution is direct from the current Claude agent rather than through dedicated Codex-only sub-agents.
- If either pass is missing, stale, or unavailable, the PR is not merge-ready.
- The shared `codex-xhigh` MCP server is required unless project policy explicitly defines an alternate Codex MCP endpoint.

## Post-Merge CI/CD and Compound Gate

After a PR is merged, progression is blocked until merge-triggered CI/CD is confirmed for the merged SHA on the target branch and compound capture is executed.

Rules:

- Wait for required merge-triggered workflows (tests/build/deploy) to complete.
- If any required post-merge workflow fails, treat as blocker and stop progression.
- If no merge-triggered workflow is configured, record `N/A` with rationale and continue.
- After CI/CD is green, run `/workflows:compound` (or plugin-prefixed equivalent) for the merged change context.
- Accept `status: skipped` only with explicit rationale captured in tracker/evidence.
- Treat compound workflow/tool failures as blockers until rerun succeeds or PM approves an exception.
- Do not begin the next PR slice or mark epic closeout while required post-merge workflows or compound capture are still pending.

Conditional pass rules:

- `conditional_pass` is not merge-ready for code PRs by default.
- Only explicit policy exception (`allow_conditional_pass_for_code_prs: true`) can permit it.
- Missing tests cannot be accepted as non-blocking for code PRs.

Non-blocker value rules:

- Non-blockers must be dispositioned as `implement_now`, `defer`, or `reject`.
- Duplicate non-blockers across reviewers should be normalized and tracked with `support_count` and `supporting_reviewers`.
- Consensus non-blockers (`support_count >= consensus_threshold_for_promotion`, default `2`) should be promoted by default when `auto_promote_consensus_non_blockers: true`.
- High-impact non-blockers (correctness/security/data/perf/user-accuracy) should be promoted to blockers unless explicitly deferred with rationale.
- Rejecting a non-blocker should require concrete counterevidence (tests/benchmarks/spec references) when `require_counterevidence_for_non_blocker_reject: true`.
- Deferred high-value non-blockers require PM signoff when `require_pm_signoff_for_non_blocker_deferrals: true`.
- Deferred consensus non-blockers require PM signoff when `require_pm_signoff_for_consensus_non_blocker_deferrals: true`.
- Gate evidence must include owner + target follow-up for each deferred item.
- Default tracking location for deferred items is existing review evidence + execution tracker; separate todo-file systems are optional.

## Overhead Controls

To prevent review overload:

- Run both Codex PR passes once per stable revision.
- Re-run only after material change.
- Prefer focused re-review on changed areas, not full re-review of unchanged sections.
- Keep evidence docs concise and link to artifacts instead of copying full transcripts.

## Availability Policy

- External Codex gates must use `codex-xhigh` MCP server unless project policy names an alternate Codex MCP endpoint.
- If the Codex MCP endpoint is unavailable, the relevant gate fails closed and merge/approval cannot proceed.
