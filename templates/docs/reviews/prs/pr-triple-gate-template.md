# Legacy Alias: PR Review Gate Template

Prefer `pr-review-gate-template.md` for all new evidence files.

This legacy filename remains usable so older repos and human processes still get a complete template.

## Metadata

- Date: `{YYYY-MM-DD}`
- PR Number: `{PR_NUMBER}`
- Branch: `{BRANCH}`
- PR Head SHA: `{PR_HEAD_SHA}`
- Status: `PASS|FAIL|PENDING|STALE|SUPERSEDED`
- Approved SHA: `{APPROVE_SHA|n/a}`
- Superseded By: `{docs/reviews/prs/pr-<number>-review.md|n/a}`

## Gate Results

| Gate | Status | Reviewed SHA | Evidence |
|------|--------|--------------|----------|
| Teammate review | PASS|FAIL|PENDING|STALE | `{TEAMMATE_REVIEWED_SHA}` | `{path}` |
| Codex correctness | PASS|FAIL|PENDING|STALE | `{CODEX_CORRECTNESS_REVIEWED_SHA}` | `docs/reviews/prs/pr-{PR_NUMBER}-codex-correctness.md` |
| Codex edge-case | PASS|FAIL|PENDING|STALE | `{CODEX_EDGECASE_REVIEWED_SHA}` | `docs/reviews/prs/pr-{PR_NUMBER}-codex-edgecase.md` |
| Test/CI | PASS|FAIL|PENDING|STALE|N/A | `{TEST_CI_REVIEWED_SHA_OR_N_A}` | `{path}` |
| Frontend/browser validation | PASS|FAIL|PENDING|STALE|N/A | `{FRONTEND_VALIDATION_REVIEWED_SHA_OR_N_A}` | `docs/reviews/frontend/pr-{PR_NUMBER}-frontend-validate.md` |

## Blockers

- {blocker}

## Non-Blocker Triage

| Finding | Source Reviewers | Support Count | Impact Tags | Disposition | Rationale | Counterevidence | PM Signoff | Target Milestone / PR | Owner / Follow-up |
|---------|-------------------|---------------|-------------|-------------|-----------|-----------------|------------|-----------------------|-------------------|
| {finding} | {reviewers} | {count} | {tags} | implement_now\|defer\|reject | {rationale} | {counterevidence_or_n/a} | {pm_signoff_or_n/a} | {target_milestone_or_pr} | {owner_or_followup} |

## Next Action

- {action}
