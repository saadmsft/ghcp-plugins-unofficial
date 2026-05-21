# Troubleshooting

Symptom → likely cause → fix. Listed roughly in order of how often each one comes up.

---

## Slash commands / agents don't show up in chat

**Likely causes**

- VS Code wasn't reloaded after install.
- Copilot Chat isn't signed in or is on a stale build.
- Files were copied to the wrong path.

**Fix**

1. `Cmd+Shift+P` → **Developer: Reload Window**.
2. Verify the files exist on disk:
   ```bash
   ls "$HOME/Library/Application Support/Code/User/prompts/" | grep '^claude-' | wc -l
   # Expect: 47
   ```
3. Open `Settings → Copilot → Chat → Customizations` (or run the command **Chat: Open Customizations View**) and confirm the `claude-*` entries are listed.
4. If the files are present on disk but missing from the customizations view, your VS Code is reading from a different profile. Check `Settings → Profiles` and confirm the active profile matches the path the script wrote to.

---

## Skill never auto-triggers

**Likely causes**

- The skill's `description` doesn't include keywords matching your prompt.
- A higher-priority skill is matching first.
- VS Code didn't see the skill (path or reload issue — see previous entry).

**Fix**

1. Read `~/.copilot/skills/claude-<plugin>-<skill>/SKILL.md` — the `description:` line is what gets matched.
2. Try naming the skill explicitly in your prompt: *"Use the `claude-skill-creator-skill-creator` skill to …"*. If that triggers it, the description needs tuning.
3. Edit the description to include keywords *you* would naturally use, and reload.
4. If two skills compete, GHCP picks the better description match — make yours more specific or add `USE FOR: …, DO NOT USE FOR: …` clauses (this is the convention many bundled skills already follow).

---

## YAML frontmatter parse error in the customizations view

**Symptom**

VS Code highlights a `claude-*.prompt.md` with a red error like *"Invalid frontmatter"*.

**Fix**

1. `head -10` the file. The first 3 lines should be `---`, frontmatter, `---`. If any key's value contains an unescaped double-quote, that's the cause.
2. Edit the file and properly escape (`\"`). If this happens to a freshly built file (not a manual edit), it's a porter bug — file an issue with the plugin name and frontmatter content of the upstream source.

---

## "I want to roll back" — undo the install

```bash
./uninstall.sh
```

This removes every `claude-*` file the fork installed, leaving your own customizations intact. If you also want to delete the cloned repo and the upstream clone:

```bash
cd ..
rm -rf ghcp-plugins-unofficial repo
```

---

## Re-install overwrote a skill I edited locally

`install.sh` does `rm -rf <skill> && cp -R` for skills, so any in-place edits to `~/.copilot/skills/claude-…/` are lost.

**Fix**

Make your edits inside the fork at `plugins/<P>/skills/claude-<P>-<S>/` and re-run `./install.sh`. To preserve the edit across `sync-from-upstream.sh` runs (which regenerate the fork's `plugins/`), commit the change to a long-lived feature branch and rebase after each sync, or keep the override in a separate `manual-plugins/` directory (see [PORTING.md](PORTING.md#option-b)).

---

## MCP server I added to `mcp.json` doesn't work

**Likely causes**

- Forgot to reload VS Code after editing `mcp.json`.
- Server URL/command is wrong (the bundled `claude-example-plugin-example-server` points at `https://mcp.example.com/api`, which is a placeholder and **not a real server**).
- Required `inputs` (API key, etc.) aren't defined in `mcp.json`'s `inputs:` array.

**Fix**

1. Reload.
2. Check the MCP tab in Copilot Chat for connection errors.
3. For HTTP MCP servers, `curl -i <url>` to confirm reachability.
4. For stdio MCP servers (`command + args`), run the command standalone in a terminal and confirm it speaks the MCP protocol.

---

## "`./install.sh: line N: syntax error near unexpected token`"

Your `/bin/bash` is ancient (probably macOS's bash 3.2). The script is written to be 3.2-compatible, but if you somehow got a corrupt download, re-clone the repo.

If you have a custom `BASH_ENV` or `.bashrc` that messes with `set -euo pipefail`, try running explicitly with `/bin/bash ./install.sh`.

---

## `sync-from-upstream.sh` fails on `git clone` / `git fetch`

**Likely causes**

- No network.
- Upstream URL changed.
- `../repo/` exists but isn't a git checkout (e.g. you copied files in).

**Fix**

```bash
rm -rf ../repo
./sync-from-upstream.sh
```

If the upstream URL has changed, edit `sync-from-upstream.sh` and update the URL.

---

## `build-fork.py` raises `KeyError` or similar Python error

**Likely cause**

Upstream introduced a new file layout or frontmatter key the porter doesn't expect.

**Fix**

1. Open the stack trace, identify the plugin being processed.
2. Inspect the offending upstream file at `../repo/plugins/<P>/...`.
3. Either patch `build-fork.py` to handle the new shape, or add the plugin to a temporary skip-list at the top of `main()`.
4. File an issue (or PR a fix).

---

## A ported prompt references "Haiku agent" / "Sonnet agent" / `Task` tool and the behavior is weird

This is expected — see [MAPPING.md](MAPPING.md#inline-references-to-claude-specific-runtime). The prose is preserved verbatim from upstream and references Claude Code's runtime primitives that don't exist in GHCP. Treat such prompts as **guidance** rather than literal instructions. Often the high-level intent (review this PR, refactor this file, etc.) still works fine.

If a specific prompt is broken enough that it's useless, file a porting-side issue suggesting a translation (e.g. "rewrite 'spawn 5 parallel Sonnet agents' → 'review the PR considering these 5 lenses one by one'").

---

## "I want to know what was installed and where, exactly"

```bash
# Prompts and agents
ls -la "$HOME/Library/Application Support/Code/User/prompts/" | grep claude- | awk '{print $NF, "←", $5, "bytes"}'

# Skills
find "$HOME/.copilot/skills" -maxdepth 1 -name 'claude-*' -type d -exec basename {} \;

# Per-plugin inventory (what should be there)
cat plugins/<P>/plugin.json | python3 -m json.tool
```

---

Still stuck? Open an issue with:

- Output of `./install.sh --list`
- Output of `./install.sh --dry-run <plugin>` for the plugin in question
- Your VS Code version (`Help → About`)
- Your OS
- What you tried and what happened
