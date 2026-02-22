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
WORKTREE_CREATED=false

cleanup_on_error() {
  local exit_code=$?
  if [[ "$WORKTREE_CREATED" == true ]]; then
    echo ""
    echo "Error after worktree creation. Cleaning up partial worktree..."
    git worktree remove --force "$WORKTREE_PATH" >/dev/null 2>&1 || true
    if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
      git branch -D "$BRANCH_NAME" >/dev/null 2>&1 || true
    fi
  fi
  exit "$exit_code"
}

trap 'cleanup_on_error' ERR

if [[ -d "$WORKTREE_PATH" ]]; then
  echo "Error: worktree path already exists: $WORKTREE_PATH"
  exit 1
fi

BASE_REF=""
if git ls-remote --exit-code --heads origin develop >/dev/null 2>&1; then
  git fetch origin develop
  BASE_REF="origin/develop"
elif git show-ref --verify --quiet refs/heads/develop; then
  BASE_REF="develop"
else
  DEFAULT_REMOTE_BRANCH="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || true)"
  if [[ -z "$DEFAULT_REMOTE_BRANCH" ]]; then
    DEFAULT_REMOTE_BRANCH="main"
  fi
  echo "No develop branch found. Creating local develop from origin/$DEFAULT_REMOTE_BRANCH"
  git fetch origin "$DEFAULT_REMOTE_BRANCH"
  git branch develop "origin/$DEFAULT_REMOTE_BRANCH"
  BASE_REF="develop"
fi

echo "Creating worktree at: $WORKTREE_PATH"
echo "Base branch: $BASE_REF"
echo "New branch: $BRANCH_NAME"
echo ""

git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" "$BASE_REF"
WORKTREE_CREATED=true

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
    DEST_PATH="$WORKTREE_PATH/$DIR_NAME"
    if [[ -L "$DEST_PATH" ]]; then
      rm "$DEST_PATH"
    elif [[ -e "$DEST_PATH" ]]; then
      echo "Error: refusing to replace non-symlink path: $DEST_PATH"
      echo "This partial worktree will be cleaned up automatically."
      echo "Fix the base branch path/symlink setup, then rerun this script."
      exit 1
    fi
    ln -s "$TARGET" "$WORKTREE_PATH/$DIR_NAME"
    echo "Symlinked $DIR_NAME -> $TARGET"
  fi
done

trap - ERR

echo ""
echo "Worktree ready. Next steps:"
echo "  cd $WORKTREE_PATH"
echo "  # Start working on $BRANCH_NAME"
