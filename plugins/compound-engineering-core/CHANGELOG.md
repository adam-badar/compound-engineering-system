# Changelog

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
