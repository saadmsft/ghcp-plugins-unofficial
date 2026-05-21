# Claude Code → GHCP feature mapping

This is the canonical reference for how the porter (`build-fork.py`) translates each Claude Code plugin primitive into a GHCP-native equivalent. If you're debugging "why did my ported X not behave like the upstream X?", the answer is almost certainly here.

## Format translation table

| Claude Code source                       | Becomes in this fork                                   | Installed to                                    | Frontmatter changes                            |
|---|---|---|---|
| `<P>/commands/<C>.md`                    | `plugins/<P>/prompts/claude-<P>-<C>.prompt.md`        | `~/Library/.../prompts/`                       | `name`/`description` rewritten; `allowed-tools` dropped; `disable-model-invocation` dropped |
| `<P>/agents/<A>.md`                      | `plugins/<P>/agents/claude-<P>-<A>.agent.md`          | `~/Library/.../prompts/`                       | `name`/`description` rewritten; `tools` dropped; `argument-hint` preserved |
| `<P>/skills/<S>/...` (whole dir)         | `plugins/<P>/skills/claude-<P>-<S>/...` (whole dir)   | `~/.copilot/skills/claude-<P>-<S>/`            | `SKILL.md`'s `name` set to `claude-<P>-<S>`; `description` prefixed `[claude-plugins/<P>]` |
| `<P>/.mcp.json`                          | `plugins/<P>/mcp.json` (servers re-keyed `claude-<P>-…`) | **Not auto-installed** — manual merge into user `mcp.json` | None |
| `<P>/.claude-plugin/plugin.json`         | `plugins/<P>/plugin.json` (augmented)                 | Not installed (informational only)             | Preserved + GHCP inventory section added |
| `<P>/LICENSE`                            | `plugins/<P>/LICENSE`                                 | Not installed                                  | Verbatim copy |
| `<P>/hooks/` (shell scripts)             | ❌ dropped                                             | —                                              | — |
| `<P>/` matching `*output-style*`         | ❌ dropped                                             | —                                              | — |
| Plugin name ending in `-lsp`             | ❌ entire plugin skipped                               | —                                              | VS Code provides these LSPs natively |

## Naming convention

Every installed artifact is prefixed `claude-<plugin>-…`. This serves three purposes:

1. **No collision** with your own prompts/agents/skills (e.g. your existing `code-review.prompt.md` is not overwritten by `claude-code-review-code-review.prompt.md`).
2. **Reliable uninstall** — `uninstall.sh` can match by prefix.
3. **Provenance** — when a skill auto-triggers, you can see at a glance it came from this fork.

