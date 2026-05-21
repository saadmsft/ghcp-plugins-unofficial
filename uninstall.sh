#!/usr/bin/env bash
# Remove GHCP-native Claude plugins from your user profile.
# Usage: ./uninstall.sh [plugin...]  (default: all)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGINS_DIR="$ROOT/plugins"

if [[ "$(uname -s)" == "Darwin" ]]; then
  PROMPTS_DIR="$HOME/Library/Application Support/Code/User/prompts"
else
  PROMPTS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User/prompts"
fi
SKILLS_DIR="$HOME/.copilot/skills"

selected=("$@")
if [[ ${#selected[@]} -eq 0 ]]; then
  for d in "$PLUGINS_DIR"/*/; do selected+=("$(basename "$d")"); done
fi

for plugin in "${selected[@]}"; do
  pdir="$PLUGINS_DIR/$plugin"
  [[ -d "$pdir" ]] || continue
  echo "==> removing $plugin"
  for f in "$pdir/prompts"/*.prompt.md "$pdir/agents"/*.agent.md; do
    [[ -e "$f" ]] || continue
    rm -f "$PROMPTS_DIR/$(basename "$f")"
  done
  if [[ -d "$pdir/skills" ]]; then
    for sd in "$pdir/skills"/*/; do
      [[ -d "$sd" ]] || continue
      rm -rf "$SKILLS_DIR/$(basename "$sd")"
    done
  fi
done

echo "Done. Reload VS Code."
