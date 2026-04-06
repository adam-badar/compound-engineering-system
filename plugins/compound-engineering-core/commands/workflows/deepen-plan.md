---
name: workflows:deepen-plan
description: Deepen an existing plan with targeted research passes and iterative PM feedback loops
argument-hint: "[path to plan file, e.g. docs/plans/2026-02-26-my-plan.md]"
---

# Deepen Plan (Research-First)

Use this command when a plan exists but needs deeper grounding before execution or approval.

This command does not write production code.

## Inputs

<plan_path> #$ARGUMENTS </plan_path>

If empty:

1. list recent plans under `docs/plans/`
2. ask which plan to deepen

Optional runtime flags in arguments:

- `teams=on|off` (default `off`)
- `depth=quick|standard|deep` (default `standard`)
- `as_of=YYYY-MM-DD` (default: current run date)

## Policy and defaults

1. Read `compound-engineering.local.md` if present.
2. Resolve `research_agents` from frontmatter when defined.
3. If unset, default to:
   - `compound-engineering-core:repo-research-analyst`
   - `compound-engineering-core:learnings-researcher`
   - `compound-engineering-core:framework-docs-researcher`
   - `compound-engineering-core:external-frontier-researcher`
   - `compound-engineering-core:best-practices-researcher`
4. Set `deepen_plan_max_rounds` from policy when available; default `2`.
5. Agent ID normalization: if an ID has no namespace prefix, resolve as `compound-engineering-core:<agent-id>`.

## Workflow

### 1. Validate plan and parse structure

1. Confirm plan file exists and is readable.
2. Parse sections and mark low-confidence areas:
   - assumptions/constraints
   - options and selected approach
   - risk model/mitigations
   - dependency strategy
   - PR ladder and testing strategy
   - rollout/rollback
3. Build a section manifest with confidence labels (`high|medium|low`).

### 2. Teams preflight (optional)

1. Parse `teams`, `depth`, `as_of`.
2. If `teams=on`, validate `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.
3. If unavailable, fail closed with reason `agent_teams_unavailable`.

### 3. Run deepening research pass

For low/medium-confidence sections, run targeted research tracks:

- codebase pattern validation
- historical failure/learnings validation
- framework/library behavior validation
- external frontier changes (for volatile domains)
- best-practice alignment and anti-pattern detection

Execution mode:

- If `teams=on`: parallel via agent teams
- If `teams=off`: sequential

### 4. Adversarial verification (negative claims)

After the deepening research pass, scan both the **new research output** and the **original plan text** for claims that conclude absence or non-existence of a capability, API, feature, pattern, or service. Scanning the original plan text catches pre-existing negative claims from prior planning phases that may now be stale.

The scan is semantic — look for explicit negatives ("X doesn't exist", "no API") and implicit negatives ("lacks", "is absent", "does not provide", "unavailable as of", "could not find"). Do not rely on keyword matching alone.

**Origin-based guard:** Only run external counter-queries on negative claims about external products/services. Negative claims about codebase patterns (from `repo-research-analyst`, `learnings-researcher`, `framework-docs-researcher`) are logged with paths checked but never trigger external counter-research.

1. Extract all negative claims from both the research output and the original plan text, tagged with origin (agent or plan section).
2. If zero negative claims: skip this step entirely.
3. Filter to external-facing negatives only. Log codebase negatives with paths checked.
4. For each external negative claim in a `high` volatility domain (per the Domain Volatility Taxonomy defined in `external-frontier-researcher`):
   a. Formulate a directed counter-query that assumes the claim is wrong. If the original claim is version-scoped or tier-scoped, the counter-query must match the same scope first, then broaden only if the scoped search is exhausted.
   b. Run `external-frontier-researcher` with the counter-query. Instruct the agent to check 3-5 high-signal sources only (official docs, changelog, GitHub, one community source).
   c. If counter-evidence is found: revise the original claim in the plan, flag the correction, and re-assign confidence based on the counter-evidence strength.
   d. If no counter-evidence: retain the claim with sources-checked documentation from both the original and counter-query passes.
5. For `medium` volatility domains: log the negative claim with sources checked. Counter-research is not automatic but can be triggered by PM in the interaction loop.
6. For `low` volatility domains: log the negative claim with sources checked. No counter-research.
7. This step is a **single pass**. Do not recurse — if the counter-query itself produces negative claims, document them but do not run another adversarial verification round.
8. Document all adversarial checks in the deepening evidence artifact.

**Re-entry:** If a subsequent deepening pass (step 3, re-run after PM feedback) introduces new negative claims, rerun this step on the new claims only — do not re-verify claims already checked in prior rounds.

### 5. PM interaction loop (required)

After each pass:

1. Present what changed in confidence.
2. Ask only decision-critical PM questions (1-3 per round).
3. Update the plan with PM answers and evidence-backed adjustments.
4. Re-run targeted research for unresolved sections.

Stop when:

- no critical low-confidence sections remain, or
- round cap reached, or
- PM requests finalize with known uncertainty documented.

### 6. Update artifacts

1. Update plan in place with deepened content and clarified decisions.
2. Add/update plan metadata:
   - `updated_at: YYYY-MM-DD`
   - `deepened_at: YYYY-MM-DD`
3. Write deepening evidence to:

`docs/reviews/plans/<plan-slug>-deepen-research.md`

Evidence must include:

- parameters (`depth`, `as_of`, rounds)
- section-by-section confidence deltas
- key findings and sources
- PM Q&A log
- unresolved risks

### 7. Handoff

If approval gate is still pending:

`/compound-engineering-core:workflows:plan-loop "<plan-path>"`

If plan is approved and ready:

`/compound-engineering-core:workflows:work <plan-path>`

## Output

Return:

- updated plan path
- deepening evidence path
- confidence summary
- unresolved risks
- recommended next command
