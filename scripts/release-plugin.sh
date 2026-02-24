#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") <new-version>"
  echo ""
  echo "Updates plugin version in:"
  echo "  - plugins/compound-engineering-core/.claude-plugin/plugin.json"
  echo "  - .claude-plugin/marketplace.json"
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
fi

NEW_VERSION="$1"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_MANIFEST="$REPO_ROOT/plugins/compound-engineering-core/.claude-plugin/plugin.json"
MARKETPLACE_MANIFEST="$REPO_ROOT/.claude-plugin/marketplace.json"

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required"
  exit 1
fi

TMP_PLUGIN="$(mktemp)"
TMP_MARKETPLACE="$(mktemp)"
trap 'rm -f "$TMP_PLUGIN" "$TMP_MARKETPLACE"' EXIT

jq --arg version "$NEW_VERSION" '.version = $version' "$PLUGIN_MANIFEST" > "$TMP_PLUGIN"

jq --arg version "$NEW_VERSION" '
  .plugins = (.plugins | map(
    if .name == "compound-engineering-core" then .version = $version else . end
  ))
' "$MARKETPLACE_MANIFEST" > "$TMP_MARKETPLACE"

mv "$TMP_PLUGIN" "$PLUGIN_MANIFEST"
mv "$TMP_MARKETPLACE" "$MARKETPLACE_MANIFEST"

echo "Updated plugin to version $NEW_VERSION"
echo "Run: scripts/validate-marketplace.sh"
