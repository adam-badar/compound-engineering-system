# Configure Private Plugin Marketplace

Use this runbook to enable shared compound-engineering workflows across multiple repositories with one centrally maintained plugin.

## 1) Add marketplace once (machine level)

```bash
claude plugin marketplace add https://github.com/adam-badar/compound-engineering-system.git
```

## 2) Install plugin once for all repos on this machine

```bash
claude plugin install compound-engineering-core@compound-engineering-marketplace --scope user
```

This is the lowest-maintenance setup when one person works across many repos.

No immediate rewrite of existing `compound-engineering.local.md` agent IDs is required. The plugin normalizes unqualified IDs (for example `security-sentinel`) to `compound-engineering-core:security-sentinel` at runtime.

## 3) Optional: enforce per-repo/team

Inside a project repo:

```bash
claude plugin install compound-engineering-core@compound-engineering-marketplace --scope project
```

Then commit `.claude/settings.json` so teammates inherit it.

## 4) Verify

```bash
claude plugin list
claude plugin marketplace list
```

## 5) Use plugin-prefixed workflow commands

Use explicit plugin prefix so execution always comes from the shared plugin (not stale repo-local command copies):

```text
/compound-engineering-core:workflows:plan-loop "problem statement"
/compound-engineering-core:workflows:brainstorm "problem framing prompt research=on research_depth=standard"
/compound-engineering-core:workflows:research "problem framing prompt depth=deep scope=hybrid"
/compound-engineering-core:workflows:deepen-plan "docs/plans/<plan>-plan.md depth=deep"
/compound-engineering-core:workflows:debug "failing behavior or error trace"
/compound-engineering-core:workflows:explain "why is this behaving this way?"
/compound-engineering-core:workflows:work docs/plans/<plan>-plan.md
/compound-engineering-core:workflows:epic-delta-loop "docs/plans/<plan>-plan.md | <delta>"
/compound-engineering-core:workflows:pr-review "<pr-number> approve_sha=<current-head-sha>"
```

`/compound-engineering-core:workflows:work` auto-invokes PR review after each pushed SHA and auto-runs post-merge compound capture after CI/CD is green.
Use direct `/workflows:pr-review` mainly for ad-hoc reruns or spot checks.

## 6) Update workflow after new plugin release

```bash
claude plugin marketplace update compound-engineering-marketplace
claude plugin update compound-engineering-core@compound-engineering-marketplace
```

If plugin auto-update is enabled, update may happen at startup.
