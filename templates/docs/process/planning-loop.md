# Planning and Review Loop

This process defines how planning runs before implementation starts.

Use `/compound-engineering-core:workflows:brainstorm` first when problem framing or approach is still ambiguous.
For fast-moving domains (AI models, external APIs, compliance, pricing), run with external freshness research enabled, for example:

`/compound-engineering-core:workflows:brainstorm "<topic> research=on research_depth=standard"`

For deep research before planning decisions, run:

`/compound-engineering-core:workflows:research "<topic> depth=deep scope=hybrid"`

If a plan already exists but needs stronger grounding, run:

`/compound-engineering-core:workflows:deepen-plan "docs/plans/<plan>.md"`

## Roles

- PM/architect: defines the problem, approves priorities, accepts tradeoffs
- Planning workflow: drafts the plan and keeps it internally consistent
- Plan-review agents: critique architecture, security, performance, and simplicity
- External Codex reviewer: the current Claude agent runs the Codex MCP gate directly and normalizes findings into durable evidence
- Research agents: gather evidence when reviewers identify uncertainty

## Required Loop

1. PM/architect provides problem statement, outcomes, constraints, success metrics, non-goals.
2. Planning workflow creates/updates `docs/plans/*-plan.md`.
3. Plan-review agents critique the plan.
4. Spec-flow analysis runs on each material revision to detect permutation/edge-case gaps (including refresh/rehydrate/resume for stateful UX).
5. Planning workflow asks PM/architect only the unresolved decision questions.
6. Plan updates are applied.
7. Run external Codex review in Extra High mode directly from the current Claude agent and record evidence pinned to revision.
8. Steps 3-7 repeat until PM/architect, plan-review agents, and Codex all approve.

No implementation begins until this loop exits.

External Codex gate requires a connected global `codex-xhigh` MCP server.

Agent teams are optional for `/compound-engineering-core:workflows:brainstorm`, `/compound-engineering-core:workflows:research`, `/compound-engineering-core:workflows:deepen-plan`, `/compound-engineering-core:workflows:plan-loop`, `/compound-engineering-core:workflows:debug`, `/compound-engineering-core:workflows:explain`, and `/compound-engineering-core:workflows:pr-review`; add `teams=on` per run when you want fan-out.

Related non-coding workflows:

- `/compound-engineering-core:workflows:research` for deep evidence-backed investigation with iterative PM Q&A
- `/compound-engineering-core:workflows:deepen-plan` for plan-level research hardening before approval
- `/compound-engineering-core:workflows:debug` for reproducible root-cause loops
- `/compound-engineering-core:workflows:explain` for evidence-backed decision/behavior traceability

## Scope Sizing Contract

Each approved plan must include an Epic PR Ladder with one row per PR:

- PR id/title
- objective and acceptance criteria
- test plan (unit + integration)
- estimated net LOC
- estimated files changed
- rollback note

Default size budgets (override in `compound-engineering.local.md`):

- `max_prs_per_epic: 5`
- `max_net_loc_per_pr: 600`
- `max_files_per_pr: 20`
- `max_cycle_days_per_pr: 2`

If projected scope violates these budgets, split into child epics before approval.

Each approved plan must also include a **Flow Permutations & Edge Cases** section with:

- initial load
- refresh/rehydrate
- partial completion + resume
- error + retry
- session expiry/re-auth (if auth exists)
- offline/timeout degradation (if networked)

## PR Triple Review Policy

Every code PR must pass all three review sources plus test gate before merge:

1. Teammate review agents
2. Codex correctness pass
3. Codex edge-case pass
4. Test/CI gate for code PRs
5. Non-blocker triage and disposition (`implement_now|defer|reject`)

Record results under `docs/reviews/prs/`.

PR review invocation policy:

- `/compound-engineering-core:workflows:work` should auto-run PR review after each pushed SHA on open PRs using `approve_sha=<current-head-sha>`.
- For manual invocations, use `approve_sha=<current-head-sha>` when invoking PR review.
- If head SHA changes, invalidate prior gate/approval and rerun.
- Deferred high-value non-blockers require explicit PM signoff and follow-up ownership.
- After PR merge, wait for merge-triggered CI/CD/deploy on target-branch SHA before continuing to the next PR slice (or record `N/A` with rationale when no merge-triggered pipeline exists).
- After post-merge CI/CD is green, `/compound-engineering-core:workflows:work` should auto-run `/compound-engineering-core:workflows:compound` and record created/updated/skipped evidence before proceeding.

`spec-flow-analyzer` output handling:

- If it returns `status: not_applicable`, record the rationale and do not invent frontend/state blockers.
- If it returns `required_tests`, copy them into the plan's Flow Permutations section or per-PR test strategy before approval.

## Mid-Epic Delta Loop

When implementation reveals material changes:

1. Run `/compound-engineering-core:workflows:epic-delta-loop`.
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
