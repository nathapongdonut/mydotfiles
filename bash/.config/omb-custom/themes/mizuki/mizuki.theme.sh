#! bash oh-my-bash.module
# Mizuki theme — Nightcord-at-25:00 prompt in Akiyama Mizuki's palette.
#
# Single-line: user@host:cwd (branch) ❯
#   user@host ... Uniform Gray (#A2A6BD, sailor-uniform gray)
#   cwd ......... Mizuki Pink  (#DDAACC, official image color)
#   git branch .. Hair Pink    (#F4A9C6, hair/eyes)
#   dirty mark .. Deep Ribbon  (#8E3B5C, hair bow)
#   prompt glyph  Mizuki Pink
#
# 24-bit escapes: the repo baseline assumes true-color (Ghostty + tmux RGB).
# Colors are pre-wrapped in \[ \] like OMB's own _omb_prompt_* vars
# (see upstream lib/omb-prompt-colors.sh), so they are also safe inside
# SCM_THEME_* segments expanded via $(scm_prompt_info).

_MIZUKI_GRAY='\[\e[38;2;162;166;189m\]'
_MIZUKI_PINK='\[\e[38;2;221;170;204m\]'
_MIZUKI_HAIR='\[\e[38;2;244;169;198m\]'
_MIZUKI_RIBBON='\[\e[38;2;142;59;92m\]'
_MIZUKI_RESET='\[\e[0m\]'

# Raw (unwrapped) copies for SCM_THEME_* segments: they are expanded via
# $(scm_prompt_info), where \[ \] would print literally instead of marking
# zero-width. Same tradeoff as OMB's stock themes (e.g. cupcake).
_MIZUKI_RAW_HAIR=$'\e[38;2;244;169;198m'
_MIZUKI_RAW_RIBBON=$'\e[38;2;142;59;92m'
_MIZUKI_RAW_RESET=$'\e[0m'

# SCM (git) segments consumed by OMB's scm_prompt_info.
SCM_THEME_PROMPT_DIRTY=" ${_MIZUKI_RAW_RIBBON}✗${_MIZUKI_RAW_RESET}"
SCM_THEME_PROMPT_CLEAN=""
SCM_THEME_PROMPT_PREFIX=" ${_MIZUKI_RAW_HAIR}("
SCM_THEME_PROMPT_SUFFIX="${_MIZUKI_RAW_RESET})"

function _omb_theme_PROMPT_COMMAND() {
  PS1="${_MIZUKI_GRAY}\u@\h${_MIZUKI_RESET} "
  PS1+="${_MIZUKI_PINK}\w${_MIZUKI_RESET}"
  PS1+='$(scm_prompt_info)'
  PS1+=" ${_MIZUKI_PINK}❯${_MIZUKI_RESET} "
  PS2=" ${_MIZUKI_PINK}❯${_MIZUKI_RESET} "
}

# Bypass OMB's $PROMPT handling; drive PS1 directly.
_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
