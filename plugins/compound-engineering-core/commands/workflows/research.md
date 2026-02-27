---
name: workflows:research
description: Run deep evidence-backed research with iterative PM guidance using both codebase and external context
argument-hint: "[topic, question, decision, or initiative to research]"
---

# Deep Research (Codebase + Frontier)

Use this command when you need deep research before committing to an approach.

This command does not write implementation code.

## Inputs

<research_input> #$ARGUMENTS </research_input>

If empty, ask:
"What should we research? Please include the decision you need to make, constraints, and what good looks like."

Optional runtime flags in arguments:

- `teams=on|off` (default `off`)
- `depth=quick|standard|deep` (default `standard`)
- `scope=codebase|external|hybrid` (default `hybrid`)
- `as_of=YYYY-MM-DD` (default: current run date)

## Policy and defaults

1. Read `compound-engineering.local.md` if present.
2. Resolve `research_agents` from frontmatter when defined.
3. If unset, default agent set:
   - `compound-engineering-core:repo-research-analyst`
   - `compound-engineering-core:learnings-researcher`
   - `compound-engineering-core:framework-docs-researcher`
   - `compound-engineering-core:external-frontier-researcher`
   - `compound-engineering-core:best-practices-researcher`
4. Set `research_max_rounds` from policy when available; default `3`.
5. Agent ID normalization: if an ID has no namespace prefix, resolve as `compound-engineering-core:<agent-id>`.

## Workflow

### 1. Frame the research objective

1. Extract:
   - decision/question to answer
   - constraints and non-goals
   - success criteria
   - risk tolerance
2. If missing, ask focused PM questions before research starts.
3. Define `done_when` so the command knows when to stop.

### 2. Runtime controls and teams preflight

1. Parse `teams`, `depth`, `scope`, and `as_of`.
2. If `teams=on`, validate `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.
3. If `teams=on` and unavailable, fail closed with reason `agent_teams_unavailable`.

### 3. Build research tracks

Create tracks based on `scope`:

- `codebase`: repo patterns, ADRs, prior learnings, known failure modes
- `external`: latest docs/releases, best practices, ecosystem shifts
- `hybrid`: both codebase and external tracks

Depth guidance:

- `quick`: narrow scan, 1 round, highest-signal evidence only
- `standard`: balanced scan, up to 2 rounds
- `deep`: comprehensive scan, up to `research_max_rounds`

### 4. Run evidence gathering (round 1)

Execution mode:

- If `teams=on`: run tracks in parallel via agent teams
- If `teams=off`: run sequentially

External/time-sensitive claims must include dated sources.

### 5. Synthesize and surface uncertainty

After each round, produce:

- verified findings
- contested claims
- unknowns that block recommendation confidence
- highest-leverage follow-up questions

### 6. PM feedback loop (required)

Run iterative PM interaction loops until stop criteria:

1. Ask 1-3 highest-value questions (not a long questionnaire).
2. Update assumptions from PM answers.
3. Launch targeted follow-up research only on unresolved areas.
4. Re-synthesize and reassess confidence.

Stop when either:

- `done_when` criteria are met, or
- round cap is reached, or
- PM asks to finalize with remaining uncertainty documented.

### 7. Quality and freshness gate

Before final output:

1. No critical recommendation may rely on unsourced claims.
2. Time-sensitive claims must include:
   - source URL
   - source publish/updated date (if available)
   - checked-on date (`as_of`)
   - confidence
3. Contradictions must be resolved or explicitly documented.

### 8. Capture artifact

Write to:

`docs/research/YYYY-MM-DD-<topic>-research.md`

Minimum sections:

- Objective and decision context
- Parameters (`scope`, `depth`, `as_of`, `teams`, rounds)
- Findings by track
- Evidence table (claim/source/date/checked/confidence)
- Contradictions and resolutions
- Open risks and unknowns
- Recommendation and alternatives
- PM Q&A log
- Revalidation plan/date

### 9. Handoff

Recommend next command based on state:

- still deciding WHAT: `/compound-engineering-core:workflows:brainstorm "<topic>"`
- ready to define HOW: `/compound-engineering-core:workflows:plan-loop "<topic or plan path>"`
- existing plan needs deeper grounding: `/compound-engineering-core:workflows:deepen-plan "<plan-path>"`

## Output

Return:

- research document path
- recommendation + confidence
- unresolved unknowns
- suggested next command
