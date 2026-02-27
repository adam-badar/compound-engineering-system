# Changelog

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
