#!/usr/bin/env bash
# Seam: Override contract (user-facing docs boundary).
# Spec: CONTEXT.md Local override = optional gitignored per-machine include
# (e.g. ~/.bashrc.local, Ghostty ?config.local). .gitignore covers
# **/.bashrc.local and **/config.local. Versioned lua/custom/ is tracked, so
# neither README nor install.sh may list it as an override.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }

check_file() {
  local f="$1" sec
  if [[ "$f" == "README.md" ]]; then
    sec="$(sed -n '/^## Per-machine overrides/,/^## /p' "$REPO/$f" | head -n -1)"
  else
    sec="$(grep -h "bashrc.local\|config.local\|lua/custom" "$REPO/$f" || true)"
  fi
  [[ -n "$sec" ]] || fail "no override section found in $f"
  echo "$sec" | grep -q "lua/custom" && fail "$f lists versioned lua/custom/ as override"
  echo "$sec" | grep -q "bashrc.local" || fail "$f override section missing ~/.bashrc.local"
  pass "$f lists only gitignored includes"
}

check_file README.md
check_file install.sh

echo "All override contract tests passed."
