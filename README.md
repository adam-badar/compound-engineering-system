# Compound Engineering System

Reusable templates for bootstrapping projects with compound engineering practices: structured AI-assisted development, decision records, runbooks, and CI workflows.

This repository now also contains a private Claude plugin marketplace so shared workflow behavior can be updated in one place and reused across many repositories.

## What's Included

| Path | Purpose |
|------|---------|
| `templates/CLAUDE.md.base` | Base Claude Code instructions (branch workflow, planning, memory, circuit breakers) |
| `templates/.claude/settings.json` | Default Claude Code permissions and deny rules |
| `templates/.claude/settings.marketplace.example.json` | Example project settings for marketplace/plugin enforcement |
| `templates/.claude/agents/codex-gate-runner.md` | Dedicated agent for Codex xhigh external review gates |
| `templates/.claude/commands/workflows/plan-loop.md` | PM + reviewer iterative planning loop command |
| `templates/.claude/commands/workflows/work.md` | Execute approved plans with tracker + gate enforcement |
| `templates/.claude/commands/workflows/pr-triple-review.md` | Mandatory triple gate PR review command |
| `templates/.claude/commands/workflows/epic-delta-loop.md` | Nested re-planning loop for mid-epic scope changes |
| `templates/compound-engineering.local.example.md` | Review-agent and external-gate configuration template |
| `templates/docs/adr/` | Architecture Decision Record template |
| `templates/docs/runbooks/` | Operational runbook template |
| `templates/docs/runbooks/configure-private-marketplace.md` | Shared plugin rollout/update runbook |
| `templates/docs/solutions/` | Solution documentation structure |
| `templates/docs/process/` | Workflow definitions and sequence diagrams |
| `templates/docs/plans/` | Plan lifecycle + real-time execution tracker template |
| `templates/docs/knowledge/` | Plan index and knowledge base lifecycle guidance |
| `templates/docs/reviews/` | Review evidence templates and logging conventions |
| `templates/scripts/` | Worktree creation/removal helpers |
| `templates/.github/workflows/` | CI workflow templates |
| `.claude-plugin/marketplace.json` | Private Claude plugin marketplace manifest |
| `plugins/compound-engineering-core/` | Shared plugin with core workflows and agents |
| `scripts/validate-marketplace.sh` | Validates marketplace and plugin manifests |
| `scripts/release-plugin.sh` | Bumps plugin version in both manifests |

## Usage

### Option A: New project starter (recommended)

1. Click **Use this template** on this repository.
2. Clone your new repository locally.
3. Apply starter files into the repo root:

```bash
./bootstrap/apply-template.sh .
```

Template command files are still copied for backwards compatibility. Use plugin-prefixed commands in day-to-day work so shared updates come from the marketplace plugin.

4. Add marketplace once on your machine:

```bash
claude plugin marketplace add https://github.com/adam-badar/compound-engineering-system.git
```

5. Install shared plugin once (works across all repos on this machine):

```bash
claude plugin install compound-engineering-core@compound-engineering-marketplace --scope user
```

6. Rename `CLAUDE.md.base` to `CLAUDE.md` and customize project-specific sections.
7. Copy `compound-engineering.local.example.md` to `compound-engineering.local.md` and customize reviewers.
8. Run `claude mcp add -s user codex-xhigh -- codex mcp-server -c 'model=\"gpt-5.3-codex\"' -c 'model_reasoning_effort=\"xhigh\"'` once per machine.
9. Verify plugin is installed:

```bash
claude plugin list
# should include: compound-engineering-core@compound-engineering-marketplace
```

10. Start planning with plugin-prefixed command:

```text
/compound-engineering-core:workflows:plan-loop "Build an app that unifies Fathom/Aircall/HubSpot/Gmail timeline + suggestions teams=on"
```

11. Confirm planning artifacts were created:
   - `docs/plans/*-plan.md`
   - `docs/reviews/plans/*-codex-extra-high.md`
12. Initialize execution tracker:

```bash
scripts/init-plan-tracker.sh docs/plans/<your-plan>-plan.md
```

13. Execute implementation from the approved plan:

```text
/compound-engineering-core:workflows:work docs/plans/<your-plan>-plan.md
```

14. If scope changes mid-epic:

```text
/compound-engineering-core:workflows:epic-delta-loop "docs/plans/<your-plan>-plan.md | <delta request>"
```

15. Before merge:

```text
/compound-engineering-core:workflows:pr-triple-review "<pr-number> approve_sha=<current-head-sha> teams=on"
```

16. Triple review is PM-authorized per SHA. Do not auto-invoke it from background/sub-agent work.
17. Merge only when triple gate status is `PASS` for the current PR head SHA (including the test/CI gate for code PRs).
18. Optional: run `/compound-engineering-setup` for project-specific setup checks.

### Option B: Existing project bootstrap

```bash
./bootstrap/apply-template.sh /path/to/your-project
```

This copies templates into the target project without overwriting existing files.

### Option C: Enable across existing repos (lowest ongoing workload)

1. Add the marketplace once on your machine.
2. Install `compound-engineering-core` with `--scope user` once.
3. Keep each repo's local files (`CLAUDE.md`, `compound-engineering.local.md`, docs) project-specific.
4. Update shared behavior by releasing a new plugin version from this repository.

The plugin normalizes unqualified agent IDs from `compound-engineering.local.md` to `compound-engineering-core:<agent-id>`, so existing repo configs can migrate gradually.

### Manual

Copy individual templates as needed. Edit placeholder sections marked with `<!-- PROJECT-SPECIFIC -->` or `# TODO:` comments.

## Conventions

- **Branch workflow**: `develop` for work, `main` for production. PRs only.
- **Planning**: Think first, plan, verify, then execute.
- **Memory**: `.claude/memory.md` in each repo tracks learnings.
- **ADRs**: Numbered, immutable once accepted. Supersede, don't edit.

## Notes

- This repository supports both **starter** and **bootstrap toolkit** workflows.
- The planning/review/compound process diagrams remain valid in both modes once bootstrap is complete.
- The planning loop is explicit: planning and plan-review agents iterate with PM feedback until both PM and reviewers approve.
- For full startup verification steps, use `templates/docs/runbooks/new-project-bootstrap-smoke-test.md`.
- For private marketplace setup and update flow, use `templates/docs/runbooks/configure-private-marketplace.md`.

## Maintaining Shared Workflows

Use this repo as the single source of truth:

1. Edit plugin files under `plugins/compound-engineering-core/`.
2. Bump version with `scripts/release-plugin.sh <new-version>`.
3. Validate with `scripts/validate-marketplace.sh`.
4. Merge to `main`.
5. On machines using the plugin, run:

```bash
claude plugin marketplace update compound-engineering-marketplace
claude plugin update compound-engineering-core@compound-engineering-marketplace
```
