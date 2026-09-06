#!/usr/bin/env bash
# GNOME v1 baseline — small versioned gsettings set only, no extensions.
# Idempotent: gsettings set is a plain overwrite. Called by install.sh.
set -euo pipefail

have() { command -v "$1" >/dev/null 2>&1; }
have gsettings || { echo "gsettings not found, skipping GNOME keys"; exit 0; }

# Appearance: prefer dark.
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true

# Favorites (Files, Ghostty, Firefox) — adjust to taste.
gsettings set org.gnome.shell favorite-apps \
  "['org.gnome.Nautilus.desktop', 'com.mitchellh.ghostty.desktop', 'org.mozilla.firefox.desktop']" || true

# Nautilus prefs.
gsettings set org.gnome.nautilus.preferences show-hidden-files true || true

# Keybindings: keep GNOME defaults in v1 (version deltas here when decided).
# Example (uncomment when ticket #7 decides):
# gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']" || true

echo "GNOME keys applied (v1 minimal set)."
