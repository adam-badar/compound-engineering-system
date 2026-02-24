#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

MARKETPLACE_MANIFEST="$REPO_ROOT/.claude-plugin/marketplace.json"
PLUGIN_ROOT="$REPO_ROOT/plugins/compound-engineering-core"
PLUGIN_MANIFEST="$PLUGIN_ROOT/.claude-plugin/plugin.json"

if ! command -v claude >/dev/null 2>&1; then
  echo "Error: 'claude' CLI not found in PATH"
  exit 1
fi

echo "Validating marketplace manifest..."
claude plugin validate "$MARKETPLACE_MANIFEST"

echo "Validating plugin manifest..."
claude plugin validate "$PLUGIN_MANIFEST"

echo "Validating plugin package..."
claude plugin validate "$PLUGIN_ROOT"

echo "Validation complete."
