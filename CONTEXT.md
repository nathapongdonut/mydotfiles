# Mydotfiles

Versioned GNOME workstation setup on Fedora and Ubuntu, deployed from this repo with no manual symlinking.

## Language

**Stow directory**:
The repo root, containing one subdirectory per managed tool.
_Avoid_: dotfiles repo, source dir

**Package**:
One tool's versioned file tree mirroring paths relative to the target (e.g. `bash/.bashrc`, `nvim/.config/nvim/init.lua`).
_Avoid_: module, folder, stow package dir

**Target**:
The directory links are created in, always `$HOME` for this project.
_Avoid_: destination, home dir, install dir

**Install script**:
The single idempotent `install.sh` that detects distro via `/etc/os-release`, installs distro packages, then restows packages.
_Avoid_: bootstrap, setup script, installer

**Local override**:
An optional gitignored per-machine include sourced by a versioned file (e.g. `~/.bashrc.local`, Ghostty `?config.local`).
_Avoid_: local config, private config, machine config
