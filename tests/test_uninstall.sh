#!/usr/bin/env bash
# Seam: Uninstall flag (user-facing removal boundary).
# Spec: ./install.sh --uninstall unstows exactly PACKAGES (bash ghostty tmux
# nvim) via `stow -D`, symlinks only. Leaves GNOME keys, system packages,
# ~/.oh-my-bash, and Local overrides (*.local) in place with a message.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }

grep -q -- "--uninstall" "$REPO/install.sh" || fail "install.sh has no --uninstall handling"
pass "install.sh handles --uninstall"

grep -q 'stow.*-D' "$REPO/install.sh" || fail "uninstall path does not use stow -D"
pass "uninstall path uses stow -D"

MSG="$(grep -h "oh-my-bash\|system packages\|bashrc.local\|config.local\|GNOME keys\|gsettings" "$REPO/install.sh" || true)"
echo "$MSG" | grep -q "oh-my-bash" || fail "uninstall message does not mention leftover ~/.oh-my-bash"
echo "$MSG" | grep -q "bashrc.local" || fail "uninstall message does not mention leftover Local overrides"
pass "uninstall message lists what is left behind"

FAKE_HOME="$(mktemp -d)"
trap 'rm -rf "$FAKE_HOME"' EXIT

PKGS="$(sed -n 's/^PACKAGES=(//p' "$REPO/install.sh" | tr -d ')')"
[[ -n "$PKGS" ]] || fail "could not read PACKAGES from install.sh"

stow -d "$REPO" -t "$FAKE_HOME" -R --no-folding $PKGS >/dev/null 2>&1 \
  || fail "setup stow into FAKE_HOME failed"
[[ -L "$FAKE_HOME/.bashrc" ]] || fail "setup did not link .bashrc into FAKE_HOME"

OUT="$(HOME="$FAKE_HOME" bash "$REPO/install.sh" --uninstall 2>&1)" \
  || fail "install.sh --uninstall exited non-zero"
[[ ! -e "$FAKE_HOME/.bashrc" ]] || fail "--uninstall left $FAKE_HOME/.bashrc behind"
echo "$OUT" | grep -qi "left behind\|leaves\|remaining" || fail "--uninstall output does not say what was left behind"
pass "uninstall removes stowed links and reports leftovers"

HOME="$FAKE_HOME" bash "$REPO/install.sh" --uninstall >/dev/null 2>&1 \
  || fail "second --uninstall (idempotent) exited non-zero"
pass "uninstall is idempotent"

echo "All uninstall tests passed."
