# Submission: `code-modernization`

> Paste these values into the [external plugin issue form](https://github.com/github/awesome-copilot/issues/new?template=external-plugin.yml).

## Form fields

| Field | Value |
| --- | --- |
| **Plugin name** | `code-modernization` |
| **GitHub repository** | `saadmsft/ghcp-plugins-official` |
| **Plugin path** | `plugins/code-modernization` |
| **Immutable ref** | `refs/tags/v1.0.0` |
| **Version** | `1.0.0` |
| **License** | `MIT` |
| **Author name** | `Saad Mahmood (port of anthropics/claude-plugins-official)` |
| **Author URL** | `https://github.com/saadmsft` |
| **Homepage URL** | `https://github.com/saadmsft/ghcp-plugins-official` |

## Short description

> Modernize legacy codebases (COBOL, legacy Java/C++, monolith web apps) with a structured assess → map → extract-rules → brief → reimagine/transform → harden workflow and a team of specialist review agents (legacy-analyst, business-rules-extractor, security-auditor, architecture-critic, test-engineer).

## Keywords

```
modernization, legacy-code, refactoring, cobol, migration, architecture, code-review, test-engineering, security-audit, ai-agents
```

## Additional notes for reviewers

This plugin is part of `ghcp-plugins-official`, a community port of [`anthropics/claude-plugins-official`](https://github.com/anthropics/claude-plugins-official) reshaped for GitHub Copilot Chat in VS Code (prompts / agents / skills layout, install via `install.sh` to the VS Code user profile).

- 7 slash commands (`/modernize-assess`, `/modernize-map`, `/modernize-extract-rules`, `/modernize-brief`, `/modernize-reimagine`, `/modernize-transform`, `/modernize-harden`)
- 5 specialist sub-agents (`legacy-analyst`, `business-rules-extractor`, `security-auditor`, `architecture-critic`, `test-engineer`)
- `plugin.json` follows the Claude Code marketplace spec (top-level `commands` / `agents` / `skills` arrays); a parallel `ghcp` namespace is preserved for the repo's own VS Code installer
- Upstream: <https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-modernization>
- License: MIT
- This is a pilot submission — if approved, 20 more plugins from the same repo will be submitted using the same format
