# Configure Codex Browser MCP

Use this runbook to enable `codex exec` browser validation for `workflows:frontend-validate`.

## Purpose

`workflows:frontend-validate` uses `codex exec` plus the `chrome-devtools` MCP server. This MCP server is configured in Codex, not Claude.

## Option A: Configure with Codex CLI

```bash
codex mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest
```

Verify:

```bash
codex mcp list
```

Expected output includes `chrome-devtools`.

## Option B: Configure in `~/.codex/config.toml`

Add:

```toml
[mcp_servers.chrome-devtools]
command = "npx"
args = ["-y", "chrome-devtools-mcp@latest"]
```

Then restart Codex/Claude sessions that will invoke `codex exec`.

## Verification

1. Confirm `codex mcp list` includes `chrome-devtools`.
2. Confirm Chrome is installed on the machine.
3. For local app validation, ensure the target app URL is reachable.
4. For staging validation, ensure the configured staging URL is reachable.

## Notes

- This is separate from the Claude-side `codex-xhigh` MCP server used for planning/PR review gates.
- Frontend validation is fail-closed for qualifying PRs when browser MCP is required but unavailable.
