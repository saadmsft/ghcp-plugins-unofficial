#!/usr/bin/env bash
# Re-sync this fork from the upstream Claude Code plugins repo.
# Pulls upstream, re-runs the porter, and rebuilds plugins/.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT="$(dirname "$ROOT")"
UP="$PARENT/repo"

if [[ ! -d "$UP/.git" ]]; then
  echo "Cloning upstream to $UP ..."
  git clone --depth 1 https://github.com/anthropics/claude-plugins-official.git "$UP"
else
  echo "Updating upstream at $UP ..."
  git -C "$UP" fetch --depth 1 origin main
  git -C "$UP" reset --hard origin/main
fi

python3 "$PARENT/build-fork.py"
echo "Sync complete. Review changes with: git -C \"$ROOT\" status"
