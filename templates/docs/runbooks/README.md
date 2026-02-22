# Runbooks

Operational runbooks for common tasks and incident response. Each runbook should be self-contained and executable by any team member.

## Template

```markdown
# Runbook: {Title}

## Purpose
What does this runbook accomplish? When should it be used?

## Prerequisites
- [ ] Access to {service/tool}
- [ ] Environment variable `X` is set
- [ ] Familiarity with {concept}

## Steps

1. **Step name**
   ```bash
   command here
   ```
   Expected output: {description}

2. **Step name**
   ```bash
   command here
   ```
   Expected output: {description}

## Rollback

If something goes wrong:
1. {Rollback step}
2. {Rollback step}

## Verification

Confirm success by:
- [ ] {Check 1}
- [ ] {Check 2}
```

## Conventions

- Name files descriptively: `deploy-production.md`, `rotate-api-keys.md`, `restore-database.md`
- Include rollback steps for every destructive operation.
- Test runbooks periodically -- stale runbooks are worse than no runbooks.
- Keep one global environment runbook for shared tooling (example: `configure-codex-xhigh-mcp.md`).
- Keep one bootstrap validation runbook for new projects (example: `new-project-bootstrap-smoke-test.md`).
