---
title: docs/ideas gate v0.6.2 hardening (PR #30 plateau OPEN findings)
status: deferred
owner: Adam Badar
target_date: 2026-06-15
created_at: 2026-05-01
priority: medium
tags: [workflows, docs-ideas, plan-loop, brainstorm, v0.6.2]
related_repos: [adam-badar/compound-engineering-system]
parent_pr: 30
parent_pr_url: https://github.com/adam-badar/compound-engineering-system/pull/30
---

# docs/ideas gate v0.6.2 hardening

## Problem

PR #30 shipped v0.6.1 with 5 OPEN findings from Codex Extra High pass 4 (plateau-converged). The findings are documentation gaps and contract internal-consistency issues, not exploits. They should be addressed in v0.6.2 to fully close the contract.

## Why deferred (not blocking v0.6.1)

- The 12-line baseline had **none** of the protections the OPEN findings critique. v0.6.1 closes one real exploit risk (prompt-injection trust boundary) and adds defense-in-depth that was absent before.
- All 5 OPEN findings are theoretical: no recorded incident triggers them. Frequency estimated <0.1% per workflow run.
- The PR grew from 12 LOC to 80 LOC chasing Codex. Each fix introduced its own next-layer issue (plateau pattern). PM authorized ship-with-risk 2026-05-01 to avoid further over-engineering.
- Same plateau-with-PM-authorization pattern as parent plan `Bavi/docs/plans/2026-04-30-baviverse-persona-routines-plan.md`.

## Open findings to address in v0.6.2

### HIGH — correctness

1. **Brainstorm-only terminal idea reference loss.** Pre-plan resolution gate inspects the brainstorm; post-plan promotion check inspects only the generated plan. If the plan drops a brainstorm reference to a terminal `completed`/`abandoned` idea, the post-plan check never fires on that idea. Outcome: silent revival of a terminal idea is possible in Branch B (brainstorm path).
   - Fix: carry the terminal-idea reference set from the source artifact into the post-plan check. Either require the plan to preserve all source-artifact terminal references, or require explicit disclaim comments.

2. **In-place reactivation metadata not durably enforceable.** The reactivation rule fires only when current `status` is `completed` or `abandoned`. After the file is edited to `status: active`, a subsequent rerun no longer triggers the rule, so `reactivated_at` and rationale can be silently dropped.
   - Fix: capture terminal-idea reference set at gate entry; validate reactivation metadata on those paths even after status change. Or: require an audit-log field that survives status changes (e.g., `reactivation_history: [{timestamp, rationale}]`).

### HIGH — UX / discipline

3. **Default `owner:` field on mid-brainstorm idea-file creation.** Workflow `brainstorm.md` step 4.0 currently requires the agent writing a deferred-idea file to include frontmatter (`status / owner / target_date / rationale / created_at / title`), but doesn't specify a default owner. Result: agents leaving the field blank when they don't know who to assign, and the consumer's downstream tooling (e.g., the Bavi Product Management persona email at `Bavi/src/bavi/routines/personas/product_management.py`) flags every such idea as backlog drift. The right default is project-aware: per-repo `compound-engineering.local.md` should declare the default owner (e.g., `default_owner: Adam Badar` for personal repos), and `brainstorm.md` step 4.0 should write that into the frontmatter automatically when the agent doesn't explicitly know better. Ask the PM only when there's genuine ambiguity.
   - Fix: extend `compound-engineering.local.md` schema with `default_owner` field. Update `brainstorm.md` step 4.0 frontmatter requirement to read `default_owner` and pre-fill `owner:` accordingly. Document the "ask only when ambiguous" rule in the workflow text.

### MEDIUM — edge case

4. **Flag-stripping ambiguity for paths containing `=`.** Step 1a says strip "any other `key=value` runtime flags" before classification. A path like `docs/brainstorms/foo=bar-brainstorm.md` could be misread as a flag. Also: Branch B/C invoke `/workflows:plan <planning_input>` with the original (unstripped) input downstream, leaking flags into plan generation.
   - Fix: whitelist exact standalone flag tokens (`teams=on|off`, `research=auto|on|off`); use the stripped artifact path in downstream invocations.

5. **`reactivation_rationale` not in untrusted-data extraction allowlist.** Reactivation rule allows `reactivation_rationale` field; extraction allowlist (`status, owner, target_date, rationale, reactivated_at, supersedes, created_at, title`) does not include it. An implementation following the untrusted-data rule strictly cannot validate the documented path.
   - Fix: add `reactivation_rationale` to the allowlist.

6. **Supersession transitive chains.** `supersedes:` constraint specifies one-hop only ("must resolve to existing terminal idea file"). A→B→C chain (A superseded by B, B superseded by C, C is the active follow-up) is not specified — a plan referencing terminal A can fail the gate even when latest active successor C exists.
   - Fix: specify chain traversal — follow `supersedes:` pointers transitively until reaching an active idea or a cycle. Block on cycle.

## Acceptance for closing this idea

- v0.6.2 PR addresses all 6 OPEN findings.
- Codex Extra High PR review passes without re-introducing similar plateau.
- CHANGELOG 0.6.2 entry references this idea.
- Update this idea: `status: completed` with merged-PR back-link.

## References

- Parent PR: https://github.com/adam-badar/compound-engineering-system/pull/30
- PR review evidence: `docs/reviews/prs/pr-30-review.md`
- Plateau plan precedent: `Bavi/docs/plans/2026-04-30-baviverse-persona-routines-plan.md`
