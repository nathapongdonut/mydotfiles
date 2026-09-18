#!/usr/bin/env bash
# Seam: bash syntax boundary (install.sh, bash/.bashrc, gnome/gsettings.sh).
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }
for f in install.sh bash/.bashrc gnome/gsettings.sh; do
  bash -n "$REPO/$f" || fail "bash -n failed for $f"
  pass "bash -n ok: $f"
done
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck -S warning "$REPO/install.sh" "$REPO/gnome/gsettings.sh" "$REPO/bash/.bashrc" || fail "shellcheck warnings"
  pass "shellcheck clean"
else
  echo "SKIP: shellcheck not installed"
fi
echo "All syntax tests passed."
