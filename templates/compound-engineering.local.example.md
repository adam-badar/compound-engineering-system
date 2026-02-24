---
review_agents: [compound-engineering-core:kieran-python-reviewer, compound-engineering-core:code-simplicity-reviewer, compound-engineering-core:security-sentinel, compound-engineering-core:performance-oracle]
plan_review_agents: [compound-engineering-core:kieran-python-reviewer, compound-engineering-core:code-simplicity-reviewer]
external_plan_review_gate: codex-extra-high
external_pr_review_gate: codex-extra-high
greptile_required_for_code_prs: true
codex_mcp_server: codex-xhigh
codex_gate_agent: compound-engineering-core:codex-gate-runner
---

# Review Context

Project-specific instructions for review agents and external gates.

Add domain-specific constraints here (security invariants, data model rules, deployment constraints, compliance requirements).
