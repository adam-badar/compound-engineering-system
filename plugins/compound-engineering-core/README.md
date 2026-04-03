# Compound Engineering Core Plugin

Private plugin for shared compound engineering workflows.

## Includes

- Workflow commands:
  - `compound-engineering-core:workflows:brainstorm`
  - `compound-engineering-core:workflows:research`
  - `compound-engineering-core:workflows:deepen-plan`
  - `compound-engineering-core:workflows:plan`
  - `compound-engineering-core:workflows:plan-loop`
  - `compound-engineering-core:workflows:debug`
  - `compound-engineering-core:workflows:explain`
  - `compound-engineering-core:workflows:frontend-validate`
  - `compound-engineering-core:workflows:work`
  - `compound-engineering-core:workflows:compound`
  - `compound-engineering-core:workflows:epic-delta-loop`
  - `compound-engineering-core:workflows:pr-review`
- Review and research agents for teammate/research workflows
- Legacy compatibility Codex agent shims for older repos

## Notes

- Use plugin-prefixed command names to guarantee you are invoking the shared plugin implementation.
- Agent teams are opt-in per command run via `teams=on`.
- `brainstorm`, `debug`, and `explain` provide non-coding workflows for discovery, diagnosis, and decision traceability.
- `brainstorm` supports freshness-aware research controls: `research=auto|on|off`, `research_depth=quick|standard|deep`, and `as_of=YYYY-MM-DD`.
- `research` provides deep-research style investigation with iterative PM Q&A loops and dated evidence capture.
- `deepen-plan` upgrades an existing plan through targeted research passes and confidence-tracked PM feedback loops.
- External Codex gate expects a configured `codex-xhigh` MCP server.
- Codex plan and PR passes are invoked directly by the current Claude agent; dedicated Codex-only Claude sub-agents are no longer the default path.
- Frontend browser validation uses gstack headless Chromium. Install gstack skill at `~/.claude/skills/gstack/` and run `./setup`.
- Planning enforces an Epic PR Ladder with per-PR size/test expectations.
- PR review enforces teammate + Codex correctness + Codex edge-case + test/CI gates for code PRs.
- `frontend-validate` provides the browser-validation gate using gstack persistent headless Chromium.
- `workflows:work` auto-runs `frontend-validate` when a batch touches qualifying frontend/browser validation changes.
- `workflows:pr-review` fails closed for qualifying PRs when current-SHA frontend validation evidence is missing, stale, or failed.
- The two Codex PR passes are both required on the current SHA and are run directly by the current Claude agent by default.
- PR review requires SHA authorization via `approve_sha=<current-head-sha>` (auto-supplied when invoked from `workflows:work`).
- `workflows:work` auto-runs/re-runs PR review after each pushed SHA on the active PR.
- `workflows:work` enforces a post-merge CI/CD confirmation gate on target-branch SHA before continuing to the next slice/closeout.
- `workflows:work` auto-runs post-merge `workflows:compound` after CI/CD is green, and records created/updated/skipped evidence in the execution tracker.
- Non-blockers must be triaged (`implement_now|defer|reject`) and cannot be silently ignored.
- Default triage artifact is existing gate evidence + execution tracker (no extra todo-file system required).
- Multi-reviewer consensus non-blockers are escalation-candidates and default to promotion unless counterevidence + PM signoff are captured.

## Meta-governance

Changes to this plugin (workflow commands, agent definitions, review policies) are themselves subject to the same compound engineering workflow:

1. **Branch + PR**: All changes must go through a feature branch and pull request in the plugin repository, never committed directly.
2. **PR review**: Plugin changes are classified as `code_pr` (they affect execution, review, and trust boundaries) and must pass the same teammate + Codex review gates.
3. **Compound capture**: Non-trivial changes should produce a `docs/solutions/` entry in the consuming repository if the change was motivated by a process failure.

The methodology must enforce itself. If an agent skips these gates for "meta" changes, that is a process violation equivalent to skipping them for application code.
