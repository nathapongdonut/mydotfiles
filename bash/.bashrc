# Ghostty shell integration must stay at the very top (auto-inject fallback
# for shell-switching like nix-shell). Guarded so plain bash still works.
if [ -n "${GHOSTTY_RESOURCES_DIR:-}" ] && [ -f "$GHOSTTY_RESOURCES_DIR/shell-integration/bash/ghostty.bash" ]; then
  # shellcheck disable=SC1090
  . "$GHOSTTY_RESOURCES_DIR/shell-integration/bash/ghostty.bash"
fi

# --- history / readline (minimal v1) ---
shopt -s histappend checkwinsize
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
bind '"\e[A": history-search-backward' 2>/dev/null || true
bind '"\e[B": history-search-forward' 2>/dev/null || true

# --- completion ---
if [ -f /usr/share/bash-completion/bash_completion ]; then
  # shellcheck disable=SC1091
  . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  # shellcheck disable=SC1091
  . /etc/bash_completion
fi

# --- plain PS1 tweak (no framework in v1) ---
# user@host:cwd ($ for user, # for root), Git branch when available.
__git_ps1_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null | sed 's/^/ (/;s/$/)/'
}
PS1='\u@\h:\w$(__git_ps1_branch)\$ '

# --- handful of aliases ---
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status --short --branch'
alias gd='git diff'
alias ..='cd ..'

# --- Local override (never commit secrets here) ---
# Per-machine bits go in ~/.bashrc.local (gitignored).
if [ -f "$HOME/.bashrc.local" ]; then
  # shellcheck disable=SC1090
  . "$HOME/.bashrc.local"
fi
