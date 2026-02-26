---
name: workflows:explain
description: Explain how and why a system behavior, implementation, or decision exists, with evidence and optional agent-team fan-out
argument-hint: "[question, file path, PR number, decision, or subsystem]"
---

# Explain (Behavior and Decision Trace)

Use this command when you need a clear explanation of:

- why code behaves a certain way
- why a decision was made
- how a flow works end-to-end

This command is for understanding and traceability, not coding.

## Inputs

<explain_input> #$ARGUMENTS </explain_input>

If empty, ask:
"What should I explain? Provide the file/PR/feature and the specific confusion."

Optional runtime flag in arguments:

- `teams=on` to require agent teams for parallel evidence gathering in this run
- `teams=off` (default) to run without hard agent-teams requirement

## Workflow

### 1. Define explanation target

1. Classify target:
   - code path/behavior
   - architecture decision
   - review/gate outcome
   - historical change rationale
2. Identify required evidence sources:
   - code and tests
   - docs/plans/execution/reviews/ADRs
   - git history and PR context

### 2. Agent-teams preflight (optional)

1. Parse `teams=on|off` from input (default `off`).
2. If `teams=on`, validate `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.
3. If `teams=on` and unavailable, fail closed with reason `agent_teams_unavailable` and stop.
4. If `teams=off`, continue.

### 3. Evidence collection

Always gather repository and prior-learning context:

- `compound-engineering-core:repo-research-analyst`
- `compound-engineering-core:learnings-researcher`

Add targeted reviewers as needed:

- `compound-engineering-core:architecture-strategist` for system-level decision rationale
- `compound-engineering-core:kieran-python-reviewer` for Python behavior details
- `compound-engineering-core:security-sentinel` for auth/trust logic questions
- `compound-engineering-core:performance-oracle` for perf tradeoff questions

Execution mode:

- If `teams=on`: run selected tracks in parallel via agent teams.
- If `teams=off`: run sequentially.

### 4. Build the explanation

Provide a concise, evidence-backed explanation with:

- what happens (actual flow)
- why it was chosen (decision context)
- alternatives that were rejected or deferred (if known)
- edge cases and failure modes
- what would need to change to alter behavior safely

If evidence is insufficient, explicitly mark uncertainty and list missing sources.

### 5. Capture explain artifact (optional but preferred)

Write to:

`docs/explanations/YYYY-MM-DD-<topic>-explain.md`

Include:

- question asked
- evidence used
- explanation
- open uncertainties
- references (files/PRs/docs)

### 6. Handoff

If explanation reveals a required change, recommend next command:

- planning needed: `/compound-engineering-core:workflows:plan-loop "<problem>"`
- direct execution on approved scope: `/compound-engineering-core:workflows:work <plan-path>`

## Output

Return:

- explanation summary
- confidence level
- evidence references
- optional artifact path
