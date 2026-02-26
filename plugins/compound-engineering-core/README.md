# Compound Engineering Core Plugin

Private plugin for shared compound engineering workflows.

## Includes

- Workflow commands:
  - `compound-engineering-core:workflows:brainstorm`
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
- External Codex gate expects a configured `codex-xhigh` MCP server.
- Planning enforces an Epic PR Ladder with per-PR size/test expectations.
- PR triple review enforces teammate + Codex + Greptile + test/CI gates for code PRs.
- PR triple review requires explicit PM authorization per SHA via `approve_sha=<current-head-sha>`.
- Non-blockers must be triaged (`implement_now|defer|reject`) and cannot be silently ignored.
