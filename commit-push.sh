#!/usr/bin/env bash
set -euo pipefail

# Usage: ./commit-push.sh "commit message"
# If no message provided, prompts for one.

msg="$*"
if [ -z "${msg// /}" ]; then
  read -rp "Commit message: " msg
  if [ -z "${msg// /}" ]; then
    echo "Aborting: empty commit message" >&2
    exit 1
  fi
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repository." >&2
  exit 1
fi

branch=$(git rev-parse --abbrev-ref HEAD)

echo "Staging changes..."
git add -A

echo "Committing: $msg"
# Allow commit to fail if there's nothing to commit
if ! git commit -m "$msg"; then
  echo "No changes to commit or commit failed." >&2
fi

echo "Pushing to origin/$branch..."
git push -u origin "$branch"

echo "Done."
