#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") <plan-file>"
  echo ""
  echo "Example:"
  echo "  $(basename "$0") docs/plans/2026-02-21-feat-customer-timeline-plan.md"
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
fi

PLAN_FILE="$1"

if [[ ! -f "$PLAN_FILE" ]]; then
  echo "Error: plan file not found: $PLAN_FILE"
  exit 1
fi

if [[ "$PLAN_FILE" != docs/plans/*-plan.md ]]; then
  echo "Error: expected docs/plans/*-plan.md"
  exit 1
fi

TRACKER_FILE="${PLAN_FILE%-plan.md}-execution.md"
TEMPLATE_FILE="docs/plans/templates/execution-status-template.md"
TODAY="$(date +%F)"
PLAN_BASENAME="$(basename "$PLAN_FILE")"
PLAN_TITLE="$(basename "$PLAN_FILE" -plan.md)"

if [[ -f "$TRACKER_FILE" ]]; then
  echo "Tracker already exists: $TRACKER_FILE"
  exit 0
fi

if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo "Error: template not found: $TEMPLATE_FILE"
  exit 1
fi

mkdir -p "$(dirname "$TRACKER_FILE")"

sed \
  -e "s|{PLAN_TITLE}|$PLAN_TITLE|g" \
  -e "s|{PLAN_FILE}|$PLAN_BASENAME|g" \
  -e "s|{OWNER}|unassigned|g" \
  -e "s|{YYYY-MM-DD}|$TODAY|g" \
  -e "s|{EPIC_NAME}|unassigned|g" \
  -e "s|{GOAL}|todo|g" \
  -e "s|{NON_GOALS}|todo|g" \
  -e "s|{task-1}|todo|g" \
  -e "s|{task-2}|todo|g" \
  -e "s|{task-3}|todo|g" \
  -e "s|{owner}|unassigned|g" \
  -e "s|{notes}|todo|g" \
  -e "s|{test or check}|todo|g" \
  -e "s|{result}|todo|g" \
  -e "s|{evidence link}|todo|g" \
  -e "s|{decision}|todo|g" \
  -e "s|{reason}|todo|g" \
  -e "s|{impact}|todo|g" \
  "$TEMPLATE_FILE" > "$TRACKER_FILE"

echo "Created tracker: $TRACKER_FILE"
