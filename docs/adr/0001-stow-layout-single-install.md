# Stow layout with single distro-detecting install script

Repo root is the Stow directory with one package per tool (`bash/`, `ghostty/`, `tmux/`, `nvim/`, `gnome/`) using plain dotfile names and `stow --no-folding -R -t "$HOME"`, deployed by a single idempotent `install.sh` that branches on `/etc/os-release` `$ID` (Fedora `dnf` incl. Ghostty COPR, Ubuntu `apt` incl. version-gated Ghostty PPA) and fails loudly on conflicts with a backup/`--adopt` hint, because this keeps per-tool deploys independent and re-runs safe without hidden state or silent overwrites.
