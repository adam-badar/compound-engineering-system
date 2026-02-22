# Runbook: Configure Codex XHigh MCP (Global)

## Purpose

Register Codex as a global Claude MCP server so all projects can run the external Codex review gate with consistent `xhigh` reasoning.

## Prerequisites

- [ ] `codex` CLI installed and authenticated
- [ ] `claude` CLI installed
- [ ] access to shell where both CLIs are available

## Steps

1. **Add user-scope MCP server**

```bash
claude mcp add -s user codex-xhigh -- codex mcp-server -c 'model="gpt-5.3-codex"' -c 'model_reasoning_effort="xhigh"'
```

Expected output includes: `Added stdio MCP server codex-xhigh`.

2. **Verify server details**

```bash
claude mcp get codex-xhigh
```

Expected output:
- scope is `User config`
- command is `codex mcp-server ...`
- status is `Connected`

3. **Verify server appears in MCP list**

```bash
claude mcp list
```

Expected output includes `codex-xhigh` with `Connected` status.

## Rollback

```bash
claude mcp remove codex-xhigh -s user
```

## Verification

- [ ] `claude mcp get codex-xhigh` shows connected
- [ ] planning/PR workflows can reference `codex-xhigh`
- [ ] no per-project MCP setup required for Codex gate

