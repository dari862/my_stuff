#!/bin/zsh
if [ -f "/usr/share/my_stuff/bin/bin/pfetch" ]; then
	pfetch
fi

# ---------------------------------  Theme  -----------------------------------
ZSH_THEME="headline"

# ---------- SSH Theme ----------
if [[ -n $SSH_CONNECTION ]]; then
  ZSH_THEME="SSH"
else
  ZSH_THEME="$ZSH_THEME"
fi

# --------- theme Applyer ------
# Configure color-scheme
COLOR_SCHEME=dark # dark/light

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|Eterm|aterm|kterm|gnome*|alacritty)
	precmd() { print -Pnr -- $'\e]0;%n@%m: %~\a' }
	;;
esac

if builtin test -f $ZDOTDIR/themes/${ZSH_THEME}.zsh-theme; then
	source $ZDOTDIR/themes/${ZSH_THEME}.zsh-theme
else
	echo "plugin '$zplugin' not found"
fi

# ------------------------------- ZSH PLUGINS ---------------------------------
zplugins=(
zsh-syntax-highlighting
zsh-autosuggestions
you-should-use
command-not-found
thefuck
kitty_auto_complete
antigen
auto-notify
zsh-history-substring-search
fzf
mise
change-term-title
)

# --------------------------------- SETTINGS ----------------------------------
setopt AUTO_CD 					# change directory just by typing its name
setopt BEEP
#setopt CORRECT
setopt HIST_BEEP
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt INTERACTIVE_COMMENTS
setopt MAGIC_EQUAL_SUBST
setopt NO_NO_MATCH
setopt NOTIFY
setopt NUMERIC_GLOB_SORT
setopt PROMPT_SUBST				# enable command substitution in prompt
setopt MENU_COMPLETE     		# Automatically highlight first element of completion menu
setopt SHARE_HISTORY
setopt appendhistory
setopt hist_ignore_space
setopt LIST_PACKED		  		# The completion menu takes less space.
setopt AUTO_LIST           		# Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD    		# Complete from both ends of a word.

HISTFILE=$ZDOTDIR/zsh_history
HIST_STAMPS=mm/dd/yyyy
HISTSIZE=5000
SAVEHIST=5000
HISTDUP=erase
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

# ------------------------------- ZSH PLUGINS Applyer --------------------------
if command -v zoxide >/dev/null 2>&1;then
	zplugin+=(zoxide)
else
	zplugin+=(z)
fi
for zplugin ($zplugins); do
	if builtin test -f $ZDOTDIR/plugins/${zplugin}.plugin.zsh; then
  		source $ZDOTDIR/plugins/${zplugin}.plugin.zsh
	elif builtin test -f $ZDOTDIR/plugins/${zplugin}.zsh; then
  		source $ZDOTDIR/plugins/${zplugin}.zsh
  	elif builtin test -f /usr/share/${zplugin}/${zplugin}.zsh; then
  		source /usr/share/${zplugin}/${zplugin}.zsh
  	else
    	echo "plugin '$zplugin' not found"
  	fi
done

# ------------------------------- source files ---------------------------------
if [ -f $ZDOTDIR/zsh-only-aliases.sh ]; then
    source $ZDOTDIR/zsh-only-aliases.sh
fi

if [ -f $ZDOTDIR/functions.sh ]; then
    source $ZDOTDIR/functions.sh
fi

if [ -f $My_shell_DIR/aliases.sh ]; then
    source $My_shell_DIR/aliases.sh
fi

if [ -f $My_shell_DIR/aliases-if-command.sh ]; then
    source $My_shell_DIR/aliases-if-command.sh
fi

if [ -f $My_shell_DIR/misc.sh ]; then
    source $My_shell_DIR/misc.sh
fi

if [ -f $My_shell_DIR/functions.sh ]; then
    source $My_shell_DIR/functions.sh
fi
# ------------------------------------------------------------------------------
