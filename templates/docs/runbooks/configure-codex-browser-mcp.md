# Configure gstack for Browser Validation

Use this runbook to enable browser validation for `workflows:frontend-validate`.

## Overview

`workflows:frontend-validate` uses gstack's persistent headless Chromium. The browser persists cookies, sessions, and state across calls — login once and subsequent validations reuse the session.

## Setup

1. Verify gstack skill is installed:

```bash
ls ~/.claude/skills/gstack/browse/dist/browse
```

2. If not built, run setup:

```bash
cd ~/.claude/skills/gstack && ./setup
```

3. Verify browser is healthy:

```bash
B=~/.claude/skills/gstack/browse/dist/browse
$B status
```

Expected output: `Status: healthy`

## Auth Setup (one-time per session)

For apps behind authentication:

```bash
$B goto "https://your-app.com"
$B snapshot -i
$B fill @e3 "test@example.com"
$B fill @e5 "password"
$B click @e6
$B url  # should show the app, not login
```

For cookie-based auth:
```bash
$B cookie-import-browser chrome --domain .your-domain.com
```

Session persists for 30 minutes of idle time.

## Troubleshooting

- **`NEEDS_SETUP`**: Run `cd ~/.claude/skills/gstack && ./setup`
- **`bun` not installed**: `curl -fsSL https://bun.sh/install | bash`
- **Keychain permission**: Approve macOS Keychain access for cookie import
- **Google OAuth**: Cannot automate headlessly. Create an email/password test account.

## Notes

- This replaces the previous `codex exec` + `chrome-devtools` MCP approach.
- gstack is a Claude Code skill, not a Codex MCP server.
- Frontend validation is fail-closed for qualifying PRs when gstack is unavailable.
