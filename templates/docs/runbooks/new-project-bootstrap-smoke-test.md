# Runbook: New Project Bootstrap + Smoke Test

## Purpose

Bootstrap a new or existing repository with the compound engineering system and validate that the planning, execution, and review workflows are available.

## Prerequisites

- [ ] `codex` CLI installed and authenticated
- [ ] `claude` CLI installed
- [ ] `codex-xhigh` MCP configured (see `configure-codex-xhigh-mcp.md`)
- [ ] repository cloned locally

## Steps

1. **Create or clone target repository**

Use either:
- new project created from this template repository
- existing project where templates will be applied

2. **Apply templates**

```bash
/path/to/compound-engineering-system/bootstrap/apply-template.sh .
mv CLAUDE.md.base CLAUDE.md
cp compound-engineering.local.example.md compound-engineering.local.md
```

3. **Verify workflow commands were copied**

```bash
ls .claude/commands/workflows
```

Expected files:
- `plan-loop.md`
- `work.md`
- `pr-triple-review.md`
- `epic-delta-loop.md`

4. **Run planning loop**

```text
/workflows:plan-loop "Build an app that unifies Fathom/Aircall/HubSpot/Gmail timeline + suggestions"
```

5. **Verify planning artifacts**

Expected artifacts:
- `docs/plans/*-plan.md`
- `docs/reviews/plans/*-codex-extra-high.md`

6. **Initialize execution tracker**

```bash
scripts/init-plan-tracker.sh docs/plans/<your-plan>-plan.md
```

Expected artifact:
- `docs/plans/<your-plan>-execution.md`

7. **Run implementation loop**

```text
/workflows:work docs/plans/<your-plan>-plan.md
```

8. **Handle material scope shifts**

```text
/workflows:epic-delta-loop "docs/plans/<your-plan>-plan.md | <delta request>"
```

9. **Run pre-merge triple gate**

```text
/workflows:pr-triple-review "<pr-number>"
```

Merge policy:
- merge only when status is `PASS`
- gate evidence must match current PR head SHA

## Rollback

If bootstrap files were applied to the wrong target repo:
1. Revert the committed bootstrap files from that repo branch.
2. Re-run `apply-template.sh` against the correct repository.

## Verification

Confirm success by checking all below:
- [ ] workflow command files exist under `.claude/commands/workflows/`
- [ ] plan + Codex plan review artifacts are generated
- [ ] execution tracker is generated from template
- [ ] PR triple review gate can run and produce evidence docs
