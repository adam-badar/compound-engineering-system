# Solutions

Structured documentation for solved problems, implemented features, proven patterns, and architecture decisions that go beyond a single ADR.

## Subdirectories

### `bug-fixes/`
Root cause analyses for non-trivial bugs. Include: symptoms, investigation, root cause, fix, and prevention.

### `features/`
Design and implementation notes for significant features. Include: requirements, approach, alternatives considered, and outcome.

### `patterns/`
Reusable patterns discovered during development. Include: problem, solution, when to use, when not to use, and examples.
`patterns/critical-patterns.md` is the high-signal subset that planning/review should check by default.

### `architecture/`
System-level documentation: data flow diagrams, integration maps, scaling strategies, and infrastructure decisions.

## Conventions

- Use descriptive filenames: `2025-03-fix-webhook-race-condition.md`, `2025-04-feature-batch-processing.md`
- Date-prefix for chronological context.
- Link to related ADRs, PRs, and code where applicable.
- Keep solutions focused -- one problem per document.
- Prefer updating existing nearby solution docs over creating duplicates.
- Skip documentation for trivial fixes; use `/compound-engineering-core:workflows:compound` only for reusable, non-trivial learnings.
