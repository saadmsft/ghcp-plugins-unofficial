# Submission: `agent-sdk-dev`

> Paste these values into the [external plugin issue form](https://github.com/github/awesome-copilot/issues/new?template=external-plugin.yml).

## Form fields

| Field | Value |
| --- | --- |
| **Plugin name** | `agent-sdk-dev` |
| **GitHub repository** | `saadmsft/ghcp-plugins-unofficial` |
| **Plugin path** | `plugins/agent-sdk-dev` |
| **Immutable ref** | `refs/tags/v1.0.0` |
| **Version** | `1.0.0` |
| **License** | `MIT` |
| **Author name** | `Saad Mahmood (port of anthropics/claude-plugins-official)` |
| **Author URL** | `https://github.com/saadmsft` |
| **Homepage URL** | `https://github.com/saadmsft/ghcp-plugins-unofficial` |

## Short description

> Build and verify applications with the Claude Agent SDK. Includes a scaffolding slash command for new SDK apps plus Python and TypeScript verifier agents that check configuration, best practices, and readiness for deployment.

## Keywords

```
agent-sdk, claude-agent-sdk, python, typescript, scaffolding, verifier, ai-agents, code-review
```

## Additional notes for reviewers

Part of `ghcp-plugins-unofficial`, a community port of [`anthropics/claude-plugins-official`](https://github.com/anthropics/claude-plugins-official) reshaped for GitHub Copilot Chat in VS Code.

- 1 slash command (`/new-sdk-app`)
- 2 sub-agents: `agent-sdk-verifier-py`, `agent-sdk-verifier-ts`
- `plugin.json` follows the Claude Code marketplace spec; a parallel `ghcp` namespace is preserved for the repo's own VS Code installer
- Upstream: <https://github.com/anthropics/claude-plugins-official/tree/main/plugins/agent-sdk-dev>
- License: MIT
