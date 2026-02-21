# Planning and Review Loop

This process defines how planning runs before implementation starts.

## Roles

- PM/architect: defines the problem, approves priorities, accepts tradeoffs
- Planning workflow: drafts the plan and keeps it internally consistent
- Plan-review agents: critique architecture, security, performance, and simplicity
- External Codex reviewer: independent review at Extra High reasoning depth
- Research agents: gather evidence when reviewers identify uncertainty

## Required Loop

1. PM/architect provides problem statement, outcomes, constraints, success metrics, non-goals.
2. Planning workflow creates/updates `docs/plans/*-plan.md`.
3. Plan-review agents critique the plan.
4. Planning workflow asks PM/architect only the unresolved decision questions.
5. Plan updates are applied.
6. Run external Codex review in Extra High mode and record evidence.
7. Steps 3-6 repeat until PM/architect, plan-review agents, and Codex all approve.

No implementation begins until this loop exits.

## PR Triple Review Policy

Every code PR must pass all three gates before merge:

1. Teammate review agents
2. Codex Extra High review
3. Greptile review

Record results under `docs/reviews/prs/`.

## Mid-Epic Delta Loop

When implementation reveals material changes:

1. Run `/workflows:epic-delta-loop`.
2. Create and review delta plan.
3. Get PM + teammate + Codex approvals.
4. Merge approved delta back into parent epic plan/tracker.

Do not discard parent context or restart planning from scratch.

## Epic Definition

An epic is the smallest independently shippable work package that:

- Delivers user-visible or operational value
- Has testable acceptance criteria
- Has clear start/end boundaries
- Can be assigned and tracked independently

If an epic cannot satisfy those requirements, split it further.

## Knowledge Base Lifecycle

Plans are living artifacts with explicit state transitions:

- `active`: being drafted/refined
- `approved`: planning loop complete, ready for execution
- `in_progress`: implementation started
- `implemented`: accepted and deployed
- `superseded`: replaced by a newer plan

Use `docs/knowledge/plans-index.md` as the single source of truth for status. Keep one row per plan and update status, never duplicate rows.

## Clutter Control

- Keep active plans in `docs/plans/`
- Move superseded or canceled plans to `docs/plans/archive/`
- Keep implemented plans in place, but ensure status is `implemented` in index
- Keep one execution tracker per plan (`*-execution.md`)
