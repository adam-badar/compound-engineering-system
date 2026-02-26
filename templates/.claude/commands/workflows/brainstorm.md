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

Optional runtime flags in arguments:

- `teams=on` to require agent teams for parallel idea exploration in this run
- `teams=off` (default) to run without hard agent-teams requirement
- `research=auto|on|off` (`auto` default) to control external/freshness research
- `research_depth=quick|standard|deep` (`standard` default) for external research breadth
- `as_of=YYYY-MM-DD` (default: current run date) to anchor time-sensitive claims

## Workflow

### 1. Clarify objective and scope

1. Extract:
   - target user/persona
   - current pain
   - desired outcome
   - constraints/non-goals
2. If any of the above is missing, ask focused questions before analysis.
3. Confirm brainstorm scope boundary (what this session will and will not decide).

### 2. Runtime controls and volatility check

1. Parse `teams=on|off` from input (default `off`).
2. Parse `research=auto|on|off` (default `auto`).
3. Parse `research_depth=quick|standard|deep` (default `standard`).
4. Parse `as_of=YYYY-MM-DD`; if missing, set `as_of` to today's date for this run.
5. Classify `volatility=high` when the topic includes fast-moving domains (AI models, external APIs, security/compliance rules, pricing, recently changing libraries/tools).

### 3. Agent-teams preflight (optional)

1. If `teams=on`, validate `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.
2. If `teams=on` and unavailable, fail closed with reason `agent_teams_unavailable` and stop.
3. If `teams=off`, continue.

### 4. Evidence gathering

Run lightweight context checks first:

- `repo-research-analyst`
- `learnings-researcher`

Run `external-frontier-researcher` when:

- `research=on`, or
- `research=auto` and `volatility=high`.

Use `research_depth` guidance for external research breadth:

- `quick`: 3-5 high-signal sources
- `standard`: 6-10 sources
- `deep`: 12+ sources across multiple tracks

If framework/library behavior assumptions are material, also run:

- `framework-docs-researcher`

If `research=off` and `volatility=high`, explicitly warn and ask PM/architect confirmation before continuing without external research.

Execution mode:

- If `teams=on`: run in parallel via agent teams.
- If `teams=off`: run sequentially.

### 5. Freshness and source quality gate

Before generating options:

1. Treat unsourced or stale time-sensitive claims as unresolved.
2. Require dated evidence for external claims:
   - source URL
   - source publish/updated date (if available)
   - checked-on date (`as_of`)
   - confidence (`high|medium|low`)
3. Mark inference explicitly when a claim is reasoned from sources rather than directly stated.

### 6. Option generation

Generate 2-4 concrete options with PM-level tradeoffs:

For each option include:

- one-sentence summary
- target user impact
- pros/cons
- delivery risk
- expected effort (S/M/L)
- key edge cases

Apply YAGNI by default. Prefer the simplest option that still meets the outcome.

### 7. Decision loop

Ask the PM/architect only decision-critical questions, such as:

- Which tradeoff matters most (speed, quality, flexibility, cost)?
- What is the minimum acceptable user outcome for V1?
- Which risks are acceptable now vs deferred?

Iterate options if needed until one primary direction is selected.

### 8. Capture artifact

Write brainstorm output to:

`docs/brainstorms/YYYY-MM-DD-<topic>-brainstorm.md`

Minimum sections:

- Problem framing
- User and outcome
- Constraints and non-goals
- Options considered
- Chosen direction and rationale
- Research mode used (`research`, `research_depth`, `as_of`, `volatility`)
- Dated evidence log (for external/time-sensitive claims)
- Open questions (if any)
- Decision timestamp and owner

### 9. Handoff

If open questions remain, do not start planning.

If direction is clear, recommend:

`/workflows:plan-loop "<problem statement or brainstorm path>"`

## Output

Return:

- brainstorm document path
- chosen direction
- unresolved questions
- external research status (performed/skipped + reason)
- recommended next command
