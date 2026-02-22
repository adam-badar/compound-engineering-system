# Reviews Evidence

Store durable review evidence here so gates remain auditable even as chat context grows.

## Structure

- `plans/`: plan and delta review evidence
- `prs/`: PR triple-review evidence

## Required Files

- Plan gate: `plans/<plan-slug>-codex-extra-high.md`
- PR gate: `prs/pr-<number>-triple-review.md`
- Optional detailed Codex PR dump: `prs/pr-<number>-codex-extra-high.md`
- Reference templates:
  - `plans/plan-gate-template.md`
  - `prs/pr-triple-gate-template.md`

## Conventions

1. Keep one evidence file per gate run and update in place for same revision.
2. Include date, revision/hash, reviewer source, blockers, and pass/fail.
3. Link evidence from plan trackers and knowledge index.
4. Pin each gate result to the reviewed commit SHA (or plan hash + commit SHA).
