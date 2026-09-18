#!/usr/bin/env bash
# Seam 1: nvim vendor image (file boundary) + custom delta runtime (Lua boundary).
# Spec: issue #4 / docs/research/kickstart-base.md §4 — vendor snapshot
# init.lua + lua/kickstart + lua/custom, stamped with upstream SHA f7b845d
# (2026-09-06); personal config only in lua/custom/.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVIM="$REPO/nvim/.config/nvim"
fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }

# 1. Pinned SHA + date stamp (independent truth: research doc §1).
grep -q "f7b845d" "$NVIM/init.lua" || fail "init.lua missing pinned SHA f7b845d"
grep -q "2026-09-06" "$NVIM/init.lua" || fail "init.lua missing pin date 2026-09-06"
pass "init.lua stamped with pinned upstream SHA + date"

# 2. All 10 upstream sections present (independent truth: research doc §1).
for n in 1 2 3 4 5 6 7 8 9 10; do
  grep -q "SECTION $n:" "$NVIM/init.lua" || fail "init.lua missing SECTION $n"
done
pass "init.lua contains all 10 upstream sections"

# 3. Vendored kickstart modules present (independent truth: research doc §1).
for f in lua/kickstart/health.lua lua/kickstart/plugins/debug.lua lua/kickstart/plugins/indent_line.lua lua/kickstart/plugins/lint.lua lua/kickstart/plugins/autopairs.lua lua/kickstart/plugins/neo-tree.lua; do
  [[ -f "$NVIM/$f" ]] || fail "missing vendored $f"
done
pass "lua/kickstart/ modules vendored"

# 4. Personal delta untouched: mizuki theme still our entry point.
grep -q "require('custom.mizuki')" "$NVIM/lua/custom/init.lua" || fail "custom delta no longer loads mizuki"
grep -q "colors_name = 'mizuki'" "$NVIM/lua/custom/mizuki.lua" || fail "mizuki theme lost its colors_name"
pass "lua/custom/ delta intact"

# 5. Delta loads cleanly through the real Lua runtime (no network needed).
PROBE="$(mktemp)"
cat > "$PROBE" <<EOF
package.path = "$NVIM/lua/?.lua;$NVIM/lua/?/init.lua;" .. package.path
require('custom.mizuki').setup()
print('colors=' .. vim.g.colors_name)
EOF
OUT="$(nvim --headless --clean -l "$PROBE" 2>&1)"
rm -f "$PROBE"
echo "$OUT" | grep -q "colors=mizuki" || fail "custom.mizuki failed headless (got: $OUT)"
pass "custom.mizuki loads headless, colors_name=mizuki"

echo "All nvim vendor tests passed."
