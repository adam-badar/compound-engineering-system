#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") <target-directory>"
  echo ""
  echo "Copies compound engineering templates into the target project."
  echo "Existing files are NOT overwritten."
  echo ""
  echo "Example:"
  echo "  $(basename "$0") /path/to/my-project"
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
fi

TARGET_DIR="$1"

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Error: target directory does not exist: $TARGET_DIR"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../templates"

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "Error: templates directory not found at $TEMPLATE_DIR"
  exit 1
fi

CREATED=()
SKIPPED=()

copy_template() {
  local src="$1"
  local rel_path="${src#$TEMPLATE_DIR/}"
  local dest="$TARGET_DIR/$rel_path"
  local dest_dir="$(dirname "$dest")"

  if [[ ! -d "$dest_dir" ]]; then
    mkdir -p "$dest_dir"
  fi

  if [[ -e "$dest" ]]; then
    SKIPPED+=("$rel_path (exists)")
  else
    cp "$src" "$dest"
    # Preserve executable bit
    if [[ -x "$src" ]]; then
      chmod +x "$dest"
    fi
    CREATED+=("$rel_path")
  fi
}

# Find all files in templates and copy them
while IFS= read -r -d '' file; do
  copy_template "$file"
done < <(find "$TEMPLATE_DIR" -type f -print0)

echo "=== Apply Template Results ==="
echo ""

if [[ ${#CREATED[@]} -gt 0 ]]; then
  echo "Created:"
  for f in "${CREATED[@]}"; do
    echo "  + $f"
  done
fi

if [[ ${#SKIPPED[@]} -gt 0 ]]; then
  echo ""
  echo "Skipped (already exist):"
  for f in "${SKIPPED[@]}"; do
    echo "  ~ $f"
  done
fi

echo ""
echo "Done. Review CLAUDE.md.base and rename it to CLAUDE.md after customizing."
