# mydotfiles

Versioned Linux workstation setup (Fedora + Ubuntu, GNOME) deployed with GNU Stow and a single idempotent `install.sh`. See `CONTEXT.md` for vocabulary and `docs/adr/` for decisions.

## Layout

Repo root is the Stow directory — one package per tool, each mirroring `$HOME`:

```
├── install.sh            # distro detect (/etc/os-release) → packages → oh-my-bash → stow → gsettings
├── bash/.bashrc          # oh-my-bash (custom mizuki theme via OSH_CUSTOM, git/ssh completions, git+bashmarks) + plain-PS1 fallback, sources ~/.bashrc.local
├── bash/.config/omb-custom/themes/mizuki/  # versioned OMB theme (Mizuki palette)
├── ghostty/.config/ghostty/config.ghostty
├── ghostty/.config/ghostty/themes/mizuki  # house theme (Mizuki palette)
├── tmux/.tmux.conf       # C-b prefix, true-color, plugin-free, Mizuki statusline
├── nvim/.config/nvim/    # kickstart snapshot + lua/custom/ delta (mizuki colorscheme)
└── gnome/gsettings.sh    # small versioned key set, no extensions in v1
```

## Quickstart

```sh
git clone https://github.com/nathapongdonut/mydotfiles.git
cd mydotfiles
./install.sh
```

Re-running is safe (`stow -R` restow; package managers no-op when installed). On Stow conflicts, back up the listed files (e.g. `mv ~/.bashrc ~/.bashrc.bak`) and re-run.

## Per-machine overrides (never commit secrets)

- `~/.bashrc.local` (see `bash/.bashrc.local.example`)
- `~/.config/ghostty/config.local` (wired via `config-file = ?config.local`)
- `nvim/.config/nvim/lua/custom/` (see its README for the 3-line `vim.pack.add` pattern)

## Docs

- `docs/research-stow-patterns.md` — Stow + multi-distro patterns
- `docs/research/ghostty-config-linux-gnome.md` — Ghostty paths and install sources
- `docs/research/kickstart-base.md` — Neovim base (vim.pack) and update flow
