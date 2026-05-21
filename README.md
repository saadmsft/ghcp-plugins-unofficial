# ghcp-plugins-official

> **A GitHub Copilot (VS Code) port of [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official).**
> Unofficial. Not affiliated with or endorsed by Anthropic or GitHub. Upstream content is © Anthropic and contributors under Apache 2.0; per-plugin `LICENSE` files are preserved.

---

## Table of contents

1. [What this is and why it exists](#what-this-is-and-why-it-exists)
2. [Quick start](#quick-start)
3. [What gets installed where](#what-gets-installed-where)
4. [Repo layout](#repo-layout)
5. [Plugin catalog (21 plugins)](#plugin-catalog-21-plugins)
6. [Install / uninstall reference](#install--uninstall-reference)
7. [Keeping in sync with upstream](#keeping-in-sync-with-upstream)
8. [Caveats and known limitations](#caveats-and-known-limitations)
9. [More docs](#more-docs)
10. [License & attribution](#license--attribution)

---

## What this is and why it exists

[Claude Code plugins](https://code.claude.com/docs/en/plugins) bundle slash commands, sub-agents, skills, MCP servers, and hooks into a single installable unit. GitHub Copilot Chat in VS Code has analogous concepts — **prompts**, **agents**, **skills**, **MCP servers** — but uses a *different on-disk layout and YAML frontmatter*, so a Claude plugin cannot be dropped into a Copilot install verbatim.

This repo solves that by:

1. **Cloning** the upstream marketplace (`anthropics/claude-plugins-official`).
2. **Porting** each plugin's contents into GHCP-native file formats with sanitized frontmatter.
3. **Restructuring** each plugin into a flat, self-contained directory under `plugins/<name>/`.
4. **Shipping** an `install.sh` that copies the right files into your VS Code user-profile directories.
5. **Providing** a `sync-from-upstream.sh` script so the fork stays current as upstream evolves.

You install once globally, reload VS Code, and the prompts/agents/skills become available in Copilot Chat exactly as if you had authored them yourself.

See **[docs/MAPPING.md](docs/MAPPING.md)** for the full feature-by-feature translation table and **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** for how the porter works internally.

---

## Quick start

```bash
git clone <this-repo-url> ghcp-plugins-official
cd ghcp-plugins-official

./install.sh --list                  # see all 21 plugins
./install.sh --dry-run code-review   # preview a single install
./install.sh code-review feature-dev # install two plugins
./install.sh                         # install everything
```

Then in VS Code: <kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> → **Developer: Reload Window**.

In Copilot Chat, type `/` to see the new prompts (prefixed `claude-…`), `@` to pick agents, and skills will auto-trigger based on their descriptions.

For step-by-step install walkthroughs, troubleshooting, and verification commands, see **[docs/INSTALL.md](docs/INSTALL.md)**.

---

## What gets installed where

| File type in this repo | Installed to (macOS)                                                | Surfaces in Copilot as            |
|---|---|---|
| `plugins/<P>/prompts/*.prompt.md` | `~/Library/Application Support/Code/User/prompts/`                  | `/claude-<P>-<command>` slash command |
| `plugins/<P>/agents/*.agent.md`   | `~/Library/Application Support/Code/User/prompts/`                  | `@Claude: <P> — <agent>` chat participant |
| `plugins/<P>/skills/<S>/...`      | `~/.copilot/skills/<S>/`                                            | Auto-triggered domain skill (by description) |
| `plugins/<P>/mcp.json`            | **Not auto-installed** — manual merge into user `mcp.json` recommended | MCP tool surface in Copilot |

Linux/WSL paths substitute `${XDG_CONFIG_HOME:-$HOME/.config}/Code/User/` for the macOS `~/Library/Application Support/Code/User/` path. Windows is not auto-detected by `install.sh` yet — see **[docs/INSTALL.md](docs/INSTALL.md#windows)**.

---

## Repo layout

```
ghcp-plugins-official/
├── plugins/                          # 21 ported plugins
│   └── <plugin-name>/
│       ├── plugin.json               # Metadata + GHCP inventory
│       ├── prompts/                  # *.prompt.md — slash-command equivalents
│       ├── agents/                   # *.agent.md  — sub-agent personas
│       ├── skills/<name>/            # SKILL.md + bundled resources
│       ├── mcp.json                  # MCP server defs (if applicable)
│       ├── README.md                 # Per-plugin docs + install snippet
│       └── LICENSE                   # Apache 2.0 (preserved from upstream)
│
├── marketplace.json                  # Machine-readable index of all plugins
├── install.sh                        # Install plugins into user profile
├── uninstall.sh                      # Reverse the install
├── sync-from-upstream.sh             # Re-port from a fresh upstream clone
│
├── README.md                         # ← you are here
├── LICENSE                           # MIT for tooling
├── CHANGELOG.md                      # Version history
├── CONTRIBUTING.md                   # How to add/fix plugins
│
└── docs/
    ├── ARCHITECTURE.md               # How the porter works (internals)
    ├── INSTALL.md                    # Detailed install/verify/troubleshoot
    ├── MAPPING.md                    # Claude → GHCP feature translation
    ├── PORTING.md                    # Add a new plugin or customize the porter
    ├── GHCP-PRIMER.md                # What prompts/agents/skills/MCP are
    └── TROUBLESHOOTING.md            # Symptom → cause → fix
```

The porter (`build-fork.py`) lives **one level up** from this repo at `../build-fork.py` so the fork's working tree stays clean of build tooling. See **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** for why.

---

## Plugin catalog (21 plugins)

Totals after porting: **26 prompts · 21 agents · 22 skills · 1 MCP server (placeholder)**.

| Plugin | Prompts | Agents | Skills | MCP | What it does |
|---|---:|---:|---:|---:|---|
| [`agent-sdk-dev`](plugins/agent-sdk-dev/) | 1 | 2 | 0 | – | Verify Anthropic Agent SDK apps (TS + Python) |
| [`claude-code-setup`](plugins/claude-code-setup/) | 0 | 0 | 1 | – | Claude Code onboarding skill (mostly self-referential) |
| [`claude-md-management`](plugins/claude-md-management/) | 1 | 0 | 1 | – | Manage `CLAUDE.md` files — applies to `AGENTS.md`/`copilot-instructions.md` too |
| [`code-modernization`](plugins/code-modernization/) | 7 | 5 | 0 | – | Legacy → modern stack pipeline (analyst, test-engineer, architecture-critic, security-auditor, business-rules-extractor) |
| [`code-review`](plugins/code-review/) | 1 | 0 | 0 | – | Multi-agent PR review with confidence scoring |
| [`code-simplifier`](plugins/code-simplifier/) | 0 | 1 | 0 | – | Refactor for clarity without changing behavior |
| [`commit-commands`](plugins/commit-commands/) | 3 | 0 | 0 | – | Conventional commits, autocommit, PR helpers |
| [`cwc-makers`](plugins/cwc-makers/) | 1 | 0 | 2 | – | "Code with Claude" maker workflows |
| [`example-plugin`](plugins/example-plugin/) | 1 | 0 | 2 | ✓ | Reference implementation (MCP is placeholder) |
| [`feature-dev`](plugins/feature-dev/) | 1 | 3 | 0 | – | Spec → code-explorer → code-architect → code-reviewer loop |
| [`frontend-design`](plugins/frontend-design/) | 0 | 0 | 1 | – | Design-system / UI conventions skill |
| [`hookify`](plugins/hookify/) | 4 | 1 | 1 | – | (hooks not ported) Conversation-analyzer + helper prompts |
| [`math-olympiad`](plugins/math-olympiad/) | 0 | 0 | 1 | – | Competition-math problem-solving skill |
| [`mcp-server-dev`](plugins/mcp-server-dev/) | 0 | 0 | 3 | – | Build/test/host MCP servers |
| [`mcp-tunnels`](plugins/mcp-tunnels/) | 1 | 0 | 0 | – | Expose local MCP servers via tunnels |
| [`playground`](plugins/playground/) | 0 | 0 | 1 | – | Scratch / experimentation skill |
| [`plugin-dev`](plugins/plugin-dev/) | 1 | 3 | 7 | – | Author Claude plugins (skill-reviewer, plugin-validator, agent-creator) |
| [`pr-review-toolkit`](plugins/pr-review-toolkit/) | 1 | 6 | 0 | – | Six specialist PR reviewers (silent-failure-hunter, type-design-analyzer, comment-analyzer, …) |
| [`ralph-loop`](plugins/ralph-loop/) | 3 | 0 | 0 | – | "Run until done" iteration pattern |
| [`session-report`](plugins/session-report/) | 0 | 0 | 1 | – | Generate session/standup reports |
| [`skill-creator`](plugins/skill-creator/) | 0 | 0 | 1 | – | Iteratively author & eval skills (485-line meta-skill) |

### Plugins *not* ported (and why)

- **12 LSP wrappers** (`clangd-lsp`, `csharp-lsp`, `gopls-lsp`, `jdtls-lsp`, `kotlin-lsp`, `lua-lsp`, `php-lsp`, `pyright-lsp`, `ruby-lsp`, `rust-analyzer-lsp`, `swift-lsp`, `typescript-lsp`) — VS Code already ships first-class LSP integrations for all of these; the Claude-side plugin only exists to wire LSPs into Claude Code's edit-event loop.
- **3 hook/output-style-only plugins** (`explanatory-output-style`, `learning-output-style`, `security-guidance`) — GHCP has no analog for Claude Code's `hooks/` (shell scripts triggered on file edits) or output-style customization.
- **1 example/placeholder** — `example-plugin`'s `.mcp.json` points at `https://mcp.example.com/api` and is staged but not auto-merged.

Full reasoning in **[docs/MAPPING.md](docs/MAPPING.md#what-cannot-be-ported)**.

---

## Install / uninstall reference

```bash
./install.sh                              # install ALL plugins
./install.sh code-review                  # install one
./install.sh code-review feature-dev      # install several
./install.sh --list                       # print plugin names, one per line
./install.sh --dry-run                    # show what would be copied (no writes)
./install.sh --dry-run code-modernization # combine with selection
./install.sh -h                           # built-in help

./uninstall.sh                            # remove ALL claude-plugins from your profile
./uninstall.sh hookify                    # remove just one
```

Behaviour notes:

- The scripts are **idempotent** — re-running `install.sh` overwrites in place. Your own non-`claude-`-prefixed prompts/agents/skills are never touched.
- Skills are removed and re-copied (not merged), so any local edits inside `~/.copilot/skills/claude-…/` will be lost on re-install. Make modifications in this repo's `plugins/<P>/skills/…` and re-run `install.sh` instead.
- MCP servers are **never** auto-merged into your user `mcp.json` — you must do that by hand. The `mcp-tunnels` plugin is a special case discussed in **[docs/INSTALL.md](docs/INSTALL.md#mcp-servers)**.

---

## Keeping in sync with upstream

```bash
./sync-from-upstream.sh
git diff
git commit -am "sync: $(date -u +%Y-%m-%d)"
```

What this does, in order:
1. Clones `anthropics/claude-plugins-official` to `../repo/` (or `git fetch && reset --hard origin/main` if already present).
2. Runs `../build-fork.py`, which regenerates every file under `plugins/`.
3. Leaves the working tree dirty so you can review and commit.

The porter is deterministic — running it twice on the same upstream commit produces byte-identical output. That means `git diff` is a clean signal of "what changed upstream this cycle".

Details: **[docs/PORTING.md](docs/PORTING.md#syncing)**.

---

## Caveats and known limitations

1. **Tool references don't translate.** Claude's `allowed-tools: Bash(gh pr view:*), Read, Grep` is dropped because GHCP's tool surface uses different names (`read`, `search`, `execute`, plus MCP tool IDs). Prompts that say "use a Haiku agent" or "spawn a sub-agent with the Task tool" will read as guidance under GHCP — they won't literally spawn sub-models. Most prose-style prompts still work well as instructions.
2. **Hooks are dropped.** Claude Code's `hooks/` (shell scripts run on `PostToolUse`, `UserPromptSubmit`, etc.) have no GHCP analog. Plugins that *only* shipped hooks are skipped entirely.
3. **Output styles are dropped.** Same reason.
4. **MCP servers are staged, not installed.** Auto-merging into your user `mcp.json` risks clobbering your existing servers and prompt-string `inputs`. Manual merge gives you a chance to review.
5. **Skills bigger than ~100 words description load lazily.** GHCP's progressive-disclosure loading means a skill's body only enters context when the description matches the user's request. If a ported skill never triggers, its description may need tuning — see **[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md#skill-never-auto-triggers)**.
6. **The `claude-` prefix is for hygiene, not branding.** It guarantees no collision with your own customizations and makes uninstall reliable, but it also means every slash-command is a mouthful (`/claude-code-review-code-review`). VS Code's command picker filters incrementally, so typing `/cl-co-re` usually narrows it.

---

## More docs

| Doc | When to read it |
|---|---|
| [`docs/GHCP-PRIMER.md`](docs/GHCP-PRIMER.md) | New to GHCP customization files? Start here. |
| [`docs/MAPPING.md`](docs/MAPPING.md) | "What exactly does the porter do to a Claude command vs an agent vs a skill?" |
| [`docs/INSTALL.md`](docs/INSTALL.md) | Detailed install + verification + per-OS notes |
| [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) | "I installed it but Copilot doesn't see it" |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | How `build-fork.py` is structured + invariants |
| [`docs/PORTING.md`](docs/PORTING.md) | Add a new plugin, customize porter behavior, contribute back |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Workflow for PRs |
| [`CHANGELOG.md`](CHANGELOG.md) | What changed when |

---

## License & attribution

- **Plugin content under `plugins/`** — © Anthropic and contributors, [Apache License 2.0](https://github.com/anthropics/claude-plugins-official/blob/main/LICENSE). Per-plugin `LICENSE` files are preserved verbatim.
- **Porting scripts, install tooling, and docs in this fork** — [MIT](LICENSE), © 2026 Saad Mahmood.

This is an unofficial port. Issues with plugin *content* should be filed against [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official). Issues with *porting* (a plugin doesn't load, frontmatter is malformed, etc.) belong here.
