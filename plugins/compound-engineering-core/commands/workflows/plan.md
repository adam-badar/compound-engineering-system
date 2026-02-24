---
name: workflows:plan
description: Create or update a structured plan document for a non-trivial initiative
argument-hint: "[problem statement or scope summary]"
---

# Create Plan

Use this command to generate an implementation-ready plan at `docs/plans/*-plan.md`.

## Inputs

<plan_input> #$ARGUMENTS </plan_input>

If empty, ask: "What should this plan solve?"

## Workflow

### 1. Gather context

1. Read `CLAUDE.md`, relevant ADRs, and existing docs under `docs/`.
2. Run focused research agents when needed:
   - `compound-engineering-core:repo-research-analyst`
   - `compound-engineering-core:learnings-researcher`
   - Optional: `compound-engineering-core:framework-docs-researcher`

### 2. Build plan draft

Create a new plan file in `docs/plans/` using date-prefixed slug format:

`YYYY-MM-DD-<topic>-plan.md`

Populate with:

- overview
- outcomes and success metrics
- scope and non-goals
- assumptions and constraints
- options considered and selected approach
- risks and mitigations
- dependencies
- acceptance criteria (testable)
- rollout and rollback strategy
- open decision questions

Include frontmatter fields:

- `title`
- `status: active`
- `created_at: YYYY-MM-DD`
- `updated_at: YYYY-MM-DD`

### 3. Resolve critical unknowns

Ask only decision-critical questions that block good planning.

### 4. Finalize handoff

Return:

- plan path
- unresolved blockers/questions
- recommended next command:
  - `/compound-engineering-core:workflows:plan-loop <plan-path>`
