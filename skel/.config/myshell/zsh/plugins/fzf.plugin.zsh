if command -v fzf >/dev/null 2>&1;then
  zstyle ':completion:*:*:*:default' menu yes select search
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi
