# code-modernization

Modernize legacy codebases (COBOL, legacy Java/C++, monolith web apps) with a structured assess → map → extract-rules → brief → reimagine/transform → harden workflow and specialist review agents

Ported from [anthropics/claude-plugins-official/code-modernization](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-modernization).

## Prompts
- `claude-code-modernization-modernize-assess.prompt.md`
- `claude-code-modernization-modernize-brief.prompt.md`
- `claude-code-modernization-modernize-extract-rules.prompt.md`
- `claude-code-modernization-modernize-harden.prompt.md`
- `claude-code-modernization-modernize-map.prompt.md`
- `claude-code-modernization-modernize-reimagine.prompt.md`
- `claude-code-modernization-modernize-transform.prompt.md`

## Agents
- `claude-code-modernization-architecture-critic.agent.md`
- `claude-code-modernization-business-rules-extractor.agent.md`
- `claude-code-modernization-legacy-analyst.agent.md`
- `claude-code-modernization-security-auditor.agent.md`
- `claude-code-modernization-test-engineer.agent.md`

## Install

```bash
./install.sh code-modernization
```
