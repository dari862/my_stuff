if command -v fzf >/dev/null 2>&1;then
  zstyle ':completion:*:*:*:default' menu yes select search
  source (((__distro_path_enabled_completion)))/zsh/completion.zsh
  source (((__distro_path_enabled_completion)))/zsh/key-bindings.zsh
fi
