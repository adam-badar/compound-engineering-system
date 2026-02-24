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

## Inputs

<pr_input> #$ARGUMENTS </pr_input>

If empty, ask: "Which PR should I run triple review for?"

Optional runtime flag in arguments:

- `teams=on` to require agent teams for teammate review fan-out in this run
- `teams=off` (default) to run without a hard agent-teams requirement

## Workflow

### 1. Collect PR context

Resolve PR number, branch, diff, touched files, and prior review status.
Capture the current PR head SHA. All gate outcomes must be pinned to this SHA.

Write or update review evidence file:

`docs/reviews/prs/pr-<number>-triple-review.md`

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

### 4. Greptile gate

Confirm Greptile review is present for the current PR revision.

If `greptile_required_for_code_prs: true` in `compound-engineering.local.md`, this gate is mandatory.

If missing, mark gate as pending and stop with explicit next action.

### 5. Burden control rules

- Default: one Codex pass per commit batch.
- Re-run Codex only if new commits materially change risk.
- For very large PRs, run focused Codex passes per subsystem (max 2 by default).
- Skip redundant teammate re-runs when no code changed since last run.

### 6. Gate decision

PR gate is **PASS** only when:

- teammate gate: no open blocker
- Codex Extra High gate: no open blocker
- Greptile gate: no open blocker
- all gate results match current PR head SHA

Otherwise **FAIL** with explicit remediation checklist.

### 7. Output

Return:

- gate status (PASS/FAIL/PENDING)
- evidence file paths
- blocker list (if any)
- next action
