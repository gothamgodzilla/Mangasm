#!/usr/bin/env bash
# Commit and push from terminal — no Xcode Source Control needed.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

MSG="${1:-chore: update Mangasm}"
BRANCH="${2:-$(git branch --show-current)}"

git status -sb
git add -A
if git diff --cached --quiet; then
  echo "Nothing to commit."
  exit 0
fi

git commit -m "$MSG"
git push origin "$BRANCH"
echo "Pushed to origin/$BRANCH"