
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
