#!/usr/bin/env bash
# Seam: install.sh Ghostty theme handling (filesystem boundary).
# Spec: ADR-0001 fails loudly on conflicts (backup/--adopt hint), no silent
# overwrites; reinstall preserves old configs not in repo.
# ADR-0002: theme delivery is stowed files only.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load only the function under test, not the whole Install script
# (whole script would run dnf/apt/stow side effects).
load_fn() {
  local tmp
  tmp="$(mktemp)"
  sed -n '/^refresh_ghostty_themes()/,/^}/p' "$REPO/install.sh" > "$tmp"
  # shellcheck disable=SC1090
  source "$tmp"
  rm -f "$tmp"
}

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }

load_fn

# 1. Reinstall preserves a user regular file not in repo (must NOT delete).
FAKE_HOME="$(mktemp -d)"
export HOME="$FAKE_HOME"
mkdir -p "$HOME/.config/ghostty/themes"
echo "user hand-placed theme" > "$HOME/.config/ghostty/themes/mizuki"
refresh_ghostty_themes
[[ -f "$HOME/.config/ghostty/themes/mizuki" ]] || fail "regular file was deleted (silent overwrite)"
[[ "$(cat "$HOME/.config/ghostty/themes/mizuki")" == "user hand-placed theme" ]] || fail "regular file content changed"
pass "reinstall preserves regular file not in repo"

# 2. Stale symlink IS cleared so stow can link fresh (clean install path).
rm -f "$HOME/.config/ghostty/themes/mizuki"
ln -s /nonexistent-old-target "$HOME/.config/ghostty/themes/mizuki"
refresh_ghostty_themes
[[ ! -e "$HOME/.config/ghostty/themes/mizuki" && ! -L "$HOME/.config/ghostty/themes/mizuki" ]] || fail "stale symlink was not cleared"
pass "stale symlink cleared for stow"

# 3. Unrelated old configs survive reinstall.
echo "old stuff" > "$HOME/.config/ghostty/themes/my-old-theme"
refresh_ghostty_themes
[[ "$(cat "$HOME/.config/ghostty/themes/my-old-theme")" == "old stuff" ]] || fail "unrelated old config touched"
pass "unrelated old config preserved"

# 4. Missing path is a no-op (clean install with no prior theme).
rm -rf "$HOME/.config/ghostty/themes"
mkdir -p "$HOME/.config/ghostty/themes"
refresh_ghostty_themes
pass "missing theme path is no-op"

rm -rf "$FAKE_HOME"
echo "All ghostty theme tests passed."
