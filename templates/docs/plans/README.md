# Plans

Plan docs are the source of truth for what should be built and why.

## File Types

- `YYYY-MM-DD-<type>-<name>-plan.md`: approved implementation plan
- `YYYY-MM-DD-<type>-<name>-execution.md`: real-time implementation tracker
- `templates/execution-status-template.md`: tracker template
- `archive/`: superseded or canceled plans

## Status Rules

Use plan frontmatter status:

- `active`: drafting or refining
- `approved`: approved for build
- `in_progress`: implementation started
- `implemented`: accepted and shipped
- `superseded`: replaced by another plan

## Operating Rules

1. One execution tracker per approved plan.
2. Update execution tracker as work progresses, not after the fact.
3. Keep acceptance criteria in the plan and validation evidence in execution tracker.
4. Update `docs/knowledge/plans-index.md` whenever status changes.
5. Use `scripts/init-plan-tracker.sh docs/plans/<plan-file>` to initialize tracker quickly.
