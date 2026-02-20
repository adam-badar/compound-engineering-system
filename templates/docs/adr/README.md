# Architecture Decision Records

Record significant architecture decisions here. Each ADR is numbered and immutable once accepted. To change a decision, create a new ADR that supersedes it.

## Template

```markdown
# ADR-{NNN}: {Title}

## Status
{Proposed | Accepted | Deprecated | Superseded by ADR-NNN}

## Context
What is the issue or force motivating this decision?

## Decision
What is the change being proposed or decided?

## Consequences
What becomes easier or harder as a result? What are the tradeoffs?
```

## Conventions

- Number sequentially: `001-use-postgres.md`, `002-adopt-event-sourcing.md`
- Keep status current. Mark old decisions as `Superseded by ADR-NNN` when replaced.
- Write in past tense for accepted decisions ("We decided to...").
- Link to relevant code, PRs, or issues where applicable.
