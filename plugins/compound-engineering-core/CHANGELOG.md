# Changelog

## 0.4.4 - 2026-03-08

- Hardened Greptile gate semantics in `workflows:pr-triple-review`:
  - fail-closed for missing/stale Greptile on code PRs
  - explicit exception path requires reason + PM signoff
  - exception is SHA-scoped and invalidated on new head SHA
- Clarified `workflows:work` behavior to auto-run triple review after each pushed SHA on active PRs.
- Added `allow_greptile_exception_for_code_prs` policy knob (default `true`) to template config.
- Updated templates/runbooks/review policy for:
  - SHA-scoped Greptile exception handling
  - manual triple-review examples with `approve_sha=<current-head-sha>`
  - removal of stale `/compound-engineering-setup` reference in favor of upstream `/setup` and `/triage` context.
  - explicit guidance that default deferred-item tracking stays in review evidence + execution tracker (no extra todo-file system required).

## 0.4.3 - 2026-03-06

- Added a post-merge CI/CD confirmation gate to `workflows:work`:
  - after merge, wait for merge-triggered workflows on target branch/SHA
  - block progression while merge-triggered workflows are pending
  - fail closed on post-merge CI/CD failure
  - allow explicit `N/A` only when no merge-triggered CI/CD exists
- Updated template docs and workflow policy to require post-merge CI/CD confirmation before starting the next PR slice or epic closeout.

## 0.4.2 - 2026-03-04

- Updated `workflows:work` to auto-run `workflows:pr-triple-review` per PR batch with SHA authorization (`approve_sha=<head-sha>`), removing the manual per-SHA approval prompt inside execution flow.
- Added stale-output handling guidance in `workflows:work` so background results tied to old SHAs are non-authoritative.
- Hardened `workflows:work` local validation requirements:
  - always run unit tests before PR gate
  - require integration tests for boundary/API/integration/auth/worker/schema changes
  - fail fast on missing/skipped integration tests without approved exception
- Renamed triple-review authorization language from PM-only to SHA-authorization to align with automated execution flow.
- Updated templates and process docs to reflect automatic triple-review invocation from `workflows:work` and manual `approve_sha` for ad-hoc gate runs.

## 0.4.1 - 2026-02-27

- Hardened non-blocker triage to reduce low-value `defer/reject` outcomes:
  - consensus-aware normalization (`support_count`, `supporting_reviewers`)
  - default promotion of multi-reviewer consensus findings (`consensus_threshold_for_promotion`, default `2`)
  - counterevidence requirement for `reject` when policy enabled
  - PM signoff requirement for deferred consensus findings
- Updated `workflows:plan-loop`, `workflows:pr-triple-review`, and `workflows:work` with consensus escalation gates.
- Updated template policy docs and local config defaults for consensus-based non-blocker handling.

## 0.4.0 - 2026-02-26

- Added `workflows:research` for deep-research style investigation with iterative PM feedback loops.
- Added `workflows:deepen-plan` to strengthen existing plans with targeted research rounds and confidence tracking.
- Added `best-practices-researcher` agent for prioritized external guidance with anti-pattern detection.
- Added template docs structure for research artifacts under `docs/research/`.
- Added policy knobs in `compound-engineering.local.md`:
  - `research_agents`
  - `research_max_rounds`
  - `deepen_plan_max_rounds`

## 0.3.1 - 2026-02-26

- Upgraded `workflows:brainstorm` with freshness-aware research controls:
  - `research=auto|on|off`
  - `research_depth=quick|standard|deep`
  - `as_of=YYYY-MM-DD`
- Added `external-frontier-researcher` for time-sensitive external research in volatile domains.
- Added dated evidence requirements for external claims in brainstorm artifacts (source URL + source date + checked date + confidence).

## 0.3.0 - 2026-02-26

- Added non-coding workflow commands:
  - `workflows:brainstorm`
  - `workflows:debug`
  - `workflows:explain`
- Added non-blocker value triage requirements across planning and PR gates:
  - explicit disposition (`implement_now|defer|reject`)
  - PM signoff requirement for deferred high-value items (policy-controlled)
  - auto-promotion path for high-impact non-blockers
- Updated `workflows:work` to require non-blocker triage completion before merge
- Updated templates, runbooks, and process docs to include new workflows and non-blocker policy

## 0.2.0 - 2026-02-25

- Added hard plan sizing contract with Epic PR Ladder requirements
- Added explicit per-PR testing strategy requirements in planning
- Added mandatory test/CI gate for code PRs in triple review workflow
- Disallowed conditional-pass merges for code PRs by default
- Updated templates and local policy defaults for sizing and testing gates

## 0.1.0 - 2026-02-24

- Initial private marketplace plugin release
- Added core workflow commands
- Added review/research agents and codex gate runner
