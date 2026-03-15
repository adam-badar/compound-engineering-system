---
name: workflows:frontend-validate
description: Validate frontend/browser behavior for qualifying PRs using gstack headless browser
argument-hint: "[PR number, PR url, branch name, or current]"
---

# Frontend Validate (Browser + State + Refresh)

Use this command when a PR touches frontend, session, auth, routing, or client-state behavior.

This command is the browser-validation gate for Compound Engineering.
It uses gstack's persistent headless Chromium for browser inspection and writes auditable evidence.

## Inputs

<frontend_validation_input> #$ARGUMENTS </frontend_validation_input>

If empty, ask:
"Which PR or branch should I validate?"

Optional runtime flags in arguments:

- `sha=<sha>` to pin validation to a specific revision (auto-supplied when invoked from `work`)
- `env=auto|local|staging` (default `auto`)
- `target_url=<url>` to force a specific URL when auto-routing is insufficient

## Policy defaults (override in `compound-engineering.local.md`)

- `require_frontend_validation_for_frontend_changes` (default: `true`)
- `frontend_validation_mode` (default: `gstack`)
- `frontend_local_url` (default: `http://localhost:3000`)
- `frontend_staging_url` (default: `""`)
- `frontend_validation_use_staging_fallback` (default: `false`)
- `frontend_local_revision_check_command` (default: `""`)
- `frontend_staging_revision_check_command` (default: `""`)

## Workflow

### 1. Resolve validation context

1. Resolve PR number/branch/diff/touched files/current head SHA.
2. If `sha=<sha>` is supplied and does not match current head SHA, stop with `status: STALE`.
3. If `require_frontend_validation_for_frontend_changes: false`, write an `N/A` artifact with rationale (`policy disabled`) and return `status: N/A`.
4. Determine whether this change qualifies for browser validation.

Treat browser validation as required when any of the following changed:

- frontend pages/routes/components/layouts/styles
- client-side JavaScript/TypeScript state
- auth/session/token lifecycle
- router/navigation behavior
- local storage/session storage/cache hydration
- multi-step forms or user flows
- backend/API behavior that materially changes rendered UI or state recovery

If the change does not qualify:

- write an `N/A` artifact with rationale
- return `status: N/A`

### 2. Preflight environment checks

1. Locate gstack browse binary:
   ```bash
   _ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
   B=""
   [ -n "$_ROOT" ] && [ -x "$_ROOT/.claude/skills/gstack/browse/dist/browse" ] && B="$_ROOT/.claude/skills/gstack/browse/dist/browse"
   [ -z "$B" ] && B=~/.claude/skills/gstack/browse/dist/browse
   ```
   If not found, fail with `NEEDS_SETUP` and instruct: run `cd <skill-dir> && ./setup`.

2. Verify gstack is healthy: `$B status`

3. Resolve target environment:
   - `env=local`: require `frontend_local_url`
   - `env=staging`: require `frontend_staging_url`
   - `env=auto`: prefer reachable `frontend_local_url`; if unreachable and fallback is enabled, use `frontend_staging_url`

4. Establish target revision proof before browser validation:
   - for `env=local`, prove the reachable target is serving code from the current worktree/reviewed SHA. Use `frontend_local_revision_check_command` when configured; otherwise inspect launch provenance/process context. If proof cannot be established, fail closed.
   - for `env=staging`, require `frontend_staging_revision_check_command` that proves the target URL is serving the reviewed SHA. If no such proof mechanism exists, fail closed instead of accepting staging as a current-SHA substitute.

5. Fail closed if no reachable browser target exists.

### 2.5 Auth setup

gstack's browser persists cookies and sessions across calls. If the target requires authentication:

1. Check if already authenticated: `$B goto <target_url>` then `$B url` — if not redirected to a login page, auth is valid from a previous session.

2. If redirected to login:
   - **Email/password login**: Use `$B snapshot -i` to find form fields, then `$B fill` + `$B click` to log in.
   - **Cookie import**: Use `$B cookie-import-browser <browser> --domain <domain>` to import from an existing browser session.
   - **Manual credentials**: If `frontend_test_email` and `frontend_test_password` are configured in `compound-engineering.local.md`, use those.
   - **Google OAuth / SSO**: Cannot be automated headlessly. Require email/password test account as fallback.

