#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") [--delete-branch] <branch-name>"
  echo ""
  echo "Removes a git worktree created by create-worktree.sh."
  echo ""
  echo "Options:"
  echo "  --delete-branch    Also delete the local branch after removal"
  echo ""
  echo "Example:"
  echo "  $(basename "$0") --delete-branch feat/new-feature"
  exit 1
}

DELETE_BRANCH=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --delete-branch) DELETE_BRANCH=true; shift ;;
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

if [[ ! -d "$WORKTREE_PATH" ]]; then
  echo "Worktree not found at: $WORKTREE_PATH"
  echo "Running prune to clean stale entries..."
  git worktree prune
  exit 1
fi

echo "Removing worktree: $WORKTREE_PATH"
git worktree remove "$WORKTREE_PATH"

git worktree prune
echo "Pruned stale worktree entries."

if [[ "$DELETE_BRANCH" == true ]]; then
  echo "Deleting local branch: $BRANCH_NAME"
  git branch -d "$BRANCH_NAME"
fi

echo "Done."
