#!/usr/bin/env bash
# Seam: Stow Package image (deploy boundary).
# Spec: CONTEXT.md Package = versioned file tree mirroring paths relative to
# Target ($HOME); ADR-0001: one package per tool with plain dotfile names,
# `stow --no-folding -R -t "$HOME"`. gsettings.sh is a helper, not a $HOME
# dotfile, so restowing must never create ~/gsettings.sh.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "PASS: $1"; }

FAKE_HOME="$(mktemp -d)"
trap 'rm -rf "$FAKE_HOME"' EXIT

# Read the package list the Install script actually restows.
PKGS="$(sed -n 's/^PACKAGES=(//p' "$REPO/install.sh" | tr -d ')')"
[[ -n "$PKGS" ]] || fail "could not read PACKAGES from install.sh"

OUT="$(stow -d "$REPO" -t "$FAKE_HOME" -R --no-folding -n -v $PKGS 2>&1 || true)"
echo "$OUT" | grep -q "LINK: gsettings.sh " && fail "stow would link ~/gsettings.sh at Target root"
pass "no ~/gsettings.sh link in stow image"

echo "All stow image tests passed."
