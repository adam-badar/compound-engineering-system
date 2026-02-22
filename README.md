# Compound Engineering System

Reusable templates for bootstrapping projects with compound engineering practices: structured AI-assisted development, decision records, runbooks, and CI workflows.

## What's Included

| Path | Purpose |
|------|---------|
| `templates/CLAUDE.md.base` | Base Claude Code instructions (branch workflow, planning, memory, circuit breakers) |
| `templates/.claude/settings.json` | Default Claude Code permissions and deny rules |
| `templates/.claude/agents/codex-gate-runner.md` | Dedicated agent for Codex xhigh external review gates |
| `templates/.claude/commands/workflows/plan-loop.md` | PM + reviewer iterative planning loop command |
| `templates/.claude/commands/workflows/work.md` | Execute approved plans with tracker + gate enforcement |
| `templates/.claude/commands/workflows/pr-triple-review.md` | Mandatory triple gate PR review command |
| `templates/.claude/commands/workflows/epic-delta-loop.md` | Nested re-planning loop for mid-epic scope changes |
| `templates/compound-engineering.local.example.md` | Review-agent and external-gate configuration template |
| `templates/docs/adr/` | Architecture Decision Record template |
| `templates/docs/runbooks/` | Operational runbook template |
| `templates/docs/solutions/` | Solution documentation structure |
| `templates/docs/process/` | Workflow definitions and sequence diagrams |
| `templates/docs/plans/` | Plan lifecycle + real-time execution tracker template |
| `templates/docs/knowledge/` | Plan index and knowledge base lifecycle guidance |
| `templates/docs/reviews/` | Review evidence templates and logging conventions |
| `templates/scripts/` | Worktree creation/removal helpers |
| `templates/.github/workflows/` | CI workflow templates |

## Usage

### Option A: New project starter (recommended)

1. Click **Use this template** on this repository.
2. Clone your new repository locally.
3. Apply starter files into the repo root:

```bash
./bootstrap/apply-template.sh .
```

4. Rename `CLAUDE.md.base` to `CLAUDE.md` and customize project-specific sections.
5. Copy `compound-engineering.local.example.md` to `compound-engineering.local.md` and customize reviewers.
6. Run `claude mcp add -s user codex-xhigh -- codex mcp-server -c 'model=\"gpt-5.3-codex\"' -c 'model_reasoning_effort=\"xhigh\"'` once per machine.
7. Verify workflow commands exist:

```bash
ls .claude/commands/workflows
# should include: plan-loop.md, work.md, pr-triple-review.md, epic-delta-loop.md
```

8. Start planning:

```text
/workflows:plan-loop "Build an app that unifies Fathom/Aircall/HubSpot/Gmail timeline + suggestions"
```

9. Confirm planning artifacts were created:
   - `docs/plans/*-plan.md`
   - `docs/reviews/plans/*-codex-extra-high.md`
10. Initialize execution tracker:

```bash
scripts/init-plan-tracker.sh docs/plans/<your-plan>-plan.md
```

11. Execute implementation from the approved plan:

```text
/workflows:work docs/plans/<your-plan>-plan.md
```

12. If scope changes mid-epic:

```text
/workflows:epic-delta-loop "docs/plans/<your-plan>-plan.md | <delta request>"
```

13. Before merge:

```text
/workflows:pr-triple-review "<pr-number>"
```

14. Merge only when triple gate status is `PASS` for the current PR head SHA.
15. Optional: run `/compound-engineering-setup` for project-specific setup checks.

### Option B: Existing project bootstrap

```bash
./bootstrap/apply-template.sh /path/to/your-project
```

This copies templates into the target project without overwriting existing files.

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
