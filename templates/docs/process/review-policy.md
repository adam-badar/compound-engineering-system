# Review Policy

## Plan Approval Gate

A plan can be marked `approved` only when all pass:

1. PM/architect approval
2. Teammate plan-review agents approval
3. Codex Extra High external approval
4. Gate output pinned to current revision (commit SHA + plan hash)

## PR Triple Review Gate

A code PR can be merged only when all pass:

1. Teammate review agents
2. Codex Extra High external review
3. Greptile review
4. All gate outputs match current PR head SHA

## Overhead Controls

To prevent review overload:

- Run Codex once per stable revision.
- Re-run only after material change.
- Prefer focused re-review on changed areas, not full re-review of unchanged sections.
- Keep evidence docs concise and link to artifacts instead of copying full transcripts.

## Availability Policy

- External Codex gate must use `codex-xhigh` MCP server.
- If `codex-xhigh` is unavailable, gate fails closed and merge/approval cannot proceed.
