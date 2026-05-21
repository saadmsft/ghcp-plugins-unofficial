# Changelog

All notable changes to this fork's **porting + tooling**. For changes to upstream plugin *content*, see commit history under `plugins/` and the upstream [`anthropics/claude-plugins-official`](https://github.com/anthropics/claude-plugins-official) repo.

Format loosely based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

_Nothing yet._

---

## [0.1.0] — 2026-05-21

Initial port of the upstream `anthropics/claude-plugins-official` marketplace into a GitHub Copilot–native layout.

### Added

- **Porter** (`../build-fork.py`): reads upstream `plugins/<P>/...` and emits a GHCP-native tree under `plugins/<P>/...`.
- **Install scripts**: `install.sh` (with `--list` / `--dry-run` / plugin-name args), `uninstall.sh`, `sync-from-upstream.sh`.
- **21 plugins ported**:
  - `agent-sdk-dev`, `claude-code-setup`, `claude-md-management`, `code-modernization`, `code-review`, `code-simplifier`, `commit-commands`, `cwc-makers`, `example-plugin`, `feature-dev`, `frontend-design`, `hookify`, `math-olympiad`, `mcp-server-dev`, `mcp-tunnels`, `playground`, `plugin-dev`, `pr-review-toolkit`, `ralph-loop`, `session-report`, `skill-creator`.
  - Totals: **26 prompts**, **21 agents**, **22 skills**, **1 MCP server (placeholder)**.
- **`marketplace.json`** machine-readable index.
- **Per-plugin `README.md`** in each `plugins/<P>/` directory.
- **Per-plugin `plugin.json`** preserving upstream metadata + adding a `ghcp:` inventory section.
- **Top-level documentation suite** under `docs/`:
  - `GHCP-PRIMER.md` — what prompts/agents/skills/MCP/instructions are
  - `MAPPING.md` — Claude Code → GHCP feature translation reference
  - `INSTALL.md` — install + verify + per-OS notes
  - `TROUBLESHOOTING.md` — symptom → cause → fix
  - `ARCHITECTURE.md` — porter internals + invariants
  - `PORTING.md` — extend the porter / add plugins
- **`CONTRIBUTING.md`** with PR workflow.
- **MIT `LICENSE`** for tooling; per-plugin Apache 2.0 licenses preserved under `plugins/<P>/LICENSE`.

### Skipped (intentionally, not regressions)

- **12 LSP wrapper plugins** (`clangd-lsp`, `csharp-lsp`, `gopls-lsp`, `jdtls-lsp`, `kotlin-lsp`, `lua-lsp`, `php-lsp`, `pyright-lsp`, `ruby-lsp`, `rust-analyzer-lsp`, `swift-lsp`, `typescript-lsp`) — VS Code provides these LSPs natively.
- **3 hook/output-style-only plugins** (`explanatory-output-style`, `learning-output-style`, `security-guidance`) — GHCP has no analog for Claude Code hooks or output styles.

### Known limitations

- Claude `allowed-tools` frontmatter (e.g. `Bash(gh pr view:*)`) is dropped — GHCP uses a different tool namespace.
- Claude's `hooks/` (shell scripts) are not ported even for plugins that ship them alongside other content.
- MCP servers are staged in `plugins/<P>/mcp.json` but **not auto-merged** into user `mcp.json` (safety; user must merge by hand).
- Prompts referencing Claude-specific runtime ("Haiku agent", "Sonnet agent", `Task` tool) survive as guidance prose; they don't literally spawn sub-models under GHCP.
- Windows install is documented but not automated (see [docs/INSTALL.md#windows](docs/INSTALL.md#windows)).

### Upstream pin

Pinned to upstream `anthropics/claude-plugins-official@main` as of build date 2026-05-21. Run `./sync-from-upstream.sh` to update.
