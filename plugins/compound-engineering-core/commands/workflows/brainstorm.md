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
5. Classify `volatility=high` when the topic includes fast-moving domains per the Domain Volatility Taxonomy defined in `external-frontier-researcher` (AI tools/models, developer tools/IDEs, SaaS platforms/APIs, crypto, compliance/regulatory).

### 3. Agent-teams preflight (optional)

1. If `teams=on`, validate `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.
2. If `teams=on` and unavailable, fail closed with reason `agent_teams_unavailable` and stop.
3. If `teams=off`, continue.

### 4. Evidence gathering

**4.0 Check `docs/ideas/` for prior deferred work** (required if folder exists in current repo):

Before generating new options, grep `docs/ideas/*.md` in the current repo for prior deferred work that may be relevant to this brainstorm topic. If matches found, surface them as candidate options to consider promoting (rather than generating new options that duplicate them). If a new option is being deferred mid-brainstorm (e.g., PM says "yes, but not now"), write it as `docs/ideas/YYYY-MM-DD-<slug>.md` immediately rather than letting it die in chat. If `docs/ideas/` does not exist in the current repo, skip this sub-step.

Then run lightweight context checks:

- `compound-engineering-core:repo-research-analyst`
- `compound-engineering-core:learnings-researcher`

Run `compound-engineering-core:external-frontier-researcher` when:

- `research=on`, or
- `research=auto` and `volatility=high`.

Use `research_depth` guidance for external research breadth:

- `quick`: 3-5 high-signal sources
- `standard`: 6-10 sources
- `deep`: 12+ sources across multiple tracks

If framework/library behavior assumptions are material, also run:
- `compound-engineering-core:framework-docs-researcher`

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

### 6. Adversarial verification (negative claims)

After the freshness gate, scan all qualified findings for claims that conclude absence or non-existence of a capability, API, feature, pattern, or service. This includes explicit negatives ("X doesn't exist", "no API") and implicit negatives ("lacks", "is absent", "does not provide", "unavailable as of", "could not find"). The scan is semantic — do not rely on keyword matching alone.

**Eligibility guards (check before running):**
- If `research=off`: skip this step entirely. The user explicitly opted out of external research; adversarial counter-queries would violate that choice.

**Origin-based guard:** Only run external counter-queries on negative claims produced by `external-frontier-researcher` or `best-practices-researcher`. Negative claims from codebase-focused agents are logged with paths checked but never trigger external counter-research.

1. Extract all negative claims from the research output, tagged with their originating agent.
2. If zero negative claims: skip this step entirely.
3. Filter to external-agent negatives only. Log codebase-agent negatives with paths checked.
4. For each external-agent negative claim in a `high` volatility domain (per the Domain Volatility Taxonomy defined in `external-frontier-researcher`):
   a. Formulate a directed counter-query that assumes the claim is wrong. If the original claim is version-scoped or tier-scoped, the counter-query must match the same scope first, then broaden only if the scoped search is exhausted.
   b. Run `external-frontier-researcher` with the counter-query. Instruct the agent to check 3-5 high-signal sources only (official docs, changelog, GitHub, one community source).
   c. If counter-evidence is found: revise the original claim, flag the correction, and re-assign confidence based on the counter-evidence strength.
   d. If no counter-evidence: retain the claim with sources-checked documentation from both the original and counter-query passes.
5. For `medium` volatility domains: log the negative claim with sources checked. Counter-research is not automatic but can be triggered by PM in the decision loop if the claim is decision-critical.
6. For `low` volatility domains: log the negative claim with sources checked. No counter-research.
7. This step is a **single pass**. Do not recurse — if the counter-query itself produces negative claims, document them but do not run another adversarial verification round.
8. Document all adversarial checks under "Dated evidence log" in the brainstorm artifact.

### 7. Option generation

Generate 2-4 concrete options with PM-level tradeoffs:

For each option include:

- one-sentence summary
- target user impact
- pros/cons
- delivery risk
- expected effort (S/M/L)
- key edge cases

Apply YAGNI by default. Prefer the simplest option that still meets the outcome.

### 8. Decision loop

Ask the PM/architect only decision-critical questions, such as:

- Which tradeoff matters most (speed, quality, flexibility, cost)?
- What is the minimum acceptable user outcome for V1?
- Which risks are acceptable now vs deferred?

Iterate options if needed until one primary direction is selected.

### 9. Capture artifact

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

### 10. Handoff

If open questions remain, do not start planning.

If direction is clear, recommend:

`/compound-engineering-core:workflows:plan-loop "<problem statement or brainstorm path>"`

## Output

Return:

- brainstorm document path
- chosen direction
- unresolved questions
- external research status (performed/skipped + reason)
- recommended next command
