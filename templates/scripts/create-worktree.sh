#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") [--copy-env] <branch-name>"
  echo ""
  echo "Creates a git worktree from develop for parallel work."
  echo ""
  echo "Options:"
  echo "  --copy-env    Copy .env instead of symlinking it"
  echo ""
  echo "Example:"
  echo "  $(basename "$0") feat/new-feature"
  exit 1
}

COPY_ENV=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --copy-env) COPY_ENV=true; shift ;;
    -h|--help) usage ;;
    -*) echo "Unknown option: $1"; usage ;;
    *) BRANCH_NAME="$1"; shift ;;
  esac
done

if [[ -z "${BRANCH_NAME:-}" ]]; then
  usage
fi

MAIN_WORKTREE="$(git rev-parse --show-toplevel)"
REPO_NAME="$(basename "$MAIN_WORKTREE")"
SANITIZED_BRANCH="${BRANCH_NAME//\//-}"
WORKTREE_PATH="$(dirname "$MAIN_WORKTREE")/${REPO_NAME}-${SANITIZED_BRANCH}"

if [[ -d "$WORKTREE_PATH" ]]; then
  echo "Error: worktree path already exists: $WORKTREE_PATH"
  exit 1
fi

echo "Creating worktree at: $WORKTREE_PATH"
echo "Base branch: develop"
echo "New branch: $BRANCH_NAME"
echo ""

git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" develop

# Handle .env
if [[ -f "$MAIN_WORKTREE/.env" ]]; then
  if [[ "$COPY_ENV" == true ]]; then
    cp "$MAIN_WORKTREE/.env" "$WORKTREE_PATH/.env"
    echo "Copied .env"
  else
    ln -s "$MAIN_WORKTREE/.env" "$WORKTREE_PATH/.env"
    echo "Symlinked .env"
  fi
fi

# Recreate symlinks for large directories
for DIR_NAME in .venv terraform aws; do
  SOURCE="$MAIN_WORKTREE/$DIR_NAME"
  if [[ -L "$SOURCE" ]]; then
    TARGET="$(readlink "$SOURCE")"
    # Resolve relative targets against main worktree
    if [[ ! "$TARGET" = /* ]]; then
      TARGET="$(cd "$MAIN_WORKTREE" && cd "$(dirname "$TARGET")" && pwd)/$(basename "$TARGET")"
    fi
    if [[ ! -e "$TARGET" ]]; then
      echo "Error: symlink target does not exist: $TARGET (for $DIR_NAME)"
      exit 1
    fi
    ln -s "$TARGET" "$WORKTREE_PATH/$DIR_NAME"
    echo "Symlinked $DIR_NAME -> $TARGET"
  fi
done

echo ""
echo "Worktree ready. Next steps:"
echo "  cd $WORKTREE_PATH"
echo "  # Start working on $BRANCH_NAME"
