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
  - `compound-engineering-core:workflows:work`
  - `compound-engineering-core:workflows:epic-delta-loop`
  - `compound-engineering-core:workflows:pr-triple-review`
- Review and research agents for planning and PR gates
- Codex gate runner agent

## Notes

- Use plugin-prefixed command names to guarantee you are invoking the shared plugin implementation.
- Agent teams are opt-in per command run via `teams=on`.
- `brainstorm`, `debug`, and `explain` provide non-coding workflows for discovery, diagnosis, and decision traceability.
- `brainstorm` supports freshness-aware research controls: `research=auto|on|off`, `research_depth=quick|standard|deep`, and `as_of=YYYY-MM-DD`.
- `research` provides deep-research style investigation with iterative PM Q&A loops and dated evidence capture.
- `deepen-plan` upgrades an existing plan through targeted research passes and confidence-tracked PM feedback loops.
- External Codex gate expects a configured `codex-xhigh` MCP server.
- Planning enforces an Epic PR Ladder with per-PR size/test expectations.
- PR triple review enforces teammate + Codex + Greptile + test/CI gates for code PRs.
- Greptile is fail-closed for code PRs by default; exception requires explicit reason + PM signoff and is SHA-scoped.
- If `greptile_required_for_code_prs: false`, the Greptile gate is explicitly `N/A` by policy.
- PR triple review requires SHA authorization via `approve_sha=<current-head-sha>` (auto-supplied when invoked from `workflows:work`).
- `workflows:work` auto-runs/re-runs triple review after each pushed SHA on the active PR.
- `workflows:work` enforces a post-merge CI/CD confirmation gate on target-branch SHA before continuing to the next slice/closeout.
- Non-blockers must be triaged (`implement_now|defer|reject`) and cannot be silently ignored.
- Default triage artifact is existing gate evidence + execution tracker (no extra todo-file system required).
- Multi-reviewer consensus non-blockers are escalation-candidates and default to promotion unless counterevidence + PM signoff are captured.
