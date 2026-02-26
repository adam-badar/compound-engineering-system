---
name: workflows:debug
description: Run a structured debug loop to reproduce, isolate, and resolve issues with optional agent-team fan-out
argument-hint: "[bug description, failing test, error trace, or subsystem]"
---

# Debug Loop (Reproduce -> Isolate -> Fix)

Use this command when behavior is incorrect, flaky, or unexplained.

Goal: produce a verified root cause and a minimal fix plan (or direct fix if explicitly requested).

## Inputs

<debug_input> #$ARGUMENTS </debug_input>

If empty, ask:
"What is failing? Include observed behavior, expected behavior, reproduction steps, and error output."

Optional runtime flag in arguments:

- `teams=on` to require agent teams for parallel debug tracks in this run
- `teams=off` (default) to run without hard agent-teams requirement

## Workflow

### 1. Triage and reproducibility

1. Classify issue type:
   - correctness bug
   - regression
   - performance issue
   - reliability/flake
   - configuration/integration issue
2. Capture expected vs actual behavior.
3. Build a minimal reproduction command or sequence.
4. If not reproducible, gather missing diagnostics first (logs, inputs, env, version).

### 2. Agent-teams preflight (optional)

1. Parse `teams=on|off` from input (default `off`).
2. If `teams=on`, validate `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.
3. If `teams=on` and unavailable, fail closed with reason `agent_teams_unavailable` and stop.
4. If `teams=off`, continue.

### 3. Parallel evidence tracks

Run targeted tracks and then synthesize:

Always run:

- `compound-engineering-core:repo-research-analyst` (existing patterns and likely touchpoints)
- `compound-engineering-core:learnings-researcher` (historical failures and prior fixes)

Conditionally run based on issue profile:

- `compound-engineering-core:security-sentinel` for auth/trust/input risks
- `compound-engineering-core:performance-oracle` for latency/throughput/resource symptoms
- `compound-engineering-core:architecture-strategist` for boundary/control-flow failures
- `compound-engineering-core:kieran-python-reviewer` for Python runtime/typing/async defects

Execution mode:

- If `teams=on`: run selected tracks in parallel via agent teams.
- If `teams=off`: run sequentially.

### 4. Root-cause synthesis

Produce:

- confirmed root cause(s) vs hypotheses
- confidence per candidate
- why this escaped current tests/reviews
- blast radius and risk classification

If no root cause is confirmed, stop and request exactly what data is missing.

### 5. Fix options and recommendation

Provide 1-3 fix options.

For each option include:

- change summary
- risk/tradeoff
- required tests (unit + integration)
- rollback strategy

Recommend one option with rationale.

### 6. Capture debug artifact

Write output to:

`docs/debug/YYYY-MM-DD-<topic>-debug.md`

Minimum sections:

- issue summary
- repro steps and evidence
- root cause
- fix options
- selected fix
- validation checklist
- follow-up prevention actions

### 7. Execution handoff

If PM requests implementation, route to:

`/compound-engineering-core:workflows:work <plan-or-task-path>`

For urgent small fixes, execution can proceed immediately after explicit PM approval.

## Output

Return:

- debug artifact path
- root cause status (confirmed/partial/unconfirmed)
- recommended fix option
- validation steps
