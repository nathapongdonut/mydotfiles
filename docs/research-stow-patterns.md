# Research: Stow layout + multi-distro bootstrap patterns

Ticket: #2 (part of wayfinding map #1).
Date: 2026-09-06.

## TL;DR recommendation for this repo

- Repo root = stow directory; one package dir per tool: `bash/`, `ghostty/`,
  `tmux/`, `nvim/`, `gnome/`. Each package mirrors `$HOME`
  (e.g. `bash/.bashrc`, `nvim/.config/nvim/init.lua`).
- Single `install.sh`: detect distro via `/etc/os-release` (`ID=fedora|ubuntu`),
  install per-distro package lists (`dnf` vs `apt`), ensure `stow` present,
  then `stow -R -t "$HOME" <packages>` from repo root. Make it idempotent:
  `command -v` guards + `dnf/apt list --installed`-style skips, `stow -R`
  restow, `set -euo pipefail`.
- Do NOT use `--dotfiles` (`dot-` prefix) for v1 — plain dotfile names inside
  packages are the dominant convention and easier to read.

## 1. GNU Stow layout best practices

Primary source: GNU Stow manual 2.4.1, §Terminology, §Invoking Stow
(https://www.gnu.org/software/stow/manual/stow.html).

- Core model: **stow directory** (repo root) contains **package directories**
  (one per unit, e.g. `bash/`, `nvim/`); each package holds an **installation
  image** — the file tree *relative to the target directory*.
- For dotfiles the target directory is `$HOME` (`~`), not `/usr/local`.
  Run from the repo root with an explicit target:
  `stow -d <repo> -t "$HOME" <pkg>` (manual §Invoking Stow: `-d`/`--dir`,
  `-t`/`--target`).
- Inside each package, recreate the path from `$HOME`:
  `bash/.bashrc`, `nvim/.config/nvim/init.lua`. Stow symlinks into `$HOME`;
  it never copies. (Corroborated by linuxjunkies.org Stow dotfiles guide,
  2026-05-26.)
- One package per tool (`bash/`, `ghostty/`, `tmux/`, `nvim/`, `gnome/`)
  is the standard granularity; deploy individually (`stow bash git nvim`)
  or all at once. penkin/dotfiles (multi-OS Stow repo) uses exactly this
  per-tool package split with `install.sh` as idempotent updater.
- Conflict model (manual §Conflicts, §Deferred Operation): since Stow 2.0,
  conflicts are detected in a scan phase *before* mutating anything — a
  conflict aborts with no partial stow. Pre-existing real files
  (e.g. stock `~/.bashrc`) are conflicts, not overwrites. First-run story:
  back up (`*.bak`) or `stow --adopt` (manual §Invoking Stow: `--adopt`
  moves the target file into the package, then `git diff`/`restore` to
  review — see also coja/dots `install.sh -a/--adopt` flow).
- Tree folding (manual §Installing Packages): Stow may symlink whole
  directories instead of per-file links. Prefer `--no-folding` when packages
  share parent dirs (e.g. several packages under `.config/`) so one package
  never shadows another's files — coja/dots uses `--no-folding` for exactly
  this host-overlay reason.
- Updates: editing a stowed file needs no re-run (symlink points into repo);
  adding/removing files needs `stow -R <pkg>` (restow prunes dead links).
  `stow -D <pkg>` unstows; `chkstow -b` finds dangling links (manual §Target
  Maintenance).
- Ignore lists: default ignore covers `.git`, `README*`, `LICENSE*`, etc.;
  per-package `.stow-local-ignore` overrides. So keeping `README.md`,
  `install.sh`, `.git/` at repo root is safe — Stow ignores them by default
  (manual §Ignore Lists).
- Optional `.stowrc` (`--target=$HOME`, `--ignore=...`) can set defaults;
  keep CLI flags explicit in `install.sh` instead so behavior doesn't depend
  on hidden state (manual §Resource Files).

## 2. Multi-distro single `install.sh` patterns (dnf + apt)

Observed across penkin/dotfiles, sebastienrousseau/dotfiles, coja/dots:

```bash
#!/usr/bin/env bash
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Distro detect — /etc/os-release is the robust source.
#    (Fallbacks seen in the wild: /etc/fedora-release, /etc/debian_version.)
. /etc/os-release   # provides $ID (fedora | ubuntu)
case "$ID" in
  fedora) PKG_MGR=dnf ;;
  ubuntu) PKG_MGR=apt ;;
  *) echo "unsupported distro: $ID" >&2; exit 1 ;;
esac

# 2. Idempotent package install.
have() { command -v "$1" >/dev/null 2>&1; }
if [ "$PKG_MGR" = fedora ]; then
  sudo dnf install -y stow tmux neovim "${EXTRA_FEDORA[@]}"
else
  sudo apt-get update -y
  sudo apt-get install -y stow tmux neovim "${EXTRA_UBUNTU[@]}"
fi
# Guard each item with have()/rpm -q/dpkg -s if you want strict no-op
# re-runs; dnf/apt are already no-ops when the package is installed.

# 3. Stow packages (idempotent: -R restows, existing correct links are no-ops).
stow -d "$REPO" -t "$HOME" -R bash tmux nvim ghostty gnome
```

Key points:

- **Detect via `/etc/os-release` `$ID`**, not `uname` alone — `uname` can't
  separate Fedora from Ubuntu. The `ID=fedora` / `ID=ubuntu` case statement
  is the minimal shape; derivatives (`ID_LIKE`) only matter if we expand
  scope later.
- **One package-name map, two lists.** `stow`, `tmux`, `bash` share names;
  the lists diverge on Ghostty (Fedora COPR vs Ubuntu manual/.deb install)
  and Neovim versions — keep `COMMON_PKGS`, `FEDORA_PKGS`, `UBUNTU_PKGS`
  arrays at the top of the script.
- **Idempotency = `set -euo pipefail` + skip-if-present + `stow -R`.**
  penkin/dotfiles documents this explicitly: `install_packages` skips
  present tools, `stow -R` is a safe restow, re-running doubles as the
  updater (`git pull` then re-run; edited configs are live via symlinks).
- **Fail loudly on conflicts.** Don't `--adopt` by default; print the
  backup/adopt hint when `stow` exits non-zero (Stow aborts cleanly pre-change
  per §Deferred Operation, so a failed run is safe to retry).
- **Ghostty caveat:** not in default Fedora/Ubuntu repos at parity — Fedora
  via COPR, Ubuntu via .deb/manual. Isolate that in a function so the common
  path stays clean.

## 3. Minimal skeleton to copy for v1

```
repo/                  # = stow dir
├── install.sh         # distro-detect + pkg install + stow -R ...
├── bash/.bashrc
├── ghostty/.config/ghostty/config
├── tmux/.tmux.conf
├── nvim/.config/nvim/init.lua   # kickstart single-file base
└── gnome/
    ├── .config/...              # only versioned keys/assets
    └── gsettings.sh             # small gsettings applier (called by install.sh)
```

`install.sh` order: detect → install pkgs (incl. stow itself) → stow
packages → run `gnome/gsettings.sh` → print next steps (log out/in for
GNOME extensions).

## Sources

- GNU Stow manual 2.4.1 — Terminology, Invoking Stow, Installing Packages,
  Conflicts/Deferred Operation, Ignore Lists, Resource Files, Target
  Maintenance. https://www.gnu.org/software/stow/manual/stow.html
- `stow(8)` man page (Arch/Ubuntu): `--no-folding`, `--adopt`, `--dotfiles`,
  `--override` semantics. https://man.archlinux.org/man/extra/stow/stow.8.en
- penkin/dotfiles — per-tool Stow packages, idempotent `install.sh`
  (`install_packages` skip + `stow -R` restow + dangling-link prune).
  https://github.com/penkin/dotfiles
- coja/dots `install.sh` — `--no-folding`, layered stow (`common → gui →
  host` with `--override`), `-a/--adopt`, `-n` dry-run, `-D` unstow,
  idempotent re-run. https://gitea.dmz.rs/coja/dots/src/branch/main/install.sh
- linuxjunkies.org "How to Manage Dotfiles with GNU Stow" (2026-05-26) —
  `$HOME`-relative package layout, `stow -t ~ <pkg>`.
  https://linuxjunkies.org/guides/manage-dotfiles-with-stow
