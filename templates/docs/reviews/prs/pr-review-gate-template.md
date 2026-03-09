# PR Review: PR #{PR_NUMBER}

## Metadata

- Date: `{YYYY-MM-DD}`
- PR Number: `{PR_NUMBER}`
- Branch: `{BRANCH}`
- PR Head SHA: `{PR_HEAD_SHA}`
- Status: `pass|fail|pending|stale`
- Approved SHA: `{APPROVE_SHA|n/a}`

## Gate Results

| Gate | Status | Reviewed SHA | Evidence |
|------|--------|--------------|----------|
| Teammate review | pass|fail|pending|stale | `{PR_HEAD_SHA}` | `{path}` |
| Codex correctness | pass|fail|pending|stale | `{PR_HEAD_SHA}` | `docs/reviews/prs/pr-{PR_NUMBER}-codex-correctness.md` |
| Codex edge-case | pass|fail|pending|stale | `{PR_HEAD_SHA}` | `docs/reviews/prs/pr-{PR_NUMBER}-codex-edgecase.md` |
| Test/CI | pass|fail|pending|stale|n/a | `{PR_HEAD_SHA}` | `{path}` |

## Blockers

- {blocker}

## Non-Blocker Triage

| Finding | Source Reviewers | Support Count | Impact Tags | Disposition | Rationale | Owner / Follow-up |
|---------|-------------------|---------------|-------------|-------------|-----------|-------------------|
| {finding} | {reviewers} | {count} | {tags} | implement_now\|defer\|reject | {rationale} | {owner_or_followup} |

## Next Action

- {action}
