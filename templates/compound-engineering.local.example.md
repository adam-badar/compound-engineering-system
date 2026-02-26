---
review_agents: [compound-engineering-core:kieran-python-reviewer, compound-engineering-core:code-simplicity-reviewer, compound-engineering-core:security-sentinel, compound-engineering-core:performance-oracle]
plan_review_agents: [compound-engineering-core:kieran-python-reviewer, compound-engineering-core:code-simplicity-reviewer]
external_plan_review_gate: codex-extra-high
external_pr_review_gate: codex-extra-high
greptile_required_for_code_prs: true
codex_mcp_server: codex-xhigh
codex_gate_agent: compound-engineering-core:codex-gate-runner
max_prs_per_epic: 5
max_net_loc_per_pr: 600
max_files_per_pr: 20
max_cycle_days_per_pr: 2
require_test_strategy_per_pr: true
require_tests_for_code_prs: true
require_integration_tests_for_boundary_changes: true
allow_conditional_pass_for_code_prs: false
require_non_blocker_triage: true
require_pm_signoff_for_non_blocker_deferrals: true
auto_promote_high_impact_non_blockers: true
unit_test_command: "pytest -q tests/unit"
integration_test_command: "pytest -q tests/integration"
---

# Review Context

Project-specific instructions for review agents and external gates.

Add domain-specific constraints here (security invariants, data model rules, deployment constraints, compliance requirements).
