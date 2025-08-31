#!/usr/bin/env bash

_repobin() {
  local cur prev words cword
  _init_completion || return

  local commands="install update list remove info clean reinstall help"
  local options="--bin-dir --config-file --root --mode --ext"

  # Get installed repos for completion (modify this if config path varies)
  local config_file="${BIN_DIR:-$HOME/.local/bin}/installs.json"
  local installed_repos=()
  if [[ -f "$config_file" ]]; then
    installed_repos=( $(jq -r 'keys[]' "$config_file") )
  fi

  case "$prev" in
    install)
      # Suggest some common repos or nothing
      COMPREPLY=( $(compgen -W "sharkdp/fd sharkdp/bat BurntSushi/ripgrep" -- "$cur") )
      return
      ;;
    remove|info|reinstall)
      # Complete with installed repos
      COMPREPLY=( $(compgen -W "${installed_repos[*]}" -- "$cur") )
      return
      ;;
    --bin-dir|--config-file)
      _filedir
      return
      ;;
  esac

  if [[ "$cur" == --* ]]; then
    COMPREPLY=( $(compgen -W "$options" -- "$cur") )
  else
    COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
  fi
}

complete -F _repobin repobin
