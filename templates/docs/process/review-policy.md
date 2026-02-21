# Review Policy

## Plan Approval Gate

A plan can be marked `approved` only when all pass:

1. PM/architect approval
2. Teammate plan-review agents approval
3. Codex Extra High external approval

## PR Triple Review Gate

A code PR can be merged only when all pass:

1. Teammate review agents
2. Codex Extra High external review
3. Greptile review

## Overhead Controls

To prevent review overload:

- Run Codex once per stable revision.
- Re-run only after material change.
- Prefer focused re-review on changed areas, not full re-review of unchanged sections.
- Keep evidence docs concise and link to artifacts instead of copying full transcripts.

