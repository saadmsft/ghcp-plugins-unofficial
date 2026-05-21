# Porting guide

How to add a new plugin, customize the porter's behavior, vendor the porter into this fork, or change the naming convention.

## Adding a new plugin from upstream

If upstream `anthropics/claude-plugins-official` adds a new plugin, the integration is automatic:

```bash
./sync-from-upstream.sh    # picks up new plugin dirs automatically
git status                 # see new plugins/<new-name>/ tree
git diff marketplace.json  # inventory delta
git add -A
git commit -m "sync: add <new-plugin>"
```

The porter walks `repo/plugins/*/` — anything new appears in the next build unless its name ends in `-lsp` or it has no portable content.

## Adding a plugin from somewhere else

If you want to port a plugin from a different Claude Code marketplace:

```bash
# Drop it into the upstream clone tree
cp -R /path/to/foreign-plugin ../repo/plugins/

# Re-run the porter
python3 ../build-fork.py

# Commit
git add -A && git commit -m "add foreign-plugin from <source>"
```

Caveat: `sync-from-upstream.sh` will overwrite `../repo/` from the official upstream on its next run, wiping your foreign plugin. To keep it durable, either:

1. Maintain a fork of `claude-plugins-official` that includes your plugin and point `sync-from-upstream.sh` at *that* URL.
2. Add a separate input root in `build-fork.py` (e.g. `LOCAL_PLUGINS = HERE / "local"`) and a second loop in `main()`.

## Authoring a GHCP-native plugin from scratch

If you want to write a new plugin that doesn't exist upstream, you have two options:

### Option A — Author Claude-style, port through the pipeline

Pros: stays in sync if you ever upstream it. Cons: porting overhead.

Create `~/some/path/<plugin>/` with the Claude layout (`commands/`, `agents/`, `skills/<name>/SKILL.md`, optional `.mcp.json` and `.claude-plugin/plugin.json`), then symlink or copy it into `../repo/plugins/` and run the porter.

### Option B — Skip Claude format, write GHCP files directly

Pros: simpler. Cons: not portable back to Claude Code.

Add a directory under `plugins/<plugin>/`:

```
plugins/my-plugin/
├── plugin.json
├── prompts/claude-my-plugin-foo.prompt.md
├── agents/claude-my-plugin-bar.agent.md
├── skills/claude-my-plugin-baz/SKILL.md
├── README.md
└── LICENSE
```

Then **add the plugin name to a manual-include list** so the porter doesn't wipe it on next sync. Two ways:

1. **Quickest**: add a guard in `build-fork.py`:
   ```python
   MANUAL_PLUGINS = {"my-plugin"}  # never wiped, never rebuilt
   ...
   if plugin in MANUAL_PLUGINS:
       continue
   ```
2. **Cleaner**: add a top-level `manual-plugins/` directory, copy your hand-written plugin there, and have `install.sh` walk both `plugins/` and `manual-plugins/`.

Either way, your plugin participates in `install.sh` normally because the install script enumerates directories on disk.

## Customizing the porter

All knobs live in `../build-fork.py`. The most common changes:

### Changing the prefix

The `claude-` prefix is hard-coded in five places (search for the string literally). The cleanest change is to introduce a constant near the top of the file:

```python
PREFIX = "claude-"   # change to "anth-", "claude-plugins-", etc.
```

Then replace each occurrence:

```python
n = f"{PREFIX}{plugin}-{f.stem}.prompt.md"
# ...
dest_name = f"{PREFIX}{plugin}-{skill_src.name}"
# ...
wrapped = {f"{PREFIX}{plugin}-{k}": v for k, v in servers.items()}
```

Also update `uninstall.sh` to match — it currently scans for matching basenames per plugin dir, so it already works prefix-agnostically as long as `install.sh` and the source tree agree.

### Including LSP plugins

Remove (or invert) the `plugin.endswith("-lsp")` check in `build_plugin`:

```python
# Remove this:
if plugin.endswith("-lsp"):
    return None
```

The LSP plugins ship `.claude-plugin/plugin.json` plus hooks/scripts that won't be ported. The result will be a near-empty `plugins/<P>/` containing just `plugin.json` and `README.md`. Probably not useful, but you can do it.

### Including hooks (when GHCP gains hook support)

Currently hooks are noted in the README and skipped. To start porting them:

1. Decide on a target convention (e.g. workspace `.vscode/tasks.json`, or some future GHCP hook schema).
2. Add a `if hooks_dir.is_dir():` branch in `build_plugin` that translates each `*.sh` into a target file.
3. Make `install.sh` copy or wire up the hook.

### Preserving Claude `allowed-tools` as guidance

If you want to keep Claude's tool restrictions visible (as documentation, not as enforcement):

```python
def emit_prompt(plugin, name, src, dst):
    fm, body = parse_fm(src.read_text(encoding="utf-8"))
    extra = ""
    if "allowed-tools" in fm:
        extra = f"\n\n> _Upstream tool restriction (informational, not enforced under GHCP):_ `{fm['allowed-tools']}`\n"
    ...
    out = [..., body.rstrip() + extra + "\n"]
```

## Vendoring the porter

If you'd rather have a single self-contained repo:

```bash
cp ../build-fork.py ./scripts/build-fork.py
# update sync-from-upstream.sh:
#   sed -i '' 's|python3 "$PARENT/build-fork.py"|python3 "$ROOT/scripts/build-fork.py"|' sync-from-upstream.sh
# update build-fork.py:
#   change UPSTREAM = HERE / "repo" / "plugins"   → HERE / ".." / "repo" / "plugins"
#   change FORK = HERE / "ghcp-plugins-unofficial"  → HERE / ".."
git add scripts/build-fork.py sync-from-upstream.sh
git commit -m "vendor: in-tree porter"
```

After this, `../repo/` is still the upstream clone location (one level up from the fork). Move it inside the fork (and add it to `.gitignore`) if you want everything in one tree.

## Syncing

`sync-from-upstream.sh` is intentionally tiny:

```bash
git clone --depth 1 https://.../claude-plugins-official.git "$UP"   # first time
# OR
git -C "$UP" fetch --depth 1 origin main && git -C "$UP" reset --hard origin/main

python3 "$PARENT/build-fork.py"
```

Run it whenever upstream releases. Review the diff before committing — sometimes upstream renames or restructures a plugin and the rename surfaces as a delete + add in the fork.

To **pin** to a specific upstream commit (e.g. for reproducible builds in CI):

```bash
( cd ../repo && git checkout <sha> )
python3 ../build-fork.py
git commit -am "pin to upstream <sha>"
```

## Contributing back

If you fix a bug in upstream content (typo, broken example), file a PR against `anthropics/claude-plugins-official` directly — don't patch it in this fork, because the next sync will overwrite it.

If you fix a bug in the *porting* (frontmatter handling, install script, missed translation), open a PR here. See [CONTRIBUTING.md](../CONTRIBUTING.md).
