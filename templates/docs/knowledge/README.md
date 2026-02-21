# Knowledge Base

The knowledge base tracks decision context and implementation status without duplicating artifacts.

## Primary Files

- `plans-index.md`: status index of all plans
- `docs/plans/*`: canonical plan and execution docs
- `docs/reviews/*`: review evidence (teammate, Codex, Greptile)
- `docs/solutions/*`: reusable learnings after implementation
- `docs/adr/*`: architecture decisions

## Lifecycle Policy

1. Create plan in `docs/plans/` with status `active`.
2. After PM + teammate + Codex Extra High plan-review approval, set status to `approved`.
3. On implementation start, set status to `in_progress`.
4. On deploy + acceptance, set status to `implemented`.
5. If replaced, set old plan to `superseded` and move to archive if needed.

## Anti-clutter Rules

- Keep one row per plan in `plans-index.md`.
- Do not create duplicate "summary" docs for the same plan.
- Use execution tracker updates for in-flight context.
- Move canceled/superseded plans to `docs/plans/archive/`.
- Keep review evidence in `docs/reviews/` and link from index/tracker rather than duplicating findings elsewhere.
