#!/usr/bin/env bash
# Seam 3: ADR/code agreement (docs boundary).
# Spec: ADR-0001 lists one package per tool including gnome/, but
# gnome/gsettings.sh is an executable helper, not $HOME-relative dotfiles —
# stowing it would link ~/gsettings.sh (guarded by test_stow_image.sh).
# The ADR must say gnome/ is invoked, never stowed, or code and docs disagree.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ADR="$REPO/docs/adr/0001-stow-layout-single-install.md"
fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }

grep -qi "gnome.*invoked\|invoked.*gnome\|never stowed\|not stowed" "$ADR" \
  || fail "ADR-0001 still lists gnome/ as a stowed package"
pass "ADR-0001 documents gnome/ as invoked helper, never stowed"

echo "All ADR agreement tests passed."
