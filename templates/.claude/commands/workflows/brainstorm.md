---
name: workflows:brainstorm
description: Explore problem framing and solution options before planning, with optional agent-team fan-out
argument-hint: "[feature idea, problem statement, or initiative prompt]"
---

# Brainstorm (What and Why Before How)

Use this command when the problem is still fuzzy or multiple product/UX directions are possible.

This command is for discovery and decision framing.
It does not produce implementation code.

## Inputs

<brainstorm_input> #$ARGUMENTS </brainstorm_input>

If empty, ask:
"What should we brainstorm? Please include user, problem, desired outcome, and constraints."

Optional runtime flag in arguments:

- `teams=on` to require agent teams for parallel idea exploration in this run
- `teams=off` (default) to run without hard agent-teams requirement

## Workflow

### 1. Clarify objective and scope

1. Extract:
   - target user/persona
   - current pain
   - desired outcome
   - constraints/non-goals
2. If any of the above is missing, ask focused questions before analysis.
3. Confirm brainstorm scope boundary (what this session will and will not decide).

### 2. Agent-teams preflight (optional)

1. Parse `teams=on|off` from input (default `off`).
2. If `teams=on`, validate `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.
3. If `teams=on` and unavailable, fail closed with reason `agent_teams_unavailable` and stop.
4. If `teams=off`, continue.

### 3. Evidence gathering

Run lightweight context checks first:

- `repo-research-analyst`
- `learnings-researcher`

If external assumptions are material, run:

- `framework-docs-researcher`

Execution mode:

- If `teams=on`: run in parallel via agent teams.
- If `teams=off`: run sequentially.

### 4. Option generation

Generate 2-4 concrete options with PM-level tradeoffs:

For each option include:

- one-sentence summary
- target user impact
- pros/cons
- delivery risk
- expected effort (S/M/L)
- key edge cases

Apply YAGNI by default. Prefer the simplest option that still meets the outcome.

### 5. Decision loop

Ask the PM/architect only decision-critical questions, such as:

- Which tradeoff matters most (speed, quality, flexibility, cost)?
- What is the minimum acceptable user outcome for V1?
- Which risks are acceptable now vs deferred?

Iterate options if needed until one primary direction is selected.

### 6. Capture artifact

Write brainstorm output to:

`docs/brainstorms/YYYY-MM-DD-<topic>-brainstorm.md`

Minimum sections:

- Problem framing
- User and outcome
- Constraints and non-goals
- Options considered
- Chosen direction and rationale
- Open questions (if any)
- Decision timestamp and owner

### 7. Handoff

If open questions remain, do not start planning.

If direction is clear, recommend:

`/workflows:plan-loop "<problem statement or brainstorm path>"`

## Output

Return:

- brainstorm document path
- chosen direction
- unresolved questions
- recommended next command
