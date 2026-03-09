# Reviews Evidence

Store durable review evidence here so gates remain auditable even as chat context grows.

## Structure

- `plans/`: plan and delta review evidence
- `prs/`: PR review evidence

## Required Files

- Plan gate: `plans/<plan-slug>-codex-extra-high.md`
- PR gate: `prs/pr-<number>-review.md`
- Optional detailed Codex PR dumps:
  - `prs/pr-<number>-codex-correctness.md`
  - `prs/pr-<number>-codex-edgecase.md`
- Reference templates:
  - `plans/plan-gate-template.md`
  - `prs/pr-review-gate-template.md`

## Conventions

1. Keep one evidence file per gate run and update in place for same revision.
2. Include date, revision/hash, reviewer source, blockers, and pass/fail.
3. Link evidence from plan trackers and knowledge index.
4. Pin each gate result to the reviewed commit SHA (or plan hash + commit SHA).
