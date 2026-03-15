---
review_agents: [compound-engineering-core:kieran-python-reviewer, compound-engineering-core:code-simplicity-reviewer, compound-engineering-core:security-sentinel, compound-engineering-core:performance-oracle]
plan_review_agents: [compound-engineering-core:kieran-python-reviewer, compound-engineering-core:code-simplicity-reviewer]
external_plan_review_gate: codex-extra-high
codex_mcp_server: codex-xhigh
research_agents: [compound-engineering-core:repo-research-analyst, compound-engineering-core:learnings-researcher, compound-engineering-core:framework-docs-researcher, compound-engineering-core:external-frontier-researcher, compound-engineering-core:best-practices-researcher]
research_max_rounds: 3
deepen_plan_max_rounds: 2
max_prs_per_epic: 5
max_net_loc_per_pr: 600
max_files_per_pr: 20
max_cycle_days_per_pr: 2
require_test_strategy_per_pr: true
require_tests_for_code_prs: true
require_integration_tests_for_boundary_changes: true
require_frontend_validation_for_frontend_changes: true
allow_conditional_pass_for_code_prs: false
frontend_validation_mode: gstack
frontend_local_url: "http://localhost:3000"
frontend_staging_url: ""
frontend_validation_use_staging_fallback: false
frontend_local_revision_check_command: ""
frontend_staging_revision_check_command: ""
playwright_command: ""
gstack_binary_path: ""
default_subagent_model: null
require_non_blocker_triage: true
require_pm_signoff_for_non_blocker_deferrals: true
auto_promote_high_impact_non_blockers: true
auto_promote_consensus_non_blockers: true
consensus_threshold_for_promotion: 2
require_counterevidence_for_non_blocker_reject: true
require_pm_signoff_for_consensus_non_blocker_deferrals: true
unit_test_command: "pytest -q tests/unit"
integration_test_command: "pytest -q tests/integration"
---

# Review Context

Project-specific instructions for review agents and external gates.

Add domain-specific constraints here (security invariants, data model rules, deployment constraints, compliance requirements).