The `claude-` prefix is hard-coded in `build-fork.py`. To change it (e.g. to `anth-`), see **[PORTING.md](PORTING.md#changing-the-prefix)**.

## Frontmatter, in detail

### Prompts

**Upstream Claude command frontmatter** typically looks like:

```yaml
---
allowed-tools: Bash(gh pr view:*), Bash(gh issue list:*), Read, Grep
description: Code review a pull request
argument-hint: <pr-number>
disable-model-invocation: false
---
```

**Ported GHCP prompt frontmatter**:

```yaml
---
description: "Code review a pull request"
name: "Claude: code-review — code-review"
---
```

What changed and why:

- `allowed-tools` is dropped. GHCP uses different tool identifiers (`read`, `search`, `execute`, plus MCP tool IDs). A blanket allow-list would either be too narrow (blocking legitimate use) or too broad (overriding the user's tool preferences). The user's normal GHCP tool config wins.
- `argument-hint` is *not* preserved on prompts (GHCP's prompt schema doesn't have an equivalent). If the prompt's body asks for an argument, that prose remains.
- `name` is synthesized as `Claude: <plugin> — <command>` so the chat picker shows provenance.
- `disable-model-invocation` is Claude-specific; dropped.

### Agents

**Upstream**:

```yaml
---
name: architecture-critic
description: Reviews proposed target architectures…
tools: Read, Glob, Grep, Bash
---
```

**Ported**:

```yaml
---
description: "Reviews proposed target architectures…"
name: "Claude: code-modernization — architecture-critic"
argument-hint: "..."   # only if upstream had one
---
```

- Upstream `name` becomes part of the synthesized `name`.
- `tools` is dropped (same reason as prompts).
- `argument-hint` is preserved if present.

### Skills

Skills are copied **almost verbatim**. The directory tree is preserved (including `references/`, `scripts/`, `assets/`). Only `SKILL.md`'s frontmatter is touched:

- `name:` is rewritten to `claude-<P>-<S>` so it matches the install directory name.
- `description:` is prefixed `[claude-plugins/<P>] ` (unless it already starts with `[`), so when a skill auto-triggers you can see where it came from in the picker.

The body of `SKILL.md` is untouched. Any `references/*.md` files are untouched. Scripts inside `scripts/` are copied with permissions preserved by `cp -R`.

### MCP servers

Each upstream `.mcp.json` may use either shape:

```json
// shape A
{ "mcpServers": { "name": { … } } }

// shape B (more common in the Claude plugins repo)
{ "name": { … } }
```

The porter normalizes to a single shape with a unique key:

```json
{
  "servers": {
    "claude-<plugin>-<original-name>": { … original config preserved … }
  }
}
```

This file lands at `plugins/<P>/mcp.json` but is **not installed**. To enable, copy the entry under `servers` into your `~/Library/Application Support/Code/User/mcp.json` under that file's `servers` key, preserving any `inputs` you've defined.

Why not auto-merge?

- User `mcp.json` often contains `inputs:` with prompt-string secrets that we shouldn't risk losing or duplicating.
- Some servers take env vars or credentials that need user action anyway.
- MCP servers can execute arbitrary code on your machine — explicit consent is the safer default.

## What cannot be ported

### LSP wrapper plugins (12 of them, all skipped)

`clangd-lsp`, `csharp-lsp`, `gopls-lsp`, `jdtls-lsp`, `kotlin-lsp`, `lua-lsp`, `php-lsp`, `pyright-lsp`, `ruby-lsp`, `rust-analyzer-lsp`, `swift-lsp`, `typescript-lsp`.

These exist in Claude Code because the host CLI doesn't have a built-in editor surface — it needs an LSP bridge to get diagnostics and completions. VS Code has had first-class LSP support since launch; installing the language-specific extension (or built-in TypeScript service) gives you everything these plugins provide. There's nothing to port.

### Hooks (skipped)

Claude Code's `hooks/` directory contains shell scripts triggered on lifecycle events:

- `PreToolUse` / `PostToolUse` — before/after a tool call
- `UserPromptSubmit` — when the user sends a message
- `SessionStart` / `Stop` — lifecycle bookends
- `PreCompact` — before context compaction

GHCP exposes none of these to user code. Some plugins (`hookify`, `security-guidance`, `explanatory-output-style`, `learning-output-style`, `ralph-loop`) rely heavily on hooks; their prompt/agent/skill content is still ported, but the runtime behavior won't fully reproduce.

### Output styles (skipped)

Claude Code lets a plugin install a custom output style (preamble, tone, formatting). GHCP doesn't expose chat-output styling to plugins. The two affected plugins (`explanatory-output-style`, `learning-output-style`) ship nothing else, so they're skipped entirely.

### Inline references to Claude-specific runtime

Several prompts/agents say things like:

- "Use a Haiku agent to summarize the PR" — GHCP can't pick a specific model from inside a prompt.
- "Spawn 5 parallel Sonnet agents with the `Task` tool" — `Task` is a Claude Code primitive.
- "Run this in a `bash` sub-process via the `Bash` tool" — `Bash` is Claude's tool name; GHCP's equivalent is `execute` (run-in-terminal) which is named differently and behaves slightly differently.

These references survive porting as prose. In practice, Copilot reads them as guidance and uses whichever underlying model/tool is available. The semantics drift but the *intent* of the prompt usually still works.

## Sanity check: was this plugin ported correctly?

For any plugin `<P>`, after running `./install.sh <P>`, verify:

```bash
# Prompts and agents installed
ls "$HOME/Library/Application Support/Code/User/prompts/" | grep "^claude-<P>-"

# Skills installed
ls "$HOME/.copilot/skills/" | grep "^claude-<P>-"

# Frontmatter is well-formed (no syntax errors)
head -10 "$HOME/Library/Application Support/Code/User/prompts/claude-<P>-"*.prompt.md
```

If counts don't match the inventory in `plugins/<P>/plugin.json` under the `ghcp` key, file an issue.
