# Research: Ghostty config on Linux GNOME

Ticket: [#3](https://github.com/nathapongdonut/mydotfiles/issues/3) (part of wayfinding map #1).
Date: 2026-09-06. All claims traced to primary sources (linked per section).

## 1. Config file location (Linux)

- Canonical name is `config.ghostty` (plain `config` was the name before v1.2.3; both are still loaded, `.ghostty` first). Optional — Ghostty runs on defaults with no file.
- Linux lookup is XDG only (no macOS `~/Library/Application Support/...` path):
  - `$XDG_CONFIG_HOME/ghostty/config.ghostty`
  - `$XDG_CONFIG_HOME/ghostty/config`
  - with `XDG_CONFIG_HOME` unset defaulting to `$HOME/.config`, i.e. `~/.config/ghostty/config[.ghostty]`.
  - If both names exist they merge in order above, later values win.
- Source: [Configuration — File Location](https://ghostty.org/docs/config) (+ generated man source [`ghostty_5_header.md`](https://github.com/ghostty-org/ghostty/blob/main/src/build/mdgen/ghostty_5_header.md)).
- Practical consequences for dotfiles:
  - Version a Stow package as `ghostty/.config/ghostty/config.ghostty` (prefer the new name; keep a `config` symlink only if we must support pre-1.2.3).
  - Split with `config-file` keys (repeatable, relative paths resolve against the containing file, `?`-prefix makes an include optional — good for per-machine overrides). Note: `config-file` entries are processed at the *end* of the current file, so keys after one do not override the included file.
  - Reload at runtime with `ctrl+shift+,` (default Linux binding, `reload_config` action); some options only apply to new surfaces / require restart.
  - Source: [Configuration — Splitting into Multiple Files / Reloading](https://ghostty.org/docs/config).

## 2. Key options to version

Syntax is `key = value` (lowercase keys, `#` comments, every key is also a CLI flag, e.g. `--font-family=`). Full list: [Option Reference](https://ghostty.org/docs/config/reference). Offline copies ship in `$prefix/share/ghostty/docs`, `$prefix/share/man`, and `ghostty +show-config --default --docs`.

| Area | Knobs to version | Notes / source |
|---|---|---|
| Font | `font-family` (+ `-bold/-italic/-bold-italic` fallbacks), `font-size`, `font-feature`, `font-codepoint-map` | Default face is embedded JetBrains Mono (+ built-in nerd fonts). Repeat `font-family` for fallbacks; reset list with `font-family = ""` first. `ghostty +list-fonts` enumerates valid names. Source: [Option Reference — font-\*](https://ghostty.org/docs/config/reference). |
| Theme / colors | `theme` (name or absolute path; `light:…,dark:…` pair follows desktop theme), overrides via `background`, `foreground`, `palette` (0–255, usually 0–15 + `palette-generate`), `cursor-color`, `selection-background/-foreground`, `background-opacity`, `background-blur` | Custom themes live in `$XDG_CONFIG_HOME/ghostty/themes/`; built-ins in `share/ghostty/themes/`. `ghostty +list-themes` lists. Theme files are plain Ghostty config (but must not set `theme`/`config-file`). On Linux/GNOME, blur support is compositor-dependent (works on KDE; GNOME needs extra setup). Source: [Option Reference — theme/background/…](https://ghostty.org/docs/config/reference), [Color Theme feature](https://ghostty.org/docs/features/theme). |
| Keybindings | `keybind = trigger=action[:param]` | Triggers: `modifiers+key`, physical `KeyA`-style codes or Unicode codepoints, sequences with `>` (e.g. `ctrl+a>n=new_window`), prefixes `all:` / `unconsumed:` / `performable:` (`global:` is macOS-only). Common versioned binds: copy/paste, new window/tab/split, `reload_config`, `jump_to_prompt`. `keybind = clear` wipes defaults; `…=unbind` removes one. Inspect with `ghostty +list-keybinds [--default]`, actions with `ghostty +list-actions`. GNOME note: prefer `ctrl+shift+…` bindings to avoid colliding with GNOME Shell `super+…`. Source: [Keybindings overview](https://ghostty.org/docs/config/keybind), [Trigger Sequences](https://ghostty.org/docs/config/keybind/sequence), [Action Reference](https://ghostty.org/docs/config/keybind/reference), [Option Reference — keybind](https://ghostty.org/docs/config/reference). |
| Shell integration | `shell-integration` (`auto`/`none`/force shell name), `shell-integration-features` (e.g. `sudo`, `ssh-env,ssh-terminfo`, `no-cursor`) | Auto-injects for bash, elvish, fish, nushell, zsh (detected by basename of the executed command). Gives: no-confirm close at prompt, cwd inheritance, prompt redraw/resize, ctrl+triple-click output select, bar cursor at prompt, `jump_to_prompt`, alt+click cursor move, optional `sudo`/`ssh` wrappers (both off by default). Manual fallback (needed when switching shells mid-session, e.g. `nix-shell`): source `${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash` at the **top** of `~/.bashrc` (guarded by `[ -n "${GHOSTTY_RESOURCES_DIR}" ]`). Verify via logs (`shell integration automatically injected…`); requires `GHOSTTY_RESOURCES_DIR` → `share/ghostty` tree to resolve. Fish ≥4 / Nushell ≥0.111 already do prompt marking natively. Source: [Shell Integration](https://ghostty.org/docs/features/shell-integration), [SSH](https://ghostty.org/docs/features/ssh). |
| Command / env | `command` / `initial-command` (default shell lookup: `$SHELL` then passwd entry), `env` (`KEY=VALUE`), `working-directory` | Relevant to the bash-baseline ticket: Ghostty defers to `$SHELL`, so `install.sh` just needs the login shell right rather than hard-coding `command`. Source: [Option Reference — command/initial-command/env](https://ghostty.org/docs/config/reference). |

Minimal versioned starter (illustrative, not yet a deliverable):

```ini
# ghostty/.config/ghostty/config.ghostty
theme = light:Adwaita,dark:Catppuccin Mocha
font-family = "JetBrains Mono"
font-size = 12
keybind = ctrl+shift+c=copy_to_clipboard
keybind = ctrl+shift+v=paste_from_clipboard
keybind = ctrl+shift+t=new_tab
shell-integration-features = sudo
config-file = ?config.local
```

## 3. Install: Fedora vs Ubuntu

Upstream only ships official macOS binaries; **all Linux packages are distro/community-maintained** — file packaging bugs with the packager, not upstream. Source: [Prebuilt Binaries and Packages](https://ghostty.org/docs/install/binary).

### Fedora — no official RPM; use COPR (or Terra)

- Upstream-documented COPR: **`scottames/ghostty`**, package name **`ghostty`**:
  ```sh
  sudo dnf copr enable scottames/ghostty
  sudo dnf install ghostty
  ```
  Source: [Install › Linux (Community Binaries) › Fedora](https://ghostty.org/docs/install/binary).
- Also documented: [Terra](https://terra.fyralabs.com/) (`terra-release` repo then `dnf install ghostty`), and `rpm-ostree` instructions for Atomic/Silverblue on the same page.
- Other COPRs exist (e.g. `pgdev/ghostty`, `burhanverse/ghostty`, `gerelef/ghostty`) but are **not** the upstream-listed one — decision for `install.sh`: standardize on `scottames/ghostty` unless testing shows otherwise.
- `install.sh` sketch: `sudo dnf copr enable -y scottames/ghostty && sudo dnf install -y ghostty`.

### Ubuntu — official repo on 26.04+, community PPA/.deb below that

- **Ubuntu 26.04+**: official package, `sudo apt install ghostty` (may lag upstream — e.g. 1.3.0 in-archive vs 1.3.1 in PPA as of May 2026). Source: [Install › Ubuntu](https://ghostty.org/docs/install/binary) + [Launchpad `ubuntu/+source/ghostty`](https://launchpad.net/ubuntu/+source/ghostty).
- **Older Ubuntus (incl. 24.04 LTS)**: no official package — use the community PPA **[`mkasberg/ghostty-ubuntu`](https://github.com/mkasberg/ghostty-ubuntu)** (amd64+arm64 builds for 24.04/25.10/26.04), package name **`ghostty`**:
  ```sh
  sudo add-apt-repository ppa:mkasberg/ghostty-ubuntu
  sudo apt update
  sudo apt install ghostty
  ```
  or the one-liner `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"` per [Install › Debian and Ubuntu](https://ghostty.org/docs/install/binary).
- `install.sh` sketch: detect `lsb_release -rs` — `26.04+` → `apt install ghostty`; older → add `ppa:mkasberg/ghostty-ubuntu` first. (Alternative third-party repo `deb.griffo.io` exists but adds a paywalled-apt caveat from Oct 2026 — avoid.)
- Unverified-in-this-ticket how-to: `snap install ghostty --classic` and the universal AppImage also exist (same install page) — left as fallbacks, not the default.

## 4. What the terminal-package decision waits on (answers for map #1)

1. **Config path is stable XDG**: `~/.config/ghostty/config.ghostty` — safe to Stow as `ghostty/.config/ghostty/config.ghostty`.
2. **Small versioned surface**: font (`font-family`/`font-size`), `theme` (+ light/dark pair), a handful of `keybind`s, `shell-integration[-features]`, and shell deferral (`command` unset). Everything else stays default per Ghostty's zero-config philosophy.
3. **Install paths differ by distro and must be branched in `install.sh`**: Fedora → COPR `scottames/ghostty`; Ubuntu 26.04+ → stock `apt`; older Ubuntu → PPA `mkasberg/ghostty-ubuntu`. Package name is `ghostty` on both.
4. **Bash integration needs one line at top of `~/.bashrc`** sourcing `ghostty.bash` via `$GHOSTTY_RESOURCES_DIR` for robustness across shell-switching; auto-injection covers the default case.
