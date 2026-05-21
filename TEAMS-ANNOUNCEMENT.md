# Teams Announcement — `ghcp-plugins-official`

> Casual + enthusiastic tone for Microsoft internal channels. Copy whichever variant fits.

---

## Variant A — Short (post in a team channel)

> 🔌 **Shipped something fun this weekend:** `ghcp-plugins-official` — a port of Anthropic's official Claude Code plugin pack reshaped for **GitHub Copilot Chat in VS Code**.
>
> **21 plugins · 26 prompts · 21 agents · 22 skills**, all installable into your VS Code user profile with one shell script.
>
> 👉 <https://github.com/saadmsft/ghcp-plugins-official>
>
> ```bash
> git clone https://github.com/saadmsft/ghcp-plugins-official
> cd ghcp-plugins-official && ./install.sh
> ```
>
> Highlights: `code-modernization` (legacy → modern with a 5-agent review crew), `agent-sdk-dev` (scaffold + verify Agent SDK apps), `skill-creator` (meta — Copilot writes its own skills), `commit-commands`, `pr-review-toolkit`, `ralph-loop`, and more.
>
> ⭐ Stars, issues, and PRs all welcome. Also submitting the first three to **github/awesome-copilot** — feedback before I open those issues is super appreciated.

---

## Variant B — Longer (post in a community channel, e.g. AI@MS / Copilot interest groups)

> 🎁 **`ghcp-plugins-official` — Anthropic's official plugin pack, ported to GitHub Copilot Chat**
>
> Hey folks 👋 — sharing a side project that might be useful if you live in VS Code + Copilot Chat.
>
> Anthropic recently open-sourced `claude-plugins-official` (21 plugins covering code modernization, agent development, PR review, skill creation, MCP server dev, hooks, etc.). I forked and reshaped the whole thing for **GitHub Copilot** — same content, GHCP-native layout (prompts / agents / skills / MCP), one-command install into your VS Code user profile.
>
> **Repo:** <https://github.com/saadmsft/ghcp-plugins-official>
>
> **What's in it:**
> - **21 plugins** · 26 prompts · 21 agents · 22 skills
> - MIT-licensed, mirrors the upstream Anthropic license
> - Self-documenting README with architecture diagrams + a "Pantheon" emoji index for every plugin (Hermes ⚡ = `commit-commands`, Hephaestus 🔨 = `agent-sdk-dev`, Argonauts ⛵ = `code-modernization`, Sisyphus 🔁 = `ralph-loop`, Athena 🦉 = `skill-creator`, …)
> - Full `docs/` folder: ARCHITECTURE, GHCP-PRIMER, INSTALL, MAPPING (Claude → GHCP shape), PORTING, TROUBLESHOOTING
> - `sync-from-upstream.sh` so it stays current with Anthropic's repo
>
> **Try it:**
> ```bash
> git clone https://github.com/saadmsft/ghcp-plugins-official
> cd ghcp-plugins-official
> ./install.sh         # installs to ~/Library/Application Support/Code/User/
> # then in VS Code Chat: /modernize-assess, /commit, @argonauts, etc.
> ```
>
> **Top 5 to try first:**
> 1. `code-modernization` — assess → map → extract-rules → reimagine → harden, with 5 specialist review agents
> 2. `pr-review-toolkit` — silent-failure hunter, type-design analyzer, test analyzer, comment analyzer
> 3. `agent-sdk-dev` — scaffold + verify Claude Agent SDK apps (Python + TS)
> 4. `skill-creator` — Copilot writes & evaluates its own skills
> 5. `ralph-loop` — the "Sisyphus" continuous-improvement loop
>
> **What's next:**
> - Pilot submission to [`github/awesome-copilot`](https://github.com/github/awesome-copilot) for 3 flagship plugins (code-modernization, agent-sdk-dev, skill-creator), then the rest if those land
> - Open to ideas for MS-specific plugins (Azure modernization? M365 agent dev? Foundry workflow?) — drop a thumbs-up or comment with what you'd want
>
> ⭐ Star if it's useful, file issues for what's broken, PRs welcome. Happy to walk anyone through it 1:1.

---

## Variant C — One-liner (DMs / quick share)

> Built a thing: `ghcp-plugins-official` — Anthropic's 21 Claude Code plugins, reshaped for GitHub Copilot Chat in VS Code. One script installs them all. https://github.com/saadmsft/ghcp-plugins-official ⭐

---

## Posting checklist

- [ ] Pick the variant that fits the channel (A for team channels, B for community / interest-group channels, C for DMs)
- [ ] Replace `https://github.com/saadmsft/ghcp-plugins-official` with the canonical link if the repo gets renamed/transferred
- [ ] Optional: attach a screenshot of the README hero + Pantheon table for visual impact
- [ ] If posting in an official Microsoft channel, mention it's a personal side project (not an MS-owned repo) — keeps comms-policy clean
