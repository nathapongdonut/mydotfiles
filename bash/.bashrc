# Ghostty shell integration must stay at the very top (auto-inject fallback
# for shell-switching like nix-shell). Guarded so plain bash still works.
if [ -n "${GHOSTTY_RESOURCES_DIR:-}" ] && [ -f "$GHOSTTY_RESOURCES_DIR/shell-integration/bash/ghostty.bash" ]; then
  # shellcheck disable=SC1090
  . "$GHOSTTY_RESOURCES_DIR/shell-integration/bash/ghostty.bash"
fi

# --- oh-my-bash (installed/updated by install.sh into ~/.oh-my-bash) ---
# Non-interactive shells (scp, rsync) must bail before OMB's interactive setup.
case $- in
  *i*) ;;
  *) return ;;
esac

# Versioned defaults (change theme here). OSH_THEME already exported in the
# environment wins; ~/.bashrc.local is sourced at the bottom (after OMB
# loads), so use it for extra aliases/env, not for OSH_* knobs.
export OSH="$HOME/.oh-my-bash"
# Versioned custom themes (e.g. mizuki) live in the repo at
# bash/.config/omb-custom/, stowed to ~/.config/omb-custom/.
export OSH_CUSTOM="$HOME/.config/omb-custom"
OSH_THEME="${OSH_THEME:-mizuki}"
OMB_USE_SUDO=true

completions=(
  git
  ssh
)

aliases=(
  general
)

plugins=(
  git
  bashmarks
)

if [ -f "$OSH/oh-my-bash.sh" ]; then
  # shellcheck disable=SC1091
  . "$OSH/oh-my-bash.sh"
fi

# --- Mizuki LS_COLORS (pink dirs/links, gray executables; after OMB) ---
export LS_COLORS="${LS_COLORS:+$LS_COLORS:}di=38;2;221;170;204:ln=38;2;244;169;198:ex=38;2;162;166;189"

# --- history / readline (minimal v1, applied after OMB so ours win) ---
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

# --- prompt: OMB theme owns PS1; plain fallback only when OMB is absent ---
if [[ -z "${OMB_VERSION:-}" ]]; then
  # user@host:cwd ($ for user, # for root), Git branch when available.
  __git_ps1_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null | sed 's/^/ (/;s/$/)/'
  }
  PS1='\u@\h:\w$(__git_ps1_branch)\$ '
fi

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
