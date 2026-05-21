# Contributing

Thanks for considering a contribution. The scope of this fork is narrow: **port Claude Code plugins to GitHub Copilot for VS Code**. Issues and PRs that match that scope are welcome.

## What belongs here

- **Bugs in the porter** — frontmatter mis-handled, files missed, incorrect prefixes, broken `install.sh` on a supported OS.
- **Porter improvements** — better translation of Claude-specific constructs, support for new GHCP customization types as VS Code adds them.
- **Docs fixes** — typos, missing context, outdated commands.
- **Install/uninstall script enhancements** — Windows PowerShell support, dry-run modes, better error messages.
- **Test harness** — there isn't one yet; PRs to add fixtures + a golden-output diff would be very welcome.

## What does NOT belong here

- **Bugs in plugin *content*** (typos in a Claude command body, wrong commit-message template, etc.) — file those against [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official). They flow into this fork on the next sync.
- **New plugins not present upstream** — see [docs/PORTING.md](docs/PORTING.md#authoring-a-ghcp-native-plugin-from-scratch). The fork can host them, but coordinate first so they don't get clobbered by sync.
- **GHCP feature requests** — file those with [`github/vscode-copilot-chat`](https://github.com/microsoft/vscode-copilot-chat).

## Development workflow

```bash
# 1. Clone and set up
git clone <your-fork-url> ghcp-plugins-unofficial
cd ghcp-plugins-unofficial

# 2. Pull upstream Claude plugins (one-time)
./sync-from-upstream.sh

# 3. Make changes (probably to ../build-fork.py)
$EDITOR ../build-fork.py

# 4. Rebuild
python3 ../build-fork.py

# 5. Verify
git diff                              # see what changed in the fork
./install.sh --dry-run code-review    # smoke-test install path
./install.sh code-review              # actual install
# Reload VS Code and try the prompt

# 6. Commit + PR
git add -A
git commit -m "fix(porter): handle nested skills in skill-creator"
git push
gh pr create
```

## Invariants you must preserve

If you touch the porter, your change must keep all of these true (see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md#invariants-the-porter-maintains) for full reasoning):

1. **Deterministic** — re-running produces byte-identical output.
2. **Idempotent** — re-running on top of previous output yields the same thing.
3. **No upstream mutation** — `../repo/` is read-only.
4. **No collisions** — every installed artifact name unique via `claude-<P>-` prefix.
5. **Lossless metadata** — upstream `plugin.json` content preserved verbatim inside generated `plugin.json`.
6. **License preservation** — per-plugin LICENSE files unchanged.
7. **Body preservation** — only frontmatter is rewritten in prompts/agents; skill bodies and bundled resources untouched.

If your change breaks (1) or (2), the next `git diff` after a clean re-build will be noisy and CI (if/when added) will fail.

## Commit message convention

Loose convention:

```
<type>(<scope>): <short summary>

[optional body]
```

`<type>` is one of `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `sync`.
`<scope>` is one of `porter`, `install`, `docs`, `<plugin-name>`, or omit for repo-wide.

Examples:

```
sync: 2026-05-21 upstream pull
fix(porter): handle skills with no SKILL.md frontmatter
docs(install): add Windows PowerShell recipe
feat(install): add --user/--workspace target flag
```

## Reviewing your own PR before opening it

- [ ] Did `build-fork.py` exit 0?
- [ ] Does `git diff` look the way you expected, with no noise from unrelated plugins?
- [ ] Did you update [CHANGELOG.md](CHANGELOG.md)?
- [ ] If you added a flag to `install.sh`, did you update [docs/INSTALL.md](docs/INSTALL.md) and the script's `--help` text?
- [ ] If you changed the prefix or naming convention, did you update [docs/MAPPING.md](docs/MAPPING.md) and `uninstall.sh`?
- [ ] Did you reload VS Code and confirm the affected plugins still load?

## License of contributions

By submitting a PR, you agree your contributions are licensed under MIT (for tooling/docs) or remain under their original Apache 2.0 (for content sourced from upstream). See [LICENSE](LICENSE).
