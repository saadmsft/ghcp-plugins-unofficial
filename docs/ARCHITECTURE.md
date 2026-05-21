# Architecture

How the porter works, why files live where they do, and what invariants the build process maintains.

## Component map

```
┌────────────────────────────────────────────────────────────────────┐
│  /Users/saadmahmood/Documents/ClaudePlugins/                       │
│  (parent workspace — not the fork itself)                          │
│                                                                    │
│   repo/                       ← shallow clone of upstream          │
│   └── plugins/<P>/...           (gitignored input — fully regen.)  │
│                                                                    │
│   build-fork.py               ← THE PORTER (single Python file)    │
│                                                                    │
│   port.py                     ← legacy direct-to-profile installer │
│   port-report.md              ←  (from the first session)          │
│   mcp-to-merge.json           ←                                    │
│                                                                    │
│   ghcp-plugins-official/      ← THE FORK (this git repo)           │
│   ├── plugins/<P>/...           (regenerated from build-fork.py)   │
│   ├── install.sh                                                   │
│   ├── uninstall.sh                                                 │
│   ├── sync-from-upstream.sh                                        │
│   ├── marketplace.json                                             │
│   ├── README.md, CHANGELOG.md, LICENSE, CONTRIBUTING.md            │
│   └── docs/*.md                                                    │
└────────────────────────────────────────────────────────────────────┘
```

**Why is `build-fork.py` outside the fork?** Two reasons:

1. The fork is meant to be installable by users who shouldn't have to think about the porter. Keeping build tooling outside the repo means `git clone <fork>` → `./install.sh` works without needing Python at all.
2. The porter is treated as a *build system* for the fork, the same way generated files in many projects sit alongside (not inside) the source. The fork's `sync-from-upstream.sh` is the in-repo bridge that calls back out to the porter.

If you want to vendor the porter into the fork, see [PORTING.md](PORTING.md#vendoring-the-porter).

## Data flow

```
upstream GitHub repo
       │  git clone --depth 1 (or fetch+reset)
       ▼
   ../repo/plugins/<P>/                    ← INPUT
       │
       │  build-fork.py iterates each plugin dir
       │   ┌─ skip if name ends in -lsp
       │   ├─ skip if no commands/agents/skills/.mcp.json
       │   ├─ for cmd:    parse frontmatter, rewrite, emit prompt.md
       │   ├─ for agent:  parse frontmatter, rewrite, emit agent.md
       │   ├─ for skill:  copytree, rewrite SKILL.md frontmatter
       │   ├─ for mcp:    parse JSON, re-key with claude-<P>- prefix
       │   └─ emit plugin.json, README.md per plugin
       ▼
   ghcp-plugins-official/plugins/<P>/...    ← OUTPUT (committed)
       │
       │  install.sh copies into user profile
       ▼
   ~/Library/.../prompts/  +  ~/.copilot/skills/  +  (manual) mcp.json
```

## Invariants the porter maintains

These are properties that *must* hold for any successful build. If you change `build-fork.py`, keep them.

1. **Deterministic** — running `build-fork.py` twice against the same upstream commit produces byte-identical output. No timestamps, no random ordering. Achieved by `sorted()` over directory listings throughout.
2. **Idempotent** — running it on top of a previously built tree yields the same result as a clean build. Per-plugin output directories are wiped (`shutil.rmtree`) before being rewritten.
3. **No upstream mutation** — `../repo/` is read-only from the porter's perspective.
4. **No collisions** — every installed artifact name is unique because of the `claude-<P>-` prefix.
5. **Lossless metadata** — upstream `.claude-plugin/plugin.json` is preserved verbatim inside the generated `plugin.json` (no destructive merge), plus a `ghcp:` inventory section is added.
6. **License preservation** — upstream `LICENSE` files are copied to `plugins/<P>/LICENSE` verbatim.
7. **No body changes** — prompt/agent/skill *bodies* are passed through unchanged. Only frontmatter is rewritten.

## File responsibilities

| File | Lines | Owns |
|---|---:|---|
| `../build-fork.py` | ~150 | All porting logic. Input → output. |
| `install.sh` | ~80 | Copy fork → user profile. No porting. |
| `uninstall.sh` | ~30 | Reverse of install. |
| `sync-from-upstream.sh` | ~15 | Thin shim: `git clone/fetch` then `python3 build-fork.py`. |
| `plugins/<P>/plugin.json` | ~10 each | Per-plugin manifest + GHCP inventory. Read by `install.sh` indirectly (it walks directories, not the manifest), but useful for tooling/UI. |
| `marketplace.json` | ~250 | Aggregate index. Generated. Consumed by potential future marketplace UIs. |

## Frontmatter parser

The porter ships a tiny single-purpose YAML parser (`parse_fm` in `build-fork.py`):

```python
FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---\n?(.*)$", re.DOTALL)
```

It only handles top-level `key: value` lines, no nested structures, no flow style, no anchors. This is *intentional*:

- Claude plugin frontmatter is consistently simple.
- A real YAML parser (`PyYAML`) would be a dependency just to read 4-line headers.
- Misformatted upstream frontmatter would be silently "corrected" by a real parser; our parser preserves the original body exactly when frontmatter is absent or malformed.

If upstream ever introduces nested frontmatter, the parser will need to be replaced with `pyyaml`. See `build-fork.py:parse_fm` for the swap point.

## Test strategy (current state)

There's no automated test suite yet. The build is verified by:

1. `python3 build-fork.py` exits 0.
2. `marketplace.json` totals match a hand-computed count from `repo/plugins/`.
3. `head -5` on a handful of generated files shows well-formed frontmatter.
4. VS Code loads the installed files without surfacing errors in the customizations view.

A future improvement is a `tests/` directory with:

- A fixture `upstream-fixture/` with a tiny synthetic plugin.
- Golden output to diff against.
- Per-frontmatter-edge-case unit tests for `parse_fm`.

Contributions welcome — see [CONTRIBUTING.md](../CONTRIBUTING.md).

## Future-proofing notes

- **If GHCP adds a `tools:` schema on prompts** — update `emit_prompt`/`emit_agent` to translate Claude's `allowed-tools` into the new schema instead of dropping it.
- **If GHCP adds hooks** — un-skip the `hooks/` directory in `build_plugin` and emit them.
- **If upstream changes plugin layout** (e.g. moves `commands/` → `prompts/` themselves) — the porter's per-directory checks are independent, so only the source paths need to update.
- **If you want workspace-scope install instead of user-scope** — `install.sh` would copy to `.github/prompts/` and `.copilot/skills/` inside the current workspace instead. The fork structure doesn't need to change.
