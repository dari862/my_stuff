#!/bin/zsh

# Enable prompt substitution
setopt prompt_subst

# Left prompt glyph
if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    user_symbol='%F{1}%f'  # root - red arrow
else
    user_symbol='%F{5}%f'  # user - magenta arrow
fi

# Return value prompt
non_zero_return_value='%(0?..%F{1}%f)'

# Background jobs
background_jobs='%(1j.%F{2}%f.)'

# Current working directory path
dir_path="%F{0}%K{0}%F{white}%2~ %K{8} %F{4}%{%k%}%F{8}%f"

# Use bold input
zle_highlight=(default:bold)

# Git prompt manually defined
function git_prompt_info() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return
  local dirty=""
  [[ -n $(git status --porcelain 2>/dev/null) ]] && dirty="%F{1}*%f"

  echo "%F{8}%K{8}%F{4} %K{0} %F{white}${branch}${dirty}%{%k%}%F{0}%f"
}

# Left and right prompt
PROMPT='$(git_prompt_info) ${user_symbol} '
RPROMPT='${background_jobs} ${non_zero_return_value} ${dir_path}'
