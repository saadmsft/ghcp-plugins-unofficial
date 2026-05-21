# GHCP customization primer

> If you've never worked with GitHub Copilot Chat's customization files in VS Code, read this first. Everything in this fork builds on these four primitives.

## The four building blocks

GHCP in VS Code supports four kinds of user-authored content that live as plain files on disk:

| Kind | File pattern | Loaded… | Invoked by | Use for |
|---|---|---|---|---|
| **Prompt** | `*.prompt.md` | On demand | Typing `/<name>` in chat | Slash commands / reusable task templates |
| **Agent** | `*.agent.md` | On demand | Typing `@<name>` in chat, or via subagent tool | Specialist personas (reviewer, planner, tester) |
| **Skill** | `<name>/SKILL.md` | Description is always in context; body loads when triggered | Auto, by description match against user prompt | Domain knowledge that should fire *without* being explicitly named |
| **Instructions** | `*.instructions.md` with `applyTo:` glob | Auto, when an edited file matches `applyTo` | Implicit | "Whenever I touch a `**/*.tsx` file, remember these conventions" |

There's also **MCP servers** — out-of-process tool providers configured via `mcp.json` — but those are tools, not text customizations.

## Where the files live

On macOS (Linux paths use `~/.config/Code/User/` instead of `~/Library/Application Support/Code/User/`):

```
~/Library/Application Support/Code/User/
├── prompts/
│   ├── *.prompt.md         ← user-scope prompts
│   ├── *.agent.md          ← user-scope agents
│   └── *.instructions.md   ← user-scope instructions
└── mcp.json                ← user-scope MCP servers

~/.copilot/
└── skills/
    └── <skill-name>/
        ├── SKILL.md
        ├── references/     ← optional bundled markdown the skill can `read_file`
        ├── scripts/        ← optional bundled scripts
        └── assets/         ← optional bundled binaries (images, templates, …)
```

Workspace-scope equivalents live under `<workspace>/.github/` and `<workspace>/.copilot/`. This fork installs into **user scope** (global, all workspaces) by default.

## Frontmatter cheat sheet

### Prompt (`*.prompt.md`)

```markdown
---
description: "One-sentence description of what this prompt does."
name: "Human-readable title"
---

The body of the prompt. Plain Markdown. Treated as the user message
when the slash command is invoked.
```

### Agent (`*.agent.md`)

```markdown
---
description: "When should the agent be used? What does it specialize in?"
name: "Display Name"
argument-hint: "Optional hint shown in the chat picker"
---

You are <persona>. Your job is to <responsibility>. …
```

The body is the agent's **system prompt**. It runs as a subagent when invoked.

### Skill (`<name>/SKILL.md`)

```markdown
---
name: my-skill-name
description: When to trigger this skill. The description is matched against user prompts to decide whether to load the body. Be specific about WHEN to use it ("USE FOR: …, DO NOT USE FOR: …").
---

# Skill body (Markdown, no length limit)

Procedural knowledge, references to bundled files in `references/`, etc.
```

The `description` is the **only** thing always in context — keep it punchy and use trigger keywords.

### Instructions (`*.instructions.md`)

```markdown
---
description: "Brief summary shown in the customizations UI."
applyTo: "**/*.tsx, **/components/**"
---

# Conventions
- Always prefer …
- Never …
```

`applyTo` is a glob (or comma-separated globs). The body is injected when any edited/viewed file matches.

## Loading model

- **Prompts / agents / instructions** load their full body when triggered. They count against context — keep them tight.
- **Skills** use *progressive disclosure*: the `description` (≈100 words, always loaded) decides whether the body (up to ~500 lines is the soft cap) loads. Bundled `references/` files are pulled in only when the skill's body chooses to read them.
- **MCP servers** expose **tools**, which are listed in the tool catalog but only consume context when called.

## How Claude Code maps onto these

| Claude Code primitive | GHCP equivalent | Notes |
|---|---|---|
| `/commands/<cmd>.md` (slash command) | `*.prompt.md` | Frontmatter sanitized — Claude's `allowed-tools` is dropped |
| `/agents/<agent>.md` (sub-agent) | `*.agent.md` | Body preserved verbatim |
| `/skills/<skill>/SKILL.md` | `~/.copilot/skills/<name>/SKILL.md` | Whole directory copied including resources |
| `.mcp.json` | Entries in `mcp.json` | **Not auto-merged** in this fork |
| `hooks/` (shell scripts) | ❌ no equivalent | Dropped |
| Output styles | ❌ no equivalent | Dropped |
| `.claude-plugin/plugin.json` | `plugins/<P>/plugin.json` (informational) | Not loaded by VS Code; preserved for traceability |

Full per-file translation: **[MAPPING.md](MAPPING.md)**.

## Further reading

- VS Code Copilot Chat customization docs: <https://code.visualstudio.com/docs/copilot/copilot-customization>
- Claude Code plugins reference: <https://code.claude.com/docs/en/plugins>
- This fork's per-plugin READMEs at `plugins/<name>/README.md`
