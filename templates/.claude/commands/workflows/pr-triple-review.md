---
name: workflows:pr-triple-review
description: Legacy alias for workflows:pr-review
argument-hint: "[pr number, pr url, or branch name]"
---

# Legacy Alias: PR Review

This command is retained for backwards compatibility.

Execute the exact same workflow, policies, evidence files, and gate semantics as:

`/workflows:pr-review #$ARGUMENTS`

Prefer `workflows:pr-review` in all new documentation, prompts, and runbooks.
