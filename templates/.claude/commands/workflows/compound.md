---
name: workflows:compound
description: Capture a non-trivial solved problem as high-signal institutional knowledge (not documentation slop)
argument-hint: "[optional solved-problem context]"
---

# Compound Learning Capture

Use this command after a meaningful fix/decision is validated to improve future planning quality.

Do not run this for trivial changes.

## Inputs

<compound_input> #$ARGUMENTS </compound_input>

Accepted input formats:

- free-form context (manual usage), for example: `"session refresh bug in dashboard filters"`
- structured context from `workflows:work`, for example:
  - `"<approved-plan-path> | pr=<pr-number-or-url> | merged_sha=<merged-sha>"`

When structured fields are present, use them in the output references/evidence section.

## Quality Gate (Fail-Closed for Noise)

Only create/update a solution doc when all are true:

1. Outcome is verified (tests/pass + behavior confirmed).
2. Problem was non-trivial (required investigation, tradeoff, or edge-case handling).
3. Learning is reusable for future planning/review.
4. At least one concrete prevention/test pattern can be stated.

If any condition is false, return `status: skipped` with a one-line rationale and do not write files.

## Workflow

### 1. Classify candidate learning

Determine:

- scope (`bug_fix|feature_pattern|workflow_pattern|integration_pattern`)
- risk tags (correctness/security/data/perf/ux)
- affected components/modules
- edge-case class (if any): `refresh-rehydrate`, `session-expiry`, `retry-idempotency`, `race`, `rollback`, `other`

### 2. De-dup before write

Search existing `docs/solutions/` for similar entries by:

- module/component
- failure symptom
- root cause pattern
- edge-case class

If a close match exists, update the existing doc instead of creating a new one.

### 3. Write high-signal artifact

Write to:

`docs/solutions/<category>/<slug>.md`

Use this compact structure:

- summary (2-4 lines)
- problem symptoms
- root cause
- implemented fix
- prevention guardrails
- required tests (including refresh/resume when applicable)
- applicability:
  - `apply_when`
  - `do_not_apply_when`
- references (PR, files, related plans)

Avoid long narrative. Prefer specific, testable guidance.

### 4. Keep retrieval-friendly metadata

Include YAML frontmatter with:

- `date`
- `category`
- `components`
- `tags`
- `edge_case_class`
- `severity`

### 5. Optional critical-pattern promotion

If the learning is broadly reusable and high-risk if missed, add or update:

`docs/solutions/patterns/critical-patterns.md`

with a concise rule and verification hint.

## Output

Return:

- `status: created|updated|skipped`
- solution path(s)
- one-line note describing what future planner/reviewer should now catch
