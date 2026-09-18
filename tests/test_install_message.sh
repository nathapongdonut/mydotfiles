#!/usr/bin/env bash
# Seam: Install script completion message (user-facing boundary).
# Spec: CONTEXT.md Local override = optional gitignored per-machine include
# (e.g. ~/.bashrc.local). .gitignore covers **/.bashrc.local, **/config.local.
# Versioned lua/custom/ must never be listed as an override.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }

MSG_LINES="$(grep -h "bashrc.local\|config.local\|lua/custom" "$REPO/install.sh" || true)"
[[ -n "$MSG_LINES" ]] || fail "no Local override message found in install.sh"

echo "$MSG_LINES" | grep -q "\.bashrc\.local" || fail "message missing ~/.bashrc.local"
pass "message lists ~/.bashrc.local"

echo "$MSG_LINES" | grep -q "config\.local" || fail "message missing config.local"
pass "message lists config.local"

echo "$MSG_LINES" | grep -q "lua/custom" && fail "message lists versioned lua/custom/ as override (violates CONTEXT.md)"
pass "message does not list versioned lua/custom/"

echo "All override message tests passed."
