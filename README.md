# Compound Engineering System

Reusable templates for bootstrapping projects with compound engineering practices: structured AI-assisted development, decision records, runbooks, and CI workflows.

## What's Included

| Path | Purpose |
|------|---------|
| `templates/CLAUDE.md.base` | Base Claude Code instructions (branch workflow, planning, memory, circuit breakers) |
| `templates/.claude/settings.json` | Default Claude Code permissions and deny rules |
| `templates/docs/adr/` | Architecture Decision Record template |
| `templates/docs/runbooks/` | Operational runbook template |
| `templates/docs/solutions/` | Solution documentation structure |
| `templates/scripts/` | Worktree creation/removal helpers |
| `templates/.github/workflows/` | CI workflow templates |

## Usage

### Quick Bootstrap

```bash
./bootstrap/apply-template.sh /path/to/your-project
```

This copies all templates into the target project without overwriting existing files.

### Manual

Copy individual templates as needed. Edit placeholder sections marked with `<!-- PROJECT-SPECIFIC -->` or `# TODO:` comments.

## Conventions

- **Branch workflow**: `develop` for work, `main` for production. PRs only.
- **Planning**: Think first, plan, verify, then execute.
- **Memory**: `.claude/memory.md` in each repo tracks learnings.
- **ADRs**: Numbered, immutable once accepted. Supersede, don't edit.
