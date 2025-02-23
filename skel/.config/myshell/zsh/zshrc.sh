#!/bin/zsh
if [ -f "/usr/share/my_stuff/bin/bin/pfetch" ];then
	pfetch
fi

fpath+="$ZDOTDIR/completion"

# ---------------------------------  Theme  -----------------------------------
ZSH_THEME="headline"

# ---------- SSH Theme ----------
if [[ -n $SSH_CONNECTION ]];then
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

if builtin test -f $ZDOTDIR/themes/${ZSH_THEME}.zsh-theme;then
	source $ZDOTDIR/themes/${ZSH_THEME}.zsh-theme
else
	echo "plugin '$zplugin' not found"
fi

# ---------------------------- ZSH local_plugins -----------------------------
zlocal_plugins=(
command-not-found
thefuck
kitty_auto_complete
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

# ------------------------------- ZSH LOCAL PLUGINS Applyer --------------------------
if command -v zoxide >/dev/null 2>&1;then
	zplugin+=(zoxide)
else
	zplugin+=(z)
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

# ---------------------------- ZSH ONLINE_plugins -----------------------------

export Z_ONLINE_PLUGIN_DIR="$ZDOTDIR/online_plugins"
export -a Z_ONLINE_INSTALLED_PLUGINS=()

function plug() {

    function _try_source() {
        if [[ "$plugin_name" == "*" ]]; then
            # Treat * as a glob pattern
            local -a initfiles=(
                $plugin_dir/*.{plugin.,}{z,}sh{-theme,}(N)
            )
            for file in "${initfiles[@]}"; do
                [[ -f "$file" ]] && source "$file"
            done
        else
            # Use the specified plugin_name
            local -a initfiles=(
                $plugin_dir/${plugin_name}.{plugin.,}{z,}sh{-theme,}(N)
                $plugin_dir/*.{plugin.,}{z,}sh{-theme,}(N)
            )
            (( $#initfiles )) && source $initfiles[1]
        fi
    }

    # If the absolute is a directory then source as a local plugin
    pushd -q "$ZDOTDIR"
    local plugin_absolute="${1:A}"
    popd -q
    if [ -d "${plugin_absolute}" ]; then
        local plugin="${plugin_absolute}"
        local plugin_name="${plugin:t}"
        local plugin_dir="${plugin_absolute}"
    elif [ "${plugin_absolute:t}" = "*" ]; then
        local plugin_name="${plugin_absolute:t}"
        local plugin_dir="${plugin_absolute:h}"
    else
        # If the basename directory exists, then local source only
        if [ -d "${plugin_absolute:h}" ]; then
            [[ -f "${plugin_absolute}" ]] && source "${plugin_absolute}"
            return
        fi

        local plugin="$1"
        local plugin_name="${plugin:t}"
        local plugin_dir="$Z_ONLINE_PLUGIN_DIR/$plugin_name"
    fi

    local git_ref="$2"
    if [ ! -d "$plugin_dir" ]; then
        echo "🔌 Zap is installing $plugin_name..."
        git clone --depth 1 "${ZAP_GIT_PREFIX:-"https://github.com/"}${plugin}.git" "$plugin_dir" > /dev/null 2>&1 || { echo -e "\e[1A\e[K❌ Failed to clone $plugin_name"; return 12 }
        echo -e "\e[1A\e[K⚡ Zap installed $plugin_name"
    fi
    [[ -n "$git_ref" ]] && {
        git -C "$plugin_dir" remote set-branches origin '*' > /dev/null 2>&1
        git -C "$plugin_dir" pull --unshallow > /dev/null 2>&1
        git -C "$plugin_dir" checkout "$git_ref" > /dev/null 2>&1 || { echo "❌ Failed to checkout $git_ref"; return 13 }
    }
    _try_source && { Z_ONLINE_INSTALLED_PLUGINS+="$plugin_name" && return 0 } || echo "❌ $plugin_name not activated" && return 1
}

function _pull() {
    echo "🔌 updating ${1:t}..."
    git -C $1 pull > /dev/null 2>&1 && { echo -e "\e[1A\e[K⚡ ${1:t} updated!"; return 0 } || { echo -e "\e[1A\e[K❌ Failed to pull"; return 14 }
}

function _zap_clean() {
    typeset -a unused_plugins=()
    echo "⚡ Zap - Clean\n"
    for plugin in "$Z_ONLINE_PLUGIN_DIR"/*; do
        [[ "$Z_ONLINE_INSTALLED_PLUGINS[(Ie)${plugin:t}]" -eq 0 ]] && unused_plugins+=("${plugin:t}")
    done
    [[ ${#unused_plugins[@]} -eq 0 ]] && { echo "✅ Nothing to remove"; return 15 }
    for plug in ${unused_plugins[@]}; do
        echo "❔ Remove: $plug? (y/N)"
        read -qs answer
        [[ "$answer" == "y" ]] && { rm -rf "$Z_ONLINE_PLUGIN_DIR/$plug" && echo -e "\e[1A\e[K✅ Removed $plug" } || echo -e "\e[1A\e[K❕ skipped $plug"
    done
}

function _zap_list() {
    local _plugin
    echo "⚡ Zap - List\n"
    for _plugin in ${Z_ONLINE_INSTALLED_PLUGINS[@]}; do
        printf '%4s  🔌 %s\n' $Z_ONLINE_INSTALLED_PLUGINS[(Ie)$_plugin] $_plugin
    done
}

function _zap_update() {

    local _plugin _plug _status
    
    function _check() {
        git -C "$1" remote update &> /dev/null
        case $(LANG=en_US git -C "$1" status -uno | grep -Eo '(ahead|behind|up to date)') in
            ahead)
                _status='\033[1;34mLocal ahead remote\033[0m' ;;
            behind)
                _status='\033[1;33mOut of date\033[0m' ;;
            'up to date')
                _status='\033[1;32mUp to date\033[0m' ;;
            *)
                _status='\033[1;31mDiverged state\033[0m' ;;
        esac
    }

    echo "⚡ Zap - Update\n"
    for _plugin in ${Z_ONLINE_INSTALLED_PLUGINS[@]}; do
        _check "$Z_ONLINE_PLUGIN_DIR/$_plugin"
        printf '%4s 🔌 %s (%b)\n' $Z_ONLINE_INSTALLED_PLUGINS[(Ie)$_plugin] $_plugin $_status
    done
    echo -n "\n  🔌 Plugin Number | (a) All Plugins | (⏎) Abort: " && read _plugin
    case $_plugin in
        [[:digit:]]*)
            [[ $_plugin -gt ${#Z_ONLINE_INSTALLED_PLUGINS[@]} ]] && { echo "❌ Invalid option" && return 1 }
            _pull "$Z_ONLINE_PLUGIN_DIR/$Z_ONLINE_INSTALLED_PLUGINS[$_plugin]";;
        'a'|'A')
            echo "\nUpdating All Plugins\n"
            for _plug in ${Z_ONLINE_INSTALLED_PLUGINS[@]}; do
                _pull "$Z_ONLINE_PLUGIN_DIR/$_plug"
            done ;;
        *)
            : ;;
    esac
    [[ $ZAP_CLEAN_ON_UPDATE == true ]] && _zap_clean || return 0
}

function _zap_help() {
    echo "⚡ Zap - Help

Usage: zap <command> [options]

COMMANDS:
    clean          Remove unused plugins
    help           Show this help message
    list           List plugins
    update         Update plugins
"
}

function zap() {
    typeset -A subcmds=(
        clean "_zap_clean"
        help "_zap_help"
        list "_zap_list"
        update "_zap_update"
    )
    emulate -L zsh
    [[ -z "$subcmds[$1]" ]] && { _zap_help; return 1 } || ${subcmds[$1]} $2
}

# vim: ft=zsh ts=4 et
# Return codes:
#   0:  Success
#   1:  Invalid option
#   12: Failed to clone
#   13: Failed to checkout
#   14: Failed to pull
#   15: Nothing to remove

# ------------------------------------------------------------------------------
