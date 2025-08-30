if command -v fzf >/dev/null 2>&1;then
	source (((__distro_path_enabled_completion)))/bash/completion.bash
	source (((__distro_path_enabled_completion)))/bash/key-bindings.bash
fi
