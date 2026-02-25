# Compound Engineering Core Plugin

Private plugin for shared compound engineering workflows.

## Includes

- Workflow commands:
  - `compound-engineering-core:workflows:plan`
  - `compound-engineering-core:workflows:plan-loop`
  - `compound-engineering-core:workflows:work`
  - `compound-engineering-core:workflows:epic-delta-loop`
  - `compound-engineering-core:workflows:pr-triple-review`
- Review and research agents for planning and PR gates
- Codex gate runner agent

## Notes

- Use plugin-prefixed command names to guarantee you are invoking the shared plugin implementation.
- Agent teams are opt-in per command run via `teams=on`.
- External Codex gate expects a configured `codex-xhigh` MCP server.
- Planning enforces an Epic PR Ladder with per-PR size/test expectations.
- PR triple review enforces teammate + Codex + Greptile + test/CI gates for code PRs.
