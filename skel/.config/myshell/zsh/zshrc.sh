#!/bin/zsh
unsetopt PROMPT_SP 2>/dev/null

distro_fetch

fpath+=("(((__distro_path_root)))/system_files/completion/zsh")

# --------- theme Applyer ------
if [[ -n "$SSH_CONNECTION" ]];then
	ZSH_THEME="$SSH_THEME"
	SSH_MESS="-ssh"
	PATH="${__distro_path_root}/system_files/binX11:$PATH"
else
	SSH_THEME=""
	SSH_MESS=""
fi

if [[ -z "$ZSH_THEME" ]];then
	ZSH_THEME="pure"
fi

# Configure color-scheme
if [[ -d "$ZDOTDIR/prompts/$ZSH_THEME" ]];then
	fpath+=("$ZDOTDIR/prompts/$ZSH_THEME")
	autoload -U promptinit; promptinit
	prompt ${ZSH_THEME}
elif [[ -f "$ZDOTDIR/themes/${ZSH_THEME}.zsh-theme" ]];then
	source "$ZDOTDIR/themes/${ZSH_THEME}.zsh-theme"
else
	echo "Theme: $ZSH_THEME not found"
fi

# ---------------------------- ZSH local_plugins -----------------------------
zlocal_plugins=(
command-not-found
kitty_auto_complete
fzf
mise
change-term-title
zap
#theoops
)

# --------------------------------- SETTINGS ----------------------------------
setopt AUTO_CD 					# change directory just by typing its name
setopt BEEP
setopt CORRECT					# auto wrong command correction
setopt INTERACTIVE_COMMENTS
setopt MAGIC_EQUAL_SUBST
setopt NO_NO_MATCH
setopt NOTIFY
setopt NUMERIC_GLOB_SORT
setopt PROMPT_SUBST				# enable command substitution in prompt
setopt MENU_COMPLETE     		# Automatically highlight first element of completion menu
setopt LIST_PACKED		  		# The completion menu takes less space.
setopt AUTO_LIST           		# Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD    		# Complete from both ends of a word.

# --------------------------------- History ----------------------------------
source "$ZDOTDIR/history.sh"

# --------------------------------- Others  ----------------------------------
ZLE_RPROMPT_INDENT=0
WORDCHARS=${WORDCHARS//\/}
PROMPT_EOL_MARK=
TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'

# ZSH completion system
autoload -Uz compinit

for dump in ~/.cache/zcompdump(N.mh+24); do
  compinit -d ~/.cache/zcompdump
done

compinit -C -d ~/.cache/zcompdump

autoload -Uz add-zsh-hook
autoload -Uz vcs_info
precmd () { vcs_info }
_comp_options+=(globdots)

zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS} 'ma=48;5;197;1'
zstyle ':completion:*' matcher-list \
		'm:{a-zA-Z}={A-Za-z}' \
		'+r:|[._-]=* r:|=*' \
		'+l:|=*'
zstyle ':completion:*:warnings' format "%B%F{red}No matches for:%f %F{magenta}%d%b"
zstyle ':completion:*:descriptions' format '%F{yellow}[-- %d --]%f'
zstyle ':vcs_info:*' formats ' %B%s-[%F{magenta}%f %F{yellow}%b%f]-'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Key bindings
## ------ auto edited by shortcuts script ------ ##
## ------ end of auto edited by shortcuts script ------ ##

# Expands history expressions like !! or !$ when you press space
bindkey ' ' magic-space

# ------------------------------- ZSH LOCAL PLUGINS Applyer --------------------------
if command -v zoxide >/dev/null 2>&1;then
	zplugin+=(zoxide)
else
	zplugin+=(z)
fi

if command -v npm >/dev/null 2>&1;then
	bashplugin+=(npm)
fi

for zplugin ($zlocal_plugins); do
	if builtin test -f $ZDOTDIR/local_plugins/${zplugin}.plugin.zsh;then
  		source $ZDOTDIR/local_plugins/${zplugin}.plugin.zsh
	elif builtin test -f $ZDOTDIR/local_plugins/${zplugin}.zsh;then
  		source $ZDOTDIR/local_plugins/${zplugin}.zsh
  	elif builtin test -f /usr/share/${zplugin}/${zplugin}.zsh;then
  		source /usr/share/${zplugin}/${zplugin}.zsh
  	else
    	echo "plugin '$zplugin' not found"
  	fi
done

# ------------------------------- source files ---------------------------------
if [ -f $ZDOTDIR/zsh-only-aliases.sh ];then
    source $ZDOTDIR/zsh-only-aliases.sh
fi

if [ -f $ZDOTDIR/functions.sh ];then
    source $ZDOTDIR/functions.sh
fi

if [ -f $My_shell_DIR/aliases.sh ];then
    source $My_shell_DIR/aliases.sh
fi

if [ -f $My_shell_DIR/aliases-if-command.sh ];then
    source $My_shell_DIR/aliases-if-command.sh
fi

if [ -f $My_shell_DIR/misc.sh ];then
    source $My_shell_DIR/misc.sh
fi

if [ -f $My_shell_DIR/functions.sh ];then
    source $My_shell_DIR/functions.sh
fi

# ------------------------------------------------------------------------------

if [ "$vim_mode_enabled" = true ];then
	remote_plugins+=("jeffreytse/zsh-vi-mode")
fi

for plugin in ${remote_plugins[@]};do
	plug "$plugin"
done
