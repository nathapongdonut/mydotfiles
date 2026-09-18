#!/usr/bin/env bash
# Seam: bash Local override wins (shell boundary).
# Spec: CONTEXT.md Local override = optional gitignored per-machine include
# sourced by a versioned file. The override must have the last word, so a
# per-machine EDITOR/PATH in ~/.bashrc.local survives sourcing bash/.bashrc.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }

FAKE_HOME="$(mktemp -d)"
trap 'rm -rf "$FAKE_HOME"' EXIT
cat > "$FAKE_HOME/.bashrc.local" <<'EOF'
export EDITOR="sentinel-editor"
export PATH="/sentinel/bin:$PATH"
EOF

OUT="$(HOME="$FAKE_HOME" bash -i -c 'source "$0"; printf "%s\n%s\n" "$EDITOR" "$PATH"' "$REPO/bash/.bashrc" 2>/dev/null)"
EDITOR_GOT="$(printf "%s" "$OUT" | sed -n '1p')"
PATH_GOT="$(printf "%s" "$OUT" | sed -n '2p')"

[[ "$EDITOR_GOT" == "sentinel-editor" ]] || fail "Local override EDITOR lost (got '$EDITOR_GOT')"
pass "Local override EDITOR wins"
case "$PATH_GOT" in
  /sentinel/bin:*) pass "Local override PATH wins" ;;
  *) fail "Local override PATH lost (got '$PATH_GOT')" ;;
esac

echo "All bash override tests passed."
