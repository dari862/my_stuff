if command -v fzf &> /dev/null; then
  zstyle ':completion:*:*:*:default' menu yes select search
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi
