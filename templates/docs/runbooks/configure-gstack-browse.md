# Configure GStack Browse for Frontend Validation

Use this runbook to enable GStack browse (Playwright CLI) for `workflows:frontend-validate`.

## Purpose

`workflows:frontend-validate` uses GStack's `browse` binary for headless browser testing. GStack provides a persistent Chromium daemon with ~100ms per-command latency, zero token overhead, and per-workspace isolation.

This replaces the previous Chrome DevTools MCP approach, which had multi-session profile lock crashes, 2-5s per-command latency, and ~2000 tokens of MCP protocol overhead per call.

## Prerequisites

- [Bun](https://bun.sh) runtime installed: `curl -fsSL https://bun.sh/install | bash`
- Git (for cloning GStack)

## Installation

### Step 1: Clone GStack

```bash
git clone https://github.com/garrytan/gstack.git ~/Documents/GitHub/gstack
```

### Step 2: Install dependencies and build

```bash
cd ~/Documents/GitHub/gstack
bun install
npx playwright install chromium
bun run build
```

### Step 3: Create symlink for Claude Code

```bash
ln -s ~/Documents/GitHub/gstack ~/.claude/skills/gstack
```

### Step 4: Configure compound-engineering.local.md

In your project's `compound-engineering.local.md`, set:

```yaml
frontend_validation_mode: gstack-browse
frontend_staging_url: "https://your-staging-url.com"
```

## Verification

```bash
# Verify binary exists
~/.claude/skills/gstack/browse/dist/browse --help

# Verify it can navigate
export PATH="$HOME/.bun/bin:$PATH"
~/.claude/skills/gstack/browse/dist/browse goto https://your-app.com

# Verify accessibility tree
~/.claude/skills/gstack/browse/dist/browse snapshot -i
```

## Usage in Claude Code

The `browse` binary is invoked via Bash tool calls. No MCP server needed.

```bash
B=~/.claude/skills/gstack/browse/dist/browse
$B goto https://app.com          # navigate (200ms)
$B snapshot -i                    # accessibility tree (88ms)
$B text                           # page content (35ms)
$B console                        # JS errors (35ms)
$B network                        # network requests
$B screenshot /tmp/evidence.png   # visual evidence (144ms)
$B click @e5                      # interact with elements
$B fill @e3 "value"               # fill form fields
```

## Migration from Chrome DevTools MCP

If you were previously using Chrome DevTools MCP:

1. Remove from Codex config: delete `[mcp_servers.chrome-devtools]` from `~/.codex/config.toml`
2. Remove from Claude permissions: remove `mcp__chrome-devtools__*` from `.claude/settings.local.json` allow lists
3. Update `compound-engineering.local.md`: set `frontend_validation_mode: gstack-browse`

## Notes

- The GStack daemon starts automatically on first use (~3s) and persists for 30 minutes idle
- Each git project gets its own Chromium process and port (no conflicts)
- State (cookies, sessions) persists between commands within a project
- Frontend validation is fail-closed: if GStack binary is not found, the gate fails
