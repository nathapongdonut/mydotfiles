# mydotfiles

Versioned Linux workstation setup (Fedora + Ubuntu, GNOME) deployed with GNU Stow and a single idempotent `install.sh`. See `CONTEXT.md` for vocabulary and `docs/adr/` for decisions.

## Prerequisites

Recent Fedora or Ubuntu (22.04/24.04/26.04-ish) with GNOME, plus `sudo` + `git` + network. Ghostty comes via COPR on Fedora; on Ubuntu it is native on 26.04+ and uses a community PPA on older releases. Without GNOME, the `gsettings` step skips cleanly.

## Getting started

```sh
git clone https://github.com/nathapongdonut/mydotfiles.git
cd mydotfiles
./install.sh
```

Re-running is safe (`stow -R` restow; package managers no-op when installed). On Stow conflicts, back up the listed files (e.g. `mv ~/.bashrc ~/.bashrc.bak`) and re-run.

## Features

- `bash` — oh-my-bash + versioned `mizuki` theme (plain-PS1 fallback), see `bash/.bashrc`
- `ghostty` — `mizuki` house theme, JetBrains Mono 12, `config-file = ?config.local` for overrides
- `tmux` — C-b prefix, true-color, mouse, Mizuki statusline, plugin-free
- `nvim` — kickstart snapshot + `lua/custom/` mizuki delta
- `gnome` — v1 minimal keys (prefer-dark, 3 favorites, Nautilus show-hidden), no extensions
- `install.sh` — idempotent restow (`-R --no-folding`), oh-my-bash clone-or-update, Ghostty stale-symlink refresh

## Update

```sh
git pull
./install.sh
```

## Verify

Manual: new shell shows the mizuki prompt, Ghostty uses the mizuki theme, `tmux` shows the Mizuki statusline. Deep check:

```sh
for f in tests/*.sh; do bash "$f"; done
```

## Uninstall

```sh
./install.sh --uninstall
```

Removes stowed links for `bash ghostty tmux nvim` only (`stow -D`). Left behind: system packages, `~/.oh-my-bash`, Local overrides, and GNOME keys. Re-run `./install.sh` to restow.

## Per-machine overrides (never commit secrets)

- `~/.bashrc.local` (see `bash/.bashrc.local.example`)
- `~/.config/ghostty/config.local` (wired via `config-file = ?config.local`)

## Layout

Repo root is the Stow directory — one package per tool, each mirroring `$HOME`:

```
├── install.sh            # distro detect (/etc/os-release) → packages → oh-my-bash → stow → gsettings (`--uninstall` to unstow)
├── bash/.bashrc          # oh-my-bash (custom mizuki theme via OSH_CUSTOM, git/ssh completions, git+bashmarks) + plain-PS1 fallback, sources ~/.bashrc.local
├── bash/.config/omb-custom/themes/mizuki/  # versioned OMB theme (Mizuki palette)
├── ghostty/.config/ghostty/config.ghostty
├── ghostty/.config/ghostty/themes/mizuki  # house theme (Mizuki palette)
├── tmux/.tmux.conf       # C-b prefix, true-color, plugin-free, Mizuki statusline
├── nvim/.config/nvim/    # kickstart snapshot + lua/custom/ delta (mizuki colorscheme)
└── gnome/gsettings.sh    # small versioned key set, no extensions in v1
```

## Docs

- `docs/research-stow-patterns.md` — Stow + multi-distro patterns
- `docs/research/ghostty-config-linux-gnome.md` — Ghostty paths and install sources
- `docs/research/kickstart-base.md` — Neovim base (vim.pack) and update flow
