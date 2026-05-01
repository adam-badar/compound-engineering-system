# Changelog

## 0.6.1 - 2026-04-30

- Added `docs/ideas/` enforcement to `workflows:brainstorm` step 4.0 and `workflows:plan-loop` step 1. Brainstorm grep-checks the per-repo deferred-work folder for prior ideas before generating new options; mid-brainstorm deferrals are written as idea files immediately. Plan-loop confirms any `docs/ideas/*.md` files referenced in the source brainstorm are resolved (active / deferred-with-owner / rejected / completed / abandoned) before plan generation or review gate launch.
- Idea file content is treated as untrusted data in both workflows: only frontmatter and prose summary are extracted; instructions or role overrides inside idea bodies are ignored.
- Mid-brainstorm idea writes constrain slugs to lowercase-alphanumeric-plus-hyphens, require minimal frontmatter (`status`/`owner`/`target_date`/`rationale`/`created_at`/`title`), and never silently overwrite collisions.
- Plan-loop reference matching is specified across exact path, basename, stem, and dated-slug suffix (token-bounded to avoid substring false positives); ambiguous matches block.
- Plan-loop step 1 split into 3 explicit branches (existing plan path / brainstorm path / raw problem statement) so the docs/ideas gate runs before `/workflows:plan` invocation in the brainstorm-path branch.
- Terminal-state reactivation rule: promoting a `completed` or `abandoned` idea requires explicit reactivation (status update with `reactivated_at` + rationale, OR a new follow-up idea file with `supersedes:` pointer).
- No-op when `docs/ideas/` is missing or empty in the consumer repo.

## 0.6.0 - 2026-04-05

- Added Negative Claims Protocol to all 5 research agents (two variants: external-facing and codebase-focused).
- Added adversarial verification step to `workflows:research`, `workflows:brainstorm`, and `workflows:deepen-plan` — challenges high-volatility negative claims with directed counter-queries.
- Added Domain Volatility Taxonomy to `external-frontier-researcher` (high/medium/low classification) with freshness requirements per level.
- Added volatility cross-reference to `best-practices-researcher`.
- Updated `brainstorm` volatility classification to reference canonical taxonomy from `external-frontier-researcher`.
- Adversarial verification includes: single-pass termination, origin-based guard, research=off guard, scope-preserving counter-queries, re-entry semantics for iterative workflows.

## 0.4.10 - 2026-03-09

- Switched plan, delta, and PR Codex gates to direct invocation by the current Claude agent instead of defaulting to dedicated Codex-only Claude sub-agents.
- Removed default reliance on `codex_gate_agent` and `codex_pr_review_agents` in the canonical workflow/config surface; legacy configs remain ignored for compatibility.
- Updated docs/examples so `teams=on` is no longer the default example path for planning and PR review.

## 0.4.9 - 2026-03-09

- Added `workflows:frontend-validate` as the phase-1 browser-validation gate using `codex exec` and Chrome DevTools MCP.
- Added a frontend validation artifact template under `docs/reviews/frontend/`.
- Updated `workflows:work` to auto-run frontend validation before PR review when a batch touches qualifying frontend/browser validation changes.
- Updated `workflows:pr-review` to fail closed for qualifying PRs when frontend validation evidence is missing, stale, or failed.
- Added policy defaults for frontend validation environment/mode/fallback and optional Playwright supplementation.

## 0.4.7 - 2026-03-09

- Renamed the canonical PR review evidence artifact from `pr-<number>-triple-review.md` to `pr-<number>-review.md`.
- Renamed the primary PR review template to `pr-review-gate-template.md` and retained the legacy template filename as a compatibility alias.
- Normalized remaining docs and workflow text from "triple review" to "PR review" while keeping `workflows:pr-triple-review` as a command alias.
- Fixed the repo-local copied `workflows:pr-review` template so it uses the canonical review artifact/remediation path and local-agent semantics instead of stale plugin-only references.
- Extended the canonical PR review evidence template to represent `stale` SHA state and required non-blocker triage fields.
- Fixed Codex reviewer/gate agent MCP-outage contracts to return `status: fail` consistently with their declared output schemas.
- Switched the repo-local `workflows:work` template to invoke canonical `workflows:pr-review` directly instead of leaning on the deprecated alias.
- Added explicit migration rules so legacy `pr-<number>-triple-review.md` evidence is renamed or superseded cleanly by `pr-<number>-review.md`.
- Tightened PR-type classification so workflow, agent, plugin, manifest, CI, and policy changes are always treated as guarded `code_pr` changes, not `docs_only`.
- Restored a complete usable body for the legacy `pr-triple-gate-template.md` filename so compatibility is structural, not just a pointer note.
- Normalized legacy Codex reviewer IDs during evidence migration so consensus counts stay stable across the underscore-to-colon reviewer ID rename.
- Added an explicit migration policy for legacy aggregate `teammate` / `ci` reviewer labels so migrated evidence preserves historical support without double-counting once fresh same-gate evidence exists.
- Extended legacy reviewer-ID migration coverage to old aggregate `codex` and `greptile` labels so historical PR evidence stays deterministic under the new gate contract.

