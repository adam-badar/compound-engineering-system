# Runbook: New Project Bootstrap + Smoke Test

## Purpose

Bootstrap a new or existing repository with the compound engineering system and validate that the planning, execution, and review workflows are available.

## Prerequisites

- [ ] `codex` CLI installed and authenticated
- [ ] `claude` CLI installed
- [ ] `codex-xhigh` MCP configured (see `configure-codex-xhigh-mcp.md`)
- [ ] private marketplace configured (see `configure-private-marketplace.md`)
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

3. **Install core plugin once on your machine (if not already installed)**

```bash
claude plugin marketplace add https://github.com/adam-badar/compound-engineering-system.git
claude plugin install compound-engineering-core@compound-engineering-marketplace --scope user
```

4. **Verify workflow commands are available**

```bash
claude plugin list
```

Expected plugin:
- `compound-engineering-core@compound-engineering-marketplace`

5. **Run planning loop**

Optional discovery step when requirements are unclear:

```text
/compound-engineering-core:workflows:brainstorm "Build an app that unifies Fathom/Aircall/HubSpot/Gmail timeline + suggestions research=on research_depth=standard"
```

Optional deep research step before planning:

```text
/compound-engineering-core:workflows:research "Build an app that unifies Fathom/Aircall/HubSpot/Gmail timeline + suggestions depth=deep scope=hybrid"
```

Then run planning loop:

```text
/compound-engineering-core:workflows:plan-loop "Build an app that unifies Fathom/Aircall/HubSpot/Gmail timeline + suggestions teams=on"
```

Optional plan-hardening step:

```text
/compound-engineering-core:workflows:deepen-plan "docs/plans/<your-plan>-plan.md depth=deep"
```

6. **Verify planning artifacts**

Expected artifacts:
- `docs/plans/*-plan.md`
- `docs/reviews/plans/*-codex-extra-high.md`

7. **Initialize execution tracker**

```bash
scripts/init-plan-tracker.sh docs/plans/<your-plan>-plan.md
```

Expected artifact:
- `docs/plans/<your-plan>-execution.md`

8. **Run implementation loop**

```text
/compound-engineering-core:workflows:work docs/plans/<your-plan>-plan.md
```

9. **Handle material scope shifts**

```text
/compound-engineering-core:workflows:epic-delta-loop "docs/plans/<your-plan>-plan.md | <delta request>"
```

10. **Manual triple-gate rerun (ad-hoc)**

```text
/compound-engineering-core:workflows:pr-triple-review "<pr-number> approve_sha=<current-head-sha> teams=on"
```

Merge policy:
- merge only when status is `PASS`
- gate evidence must match current PR head SHA
- `workflows:work` is the primary path and should auto-run triple review after each pushed SHA
- non-blockers must be triaged (`implement_now|defer|reject`) with rationale

11. **Verify diagnosis/explanation workflows are available**

```text
/compound-engineering-core:workflows:debug "<failing behavior>"
/compound-engineering-core:workflows:explain "<question about behavior/decision>"
```

## Rollback

If bootstrap files were applied to the wrong target repo:
1. Revert the committed bootstrap files from that repo branch.
2. Re-run `apply-template.sh` against the correct repository.

## Verification

Confirm success by checking all below:
- [ ] `compound-engineering-core@compound-engineering-marketplace` is installed
- [ ] plan + Codex plan review artifacts are generated
- [ ] execution tracker is generated from template
- [ ] PR triple review gate can run and produce evidence docs
