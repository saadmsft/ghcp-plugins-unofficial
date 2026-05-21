#!/usr/bin/env bash
# Install GHCP-native Claude plugins into your user profile.
#
# Usage:
#   ./install.sh                 # install all plugins
#   ./install.sh <plugin>...     # install specific plugins
#   ./install.sh --list          # list available plugins
#   ./install.sh --dry-run [...] # show what would happen
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGINS_DIR="$ROOT/plugins"

if [[ "$(uname -s)" == "Darwin" ]]; then
  PROMPTS_DIR="$HOME/Library/Application Support/Code/User/prompts"
  MCP_FILE="$HOME/Library/Application Support/Code/User/mcp.json"
else
  PROMPTS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User/prompts"
  MCP_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User/mcp.json"
fi
SKILLS_DIR="$HOME/.copilot/skills"

DRY=0
list_only=0
selected=()

for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --list) list_only=1 ;;
    -h|--help)
      sed -n '2,8p' "$0"; exit 0 ;;
    --*) echo "unknown flag: $a" >&2; exit 2 ;;
    *) selected+=("$a") ;;
  esac
done

if [[ $list_only -eq 1 ]]; then
  for d in "$PLUGINS_DIR"/*/; do basename "$d"; done
  exit 0
fi

if [[ ${#selected[@]} -eq 0 ]]; then
  for d in "$PLUGINS_DIR"/*/; do selected+=("$(basename "$d")"); done
fi

run() {
  if [[ $DRY -eq 1 ]]; then echo "DRY: $*"
  else "$@"; fi
}

mkdir -p "$PROMPTS_DIR" "$SKILLS_DIR"

mcp_pending=()

for plugin in "${selected[@]}"; do
  pdir="$PLUGINS_DIR/$plugin"
  [[ -d "$pdir" ]] || { echo "skip: $plugin (not found)"; continue; }
  echo "==> $plugin"

  if [[ -d "$pdir/prompts" ]]; then
    for f in "$pdir/prompts"/*.prompt.md; do
      [[ -e "$f" ]] || continue
      run cp -f "$f" "$PROMPTS_DIR/$(basename "$f")"
    done
  fi
  if [[ -d "$pdir/agents" ]]; then
    for f in "$pdir/agents"/*.agent.md; do
      [[ -e "$f" ]] || continue
      run cp -f "$f" "$PROMPTS_DIR/$(basename "$f")"
    done
  fi
  if [[ -d "$pdir/skills" ]]; then
    for sd in "$pdir/skills"/*/; do
      [[ -d "$sd" ]] || continue
      name="$(basename "$sd")"
      run rm -rf "$SKILLS_DIR/$name"
      run cp -R "$sd" "$SKILLS_DIR/$name"
    done
  fi
  if [[ -f "$pdir/mcp.json" ]]; then
    mcp_pending+=("$pdir/mcp.json")
  fi
done

if [[ ${#mcp_pending[@]} -gt 0 ]]; then
  echo
  echo "MCP servers were found in: ${mcp_pending[*]}"
  echo "Review and manually merge into: $MCP_FILE"
  echo "(Auto-merge skipped to protect existing config and inputs.)"
fi

echo "Done. Reload VS Code (Cmd+Shift+P → 'Developer: Reload Window')."