3. After login, verify: `$B url` should show the app, not the login page.

4. Auth persists for the gstack session lifetime (30 min idle timeout). Subsequent validation runs within the same session do not need to re-authenticate.

### 3. Select target flows

Choose 1-3 highest-risk URLs/flows from:

- plan acceptance criteria
- PR summary and touched files
- route/controller/page/component structure
- auth/session/state implications

Selection rules:

1. Always include the primary changed user flow.
2. Include a refresh/rehydrate/resume path when stateful UX is touched.
3. Include retry/error or session-expiry path when auth/session is touched.
4. If route inference is weak and `target_url=<url>` was supplied, use it.
5. Ask a focused question only if no meaningful target URL can be inferred from repo/PR context.

### 4. Run gstack browser validation

For each target flow, execute gstack commands directly via Bash:

```bash
# Navigate
$B goto "<target_url>"

# Capture baseline
$B screenshot /tmp/frontend-validate-<flow>.png
$B snapshot -i    # interactive elements with @e refs

# Exercise the changed flow
$B click @eN      # interact with changed elements
$B fill @eN "value"
$B snapshot -D     # diff shows what changed

# Inspect for errors
$B console --errors    # JS errors/warnings
$B network             # failed requests

# Test refresh/rehydrate
$B reload
$B snapshot -D         # verify state survives refresh
$B screenshot /tmp/frontend-validate-<flow>-refresh.png

# Verify session/auth continuity (when relevant)
$B url                 # still authenticated?

# Element assertions
$B is visible "<selector>"
$B is enabled "<selector>"
```

Collect results into structured findings:

- `screenshots`: paths to captured screenshots
- `console_findings`: errors/warnings from `$B console --errors`
- `network_findings`: failed requests from `$B network`
- `refresh_resume_result`: did state survive `$B reload`?
- `session_result`: did auth persist across navigation?
- `blocking_findings`: correctness-breaking issues
- `non_blocking_findings`: warnings, cosmetic issues

Before returning `PASS`, re-resolve the current PR/branch head SHA. If it no longer matches the requested/current validation SHA, write a `STALE` artifact instead of `PASS` and instruct the caller to rerun on the new SHA.
If target revision proof is missing, mismatched, or cannot establish that the tested target is serving the reviewed SHA/current worktree, write `FAIL` instead of `PASS`.

### 5. Write validation artifact

Write to:

- `docs/reviews/frontend/pr-<number>-frontend-validate.md` for PR-based runs
- `docs/reviews/frontend/YYYY-MM-DD-<branch>-<short-sha>-frontend-validate.md` otherwise

If a project overrides `frontend_validation_command`, the custom validator must still write the canonical PR artifact path above for PR-based runs so `pr-review` can consume the result.

Minimum sections:

- Metadata
- Reviewed SHA
- Environment and base URL
- Target revision proof
- Touched files summary
- Target URLs/flows
- Screenshots
- Console findings
- Network findings
- Refresh/rehydrate/resume result
- Session/auth result
- Blocking findings
- Non-blocking findings
- Final status
- Remediation / rerun instruction

### 6. Gate semantics

Frontend validation is `PASS` only when:

- artifact exists for current SHA
- gstack browser validation completed successfully
- no open browser-validation blockers remain
- refresh/rehydrate/resume behavior is validated for qualifying stateful UX
- for auth/session/token changes, session/auth continuity is validated and passes
- console/network findings do not reveal open correctness-breaking issues
- target revision proof matches the reviewed SHA or otherwise proves the local target came from the current worktree/reviewed revision

Otherwise:

- `FAIL` for open blockers or missing required validation
- `STALE` if artifact SHA does not match current head
- `N/A` only when the change truly does not qualify or project policy explicitly disables this gate

## Output

Return:

- status (`PASS|FAIL|STALE|N/A`)
- artifact path
- target URLs tested
- blockers (if any)
- next action