## 0.4.6 - 2026-03-09

- Replaced the Greptile PR gate with two required parallel Codex xhigh PR reviewers:
  - `codex-pr-correctness-reviewer`
  - `codex-pr-edgecase-reviewer`
- Added `codex_pr_review_agents` policy/config input to `compound-engineering.local.md`.
- Added canonical `workflows:pr-review` command and retained `workflows:pr-triple-review` as a compatibility alias.
- Updated `workflows:work` to invoke the canonical PR review command and require both Codex reviewer gates before merge.
- Tightened `spec-flow-analyzer` with an explicit `not_applicable` path for backend/infra-only plans.
- Tightened `workflows:plan-loop` so analyzer `required_tests` must be mapped into plan verification strategy before approval.
- Tightened `workflows:compound` skip logic so non-trivial/reusable decisions are auditable instead of subjective.
- Updated templates, review policy, runbooks, and sequence diagram to reflect the dual-Codex PR gate model.

## 0.4.5 - 2026-03-08

- Added `workflows:compound` for high-signal learning capture with:
  - fail-closed noise gate (`created|updated|skipped` only when criteria are met)
  - de-dup against existing `docs/solutions/` artifacts
  - optional promotion to `docs/solutions/patterns/critical-patterns.md`
- Added `spec-flow-analyzer` and integrated it into `workflows:plan-loop` so each material plan revision is checked for flow permutations/edge cases (including refresh/rehydrate/resume).
- Hardened planning contract to require a **Flow Permutations & Edge Cases** section in approved plans.
- Hardened `workflows:pr-triple-review` to require refresh/rehydrate/resume integration/e2e coverage when frontend/session/state surfaces change.
- Updated `workflows:work` post-merge behavior:
  - keep existing post-merge CI/CD confirmation gate
  - auto-run post-merge compound capture after CI/CD is green
  - block progression on compound workflow failure
  - include explicit PM exception escape hatch for compound-capture failure (`compound_capture_exception` evidence)
  - require compound `created|updated|skipped` evidence in tracker before next slice/closeout
- Documented structured `workflows:compound` input contract used by `workflows:work`:
  - `<approved-plan-path> | pr=<pr-number-or-url> | merged_sha=<merged-sha>`
- Expanded `learnings-researcher` guidance and added template agent copies so planning/research can retrieve higher-signal historical patterns without replacing prior behavior.
- Updated templates/runbooks/policy docs to reflect new planning edge-case gate and automatic post-merge compound step.

## 0.4.4 - 2026-03-08

- Hardened Greptile gate semantics in `workflows:pr-triple-review`:
  - fail-closed for missing/stale Greptile on code PRs
  - explicit exception path requires reason + PM signoff
  - exception is SHA-scoped and invalidated on new head SHA
  - explicit `N/A` pass path when `greptile_required_for_code_prs: false`
  - explicit `N/A` pass path for `docs_only` PR classifications
- Clarified `workflows:work` behavior to auto-run triple review after each pushed SHA on active PRs.
- Added `allow_greptile_exception_for_code_prs` policy knob (default `false`) to template config.
- Updated templates/runbooks/review policy for:
  - SHA-scoped Greptile exception handling
  - manual triple-review examples with `approve_sha=<current-head-sha>`
  - explicit default for `greptile_required_for_code_prs`
  - explicit `workflows:work` recovery path for `greptile_missing_for_sha`
  - explicit output status taxonomy includes `PASS_WITH_EXCEPTION` and `STALE`
  - merge criteria in `workflows:work` accepts `PASS_WITH_EXCEPTION` when policy-gated exception is approved
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
