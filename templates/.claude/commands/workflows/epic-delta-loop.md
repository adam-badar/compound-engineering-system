---
name: workflows:epic-delta-loop
description: Run a nested planning loop for mid-epic scope changes and merge approved deltas back into the epic
argument-hint: "[parent plan path] | [delta request]"
---

# Epic Delta Loop

Use this command when new findings during implementation require scope, priority, or acceptance-criteria changes inside an active epic.

Never start from scratch. Extend the existing epic with a controlled delta loop.

## Inputs

<delta_input> #$ARGUMENTS </delta_input>

Required:

- parent epic plan path (`docs/plans/*-plan.md`)
- delta request (new requirement, discovered risk, dependency change, or acceptance update)

If one is missing, ask for it.

## Workflow

### 1. Load parent context

Read:

- parent plan
- parent execution tracker
- latest review evidence files for that epic
- parent plan revision (latest commit SHA + plan hash)

### 2. Classify delta

Classify delta scope:

- **Minor:** no acceptance criteria or architecture change
- **Material:** acceptance criteria, architecture, dependency, risk, or rollout change

Minor deltas can be logged directly in tracker decisions section.
Material deltas must run full nested loop below.

### 3. Material delta nested loop (required for material deltas)

1. Create delta plan file:
   - `docs/plans/deltas/YYYY-MM-DD-<epic-slug>-delta-<topic>.md`
2. Run teammate plan-review agents on the delta.
3. Validate `codex_mcp_server` and `codex_gate_agent` availability.
4. Run Codex Extra High external review on the delta through `codex_gate_agent`.
   - pin to delta revision (commit SHA + delta hash)
5. Ask PM only unresolved decision questions.
6. Update delta plan and repeat until all blockers are cleared.

### 4. Delta approval criteria

Delta is approved only when:

- PM approves priority/scope change
- teammate plan-review gate passes
- Codex Extra High delta gate passes

### 5. Merge back to parent artifacts

After delta approval:

1. Update parent plan with delta decisions and acceptance criteria changes.
2. Update parent execution tracker with:
   - delta summary
   - new tasks
   - changed risks
3. Add delta entry in `docs/knowledge/plans-index.md` notes or linked evidence.
4. Archive closed delta files under `docs/plans/deltas/archive/` when fully implemented.
5. If parent plan revision changes materially after merge, rerun relevant plan gate checks.

### 6. Boundary rule

If delta introduces a new independently shippable workstream, create a new epic plan instead of forcing it into the current epic.

### 7. Output

Return:

- delta classification (minor/material)
- delta plan path (if material)
- gate evidence paths
- parent plan/tracker files updated
- next implementation step
