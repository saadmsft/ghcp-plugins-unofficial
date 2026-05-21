# ghcp-plugins-official

A GitHub Copilot (VS Code) port of [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official).

> ⚠️ Unofficial fork. Not affiliated with or endorsed by Anthropic. Upstream content is licensed under Apache 2.0; see per-plugin `LICENSE` files.

## What this is

Claude Code plugins use a directory layout (`commands/`, `agents/`, `skills/`, `.mcp.json`) that GitHub Copilot's VS Code chat doesn't load natively. This fork translates each plugin into GHCP's native customization formats:

| Claude Code           | GHCP equivalent                                          |
|-----------------------|----------------------------------------------------------|
| `commands/*.md`       | `*.prompt.md` (in user prompts folder)                   |
| `agents/*.md`         | `*.agent.md` (in user prompts folder)                    |
| `skills/<n>/SKILL.md` | `~/.copilot/skills/<n>/SKILL.md`                         |
| `.mcp.json`           | Entries merged into VS Code user `mcp.json` (manual)     |
| hooks (`.sh`)         | ❌ no GHCP equivalent — skipped                          |
| output styles         | ❌ no GHCP equivalent — skipped                          |
| `*-lsp` wrappers      | ❌ skipped — VS Code has these LSPs natively             |

All ported items are prefixed `claude-<plugin>-...` to avoid collisions.

## Repo layout

```
plugins/
  <plugin>/
    plugin.json         ← metadata + GHCP inventory
    prompts/            ← *.prompt.md  (slash-command equivalents)
    agents/             ← *.agent.md   (sub-agent personas)
    skills/<name>/      ← SKILL.md + resources
    mcp.json            ← MCP servers (if any)
    README.md
    LICENSE             ← Apache 2.0 from upstream

marketplace.json        ← machine-readable index of all plugins
install.sh              ← copy plugins into user profile
uninstall.sh            ← remove them
sync-from-upstream.sh   ← re-port from a fresh upstream clone
```

## Install

```bash
./install.sh                       # install everything
./install.sh code-review           # install one plugin
./install.sh code-review feature-dev   # install several
./install.sh --list                # show available plugins
./install.sh --dry-run             # preview without writing
```

Targets (macOS):
- Prompts/agents → `~/Library/Application Support/Code/User/prompts/`
- Skills → `~/.copilot/skills/`
- MCP → **manual merge** into `~/Library/Application Support/Code/User/mcp.json` (auto-merge is intentionally skipped so your existing config and `inputs` aren't clobbered)

Reload VS Code after installing: `Cmd+Shift+P` → **Developer: Reload Window**.

## Staying current

```bash
./sync-from-upstream.sh   # re-clone + re-port
git diff                  # review changes
git commit -am "sync $(date +%Y-%m-%d)"
```

## Caveats

- Claude-specific frontmatter (`allowed-tools: Bash(gh pr view:*)`, model directives) is dropped — those tool names don't map to GHCP. The prose body is preserved verbatim.
- Prompts referencing Claude-only constructs ("Haiku agent", "Sonnet agent", `Task` tool, sub-agent spawning) work best when treated as guidance rather than literal instructions under GHCP.
- Hooks (`.sh` files that run on file-edit events in Claude Code) have no GHCP equivalent and are not ported.

## Plugins included

See [`marketplace.json`](marketplace.json) for the machine-readable list, or browse [`plugins/`](plugins/).

## License & attribution

Plugin content is © Anthropic and contributors, Apache 2.0 (per upstream LICENSE files preserved alongside each plugin). The porting scripts and install tooling in this fork are MIT.
