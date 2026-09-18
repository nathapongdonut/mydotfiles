#!/usr/bin/env bash
# Seam 2: plugin lockfile (repo boundary).
# Spec: issue #4 / docs/research/kickstart-base.md §4 + :help vim.pack-lockfile
# — "TRACK nvim-pack-lock.json in version control"; upstream git-ignores it,
# downstream must not. The file is minted by vim.pack itself on first boot,
# never hand-written.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCK="$REPO/nvim/.config/nvim/nvim-pack-lock.json"
fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }

[[ -f "$LOCK" ]] || fail "nvim-pack-lock.json missing (run nvim once, then commit it)"
pass "nvim-pack-lock.json exists"

python3 -c "
import json
d = json.load(open('$LOCK'))
plugs = d.get('plugins', {})
assert isinstance(plugs, dict) and len(plugs) > 0, 'no plugins tracked'
for name, p in plugs.items():
    assert p.get('rev') and p.get('src'), f'{name} missing rev/src'
print(f'{len(plugs)} plugins pinned')
" || fail "nvim-pack-lock.json is not a valid pin map (plugins[].rev/src)"
pass "nvim-pack-lock.json is valid non-empty JSON"

git -C "$REPO" check-ignore -q "$LOCK" && fail "nvim-pack-lock.json is gitignored (downstream must track it)"
pass "nvim-pack-lock.json is not gitignored"

echo "All nvim lockfile tests passed."
