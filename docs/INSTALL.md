# Install guide

Detailed install, verification, and per-OS notes.

## Prerequisites

- **VS Code** with the **GitHub Copilot Chat** extension installed and signed in.
- **Bash 4+** (macOS ships with Bash 3.2 by default — `install.sh` is written to work with 3.2; if you've upgraded to bash 4/5 via Homebrew, that also works).
- **Python 3.8+** (only needed if you re-run `build-fork.py` via `sync-from-upstream.sh`).
- **git** (for cloning + syncing).
- ~5 MB free disk in your VS Code user profile directory and `~/.copilot/skills/`.

## Step-by-step (macOS / Linux)

```bash
# 1. Clone this fork
git clone <repo-url> ghcp-plugins-official
cd ghcp-plugins-official

# 2. Look around
./install.sh --list                   # see all 21 plugin names
cat marketplace.json | jq '.plugins[].name'   # same data, structured

# 3. Preview before writing anything
./install.sh --dry-run                # preview install of ALL plugins
./install.sh --dry-run code-review    # preview install of one plugin

# 4. Install (idempotent — safe to re-run)
./install.sh                          # all
./install.sh code-review feature-dev  # specific subset

# 5. Reload VS Code so it picks up the new files
#    Cmd+Shift+P → "Developer: Reload Window"
```

## Verifying the install

After reloading VS Code:

1. Open Copilot Chat (`Ctrl/Cmd+Alt+I`).
2. Type `/` — you should see entries beginning with `claude-` (e.g. `/claude-code-review-code-review`).
3. Type `@` — agents appear as `Claude: <plugin> — <agent>`.
4. Skills don't show in any picker; they fire automatically based on the user's prompt text matching their description.

Programmatic verification (terminal):

```bash
# Prompts/agents in your user profile
ls "$HOME/Library/Application Support/Code/User/prompts/" | grep -c '^claude-'
# Expect: 47  (26 prompts + 21 agents)

# Skills in your copilot skills dir
ls "$HOME/.copilot/skills/" | grep -c '^claude-'
# Expect: 22

# Spot-check one frontmatter
head -5 "$HOME/Library/Application Support/Code/User/prompts/claude-code-review-code-review.prompt.md"
```

If any count is off, run `./install.sh --dry-run` to see what *would* be copied vs what is actually present.

## Per-OS notes

### macOS

The default. `install.sh` auto-detects `Darwin` via `uname -s` and writes to:

- `~/Library/Application Support/Code/User/prompts/`
- `~/Library/Application Support/Code/User/mcp.json`
- `~/.copilot/skills/`

The folder path contains a space, hence the careful quoting in the script.

### Linux (including WSL)

`install.sh` falls back to XDG paths:

- `${XDG_CONFIG_HOME:-$HOME/.config}/Code/User/prompts/`
- `${XDG_CONFIG_HOME:-$HOME/.config}/Code/User/mcp.json`
- `~/.copilot/skills/`

VS Code Insiders uses `Code - Insiders/` instead of `Code/` — override by exporting `XDG_CONFIG_HOME` before running, or edit the path constants in `install.sh`.

### Windows

`install.sh` does not auto-detect Windows. The equivalent target paths are:

- `%APPDATA%\Code\User\prompts\`
- `%APPDATA%\Code\User\mcp.json`
- `%USERPROFILE%\.copilot\skills\`

Two options:

1. **Run from WSL** against the Windows VS Code install — set `XDG_CONFIG_HOME` to the Windows mount before running (`export XDG_CONFIG_HOME=/mnt/c/Users/<you>/AppData/Roaming`).
2. **Use PowerShell manually**:

   ```powershell
   $dst = "$env:APPDATA\Code\User\prompts"
   $skills = "$env:USERPROFILE\.copilot\skills"
   New-Item -ItemType Directory -Force -Path $dst, $skills | Out-Null

   Get-ChildItem .\plugins -Directory | ForEach-Object {
       $p = $_.FullName
       Get-ChildItem "$p\prompts" -Filter *.prompt.md -ErrorAction SilentlyContinue |
           ForEach-Object { Copy-Item $_.FullName "$dst\$($_.Name)" -Force }
       Get-ChildItem "$p\agents" -Filter *.agent.md -ErrorAction SilentlyContinue |
           ForEach-Object { Copy-Item $_.FullName "$dst\$($_.Name)" -Force }
       Get-ChildItem "$p\skills" -Directory -ErrorAction SilentlyContinue |
           ForEach-Object {
               $target = "$skills\$($_.Name)"
               if (Test-Path $target) { Remove-Item $target -Recurse -Force }
               Copy-Item $_.FullName $target -Recurse
           }
   }
   ```

A native `install.ps1` is on the wishlist — see [CONTRIBUTING.md](../CONTRIBUTING.md).

## MCP servers

`install.sh` **never** writes to your user `mcp.json` automatically. Any plugin that ships an MCP server will surface a notice at the end of an install run:

```
MCP servers were found in: .../plugins/example-plugin/mcp.json
Review and manually merge into: ~/Library/Application Support/Code/User/mcp.json
```

To merge by hand:

1. Open `~/Library/Application Support/Code/User/mcp.json` in VS Code.
2. Open the source `plugins/<P>/mcp.json`.
3. Copy each entry under `servers` from the plugin file into your user file's `servers` object, taking care not to clobber existing keys.
4. If the server requires inputs (API keys, URLs), add the prompt-string definitions under your user file's `inputs` array.
5. Reload VS Code.

**Currently shipped MCP servers**:

- `claude-example-plugin-example-server` — URL points at `https://mcp.example.com/api` (placeholder). Don't install; it's a template only.

Future upstream additions (e.g. `mcp-tunnels` if it ever ships a server config) will appear here automatically after running `sync-from-upstream.sh`.

## Uninstalling

```bash
./uninstall.sh                          # remove ALL claude-* artifacts from your profile
./uninstall.sh hookify                  # remove just one plugin
./uninstall.sh hookify code-modernization   # remove several
```

`uninstall.sh` removes only files that match the manifest of the named plugin — your own customizations (anything not prefixed `claude-…` or installed by a different plugin) are not touched.

If you want to *fully* reset (uninstall + delete the fork):

```bash
./uninstall.sh
cd ..
rm -rf ghcp-plugins-official repo
```

## Common issues

See **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** for symptom→fix recipes. Quick hits:

- **Slash commands don't appear** → did you reload VS Code? (`Cmd+Shift+P` → "Developer: Reload Window")
- **Skill never triggers** → the description may not match your phrasing; try saying the skill's keywords explicitly, or edit the description.
- **Frontmatter parse error in VS Code's customizations view** → file a bug with the plugin name; `build-fork.py` is supposed to produce valid YAML.
