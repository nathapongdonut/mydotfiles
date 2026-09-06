#!/usr/bin/env bash
# Mydotfiles install script — see docs/adr/0001-stow-layout-single-install.md
# and CONTEXT.md (Stow directory, Package, Target, Install script, Local override).
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(bash ghostty tmux nvim gnome)

have() { command -v "$1" >/dev/null 2>&1; }

# 1. Distro detect via /etc/os-release ($ID).
if [[ ! -f /etc/os-release ]]; then
  echo "error: /etc/os-release not found, unsupported distro" >&2
  exit 1
fi
# shellcheck disable=SC1091
. /etc/os-release # provides $ID, $VERSION_ID
case "${ID:-}" in
  fedora) PKG_MGR="dnf" ;;
  ubuntu) PKG_MGR="apt" ;;
  *)
    echo "error: unsupported distro ID='${ID:-unknown}' (v1 supports fedora, ubuntu)" >&2
    exit 1
    ;;
esac

# 2. Package lists — keep COMMON / FEDORA / UBUNTU at the top.
COMMON_PKGS=(stow tmux git make unzip gcc ripgrep tree-sitter-cli wl-clipboard)
FEDORA_PKGS=(neovim fd-find xclip)
UBUNTU_PKGS=(neovim fd-find xclip)

install_ghostty_fedora() {
  have ghostty && return 0
  sudo dnf copr enable -y scottames/ghostty
  sudo dnf install -y ghostty
}

install_ghostty_ubuntu() {
  have ghostty && return 0
  # Ubuntu 26.04+ ships ghostty; older releases need the community PPA.
  ver="$(lsb_release -rs 2>/dev/null || echo "${VERSION_ID:-0}")"
  major="${ver%%.*}"
  if [[ "${major:-0}" -ge 26 ]]; then
    sudo apt-get install -y ghostty
  else
    sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu
    sudo apt-get update -y
    sudo apt-get install -y ghostty
  fi
}

if [[ "$PKG_MGR" == "dnf" ]]; then
  if ! have stow; then sudo dnf install -y stow; fi
  sudo dnf install -y "${COMMON_PKGS[@]}" "${FEDORA_PKGS[@]}"
  install_ghostty_fedora
else
  if ! have stow; then
    sudo apt-get update -y
    sudo apt-get install -y stow
  fi
  sudo apt-get update -y
  sudo apt-get install -y "${COMMON_PKGS[@]}" "${UBUNTU_PKGS[@]}"
  install_ghostty_ubuntu
fi

# 2.5. oh-my-bash — idempotent clone-or-update into $HOME (unstowed external).
# bash/.bashrc sources $OSH/oh-my-bash.sh when present, with a plain-PS1
# fallback otherwise, so a failed/absent clone never breaks the shell.
install_oh_my_bash() {
  local osh_dir="${OSH:-$HOME/.oh-my-bash}"
  local repo="https://github.com/ohmybash/oh-my-bash.git"
  if [[ -d "$osh_dir/.git" ]]; then
    git -C "$osh_dir" pull --ff-only --quiet || {
      echo "warning: could not update oh-my-bash in $osh_dir (keeping existing)" >&2
    }
  elif [[ -e "$osh_dir" ]]; then
    echo "warning: $osh_dir exists but is not a git checkout, skipping oh-my-bash install" >&2
  else
    git clone --depth 1 "$repo" "$osh_dir"
  fi
}

install_oh_my_bash

# 3. Stow packages (idempotent: -R restows, correct links are no-ops).
# --no-folding: several packages share .config/, never let one shadow another.
stow -d "$REPO" -t "$HOME" -R --no-folding "${PACKAGES[@]}" || {
  echo "" >&2
  echo "stow reported a conflict (pre-existing files, aborts cleanly pre-change)." >&2
  echo "Back up the listed files (e.g. mv ~/.bashrc ~/.bashrc.bak) and re-run," >&2
  echo "or review 'stow --adopt' first (moves targets into the repo — inspect with git diff)." >&2
  exit 1
}

# 4. GNOME keys (small versioned set only, no extensions in v1).
if have gsettings && [[ -x "$REPO/gnome/gsettings.sh" ]]; then
  "$REPO/gnome/gsettings.sh"
fi

echo "Done. Next steps:"
echo "  - Restart Ghostty / tmux (or log out/in for GNOME keys to settle)."
echo "  - Per-machine secrets go in Local overrides (never commit):"
echo "    ~/.bashrc.local, ~/.config/ghostty/config.local, lua/custom/."
