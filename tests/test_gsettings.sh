#!/usr/bin/env bash
# Seam: gnome/gsettings.sh versioned key set (public deploy boundary).
# Spec: no speculative generality — no commented-out future keybindings.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILE="$REPO/gnome/gsettings.sh"

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }

grep -qi "uncomment when" "$FILE" && fail "speculative 'uncomment when' block present"
pass "no speculative uncomment block"

grep -q "ticket #7" "$FILE" && fail "speculative ticket #7 reference present"
pass "no speculative ticket reference"

bash -n "$FILE" || fail "bash -n failed"
pass "bash syntax ok"

echo "All gsettings tests passed."
