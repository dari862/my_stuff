#!/usr/bin/env bash
set -ueo pipefail

# --- Inputs ---
root="${1:-}"
themes_style_name="${2:-}"
output_theme_name="${3:-}"
themes_output_dir="${4:-$HOME/.themes}"
theme_file="${5:-}"

# ---    Clean up      ---
tmp_dir="$(mktemp -d)"
post_clean_up() {
    rm -rf "${tmp_dir}"
}
trap post_clean_up EXIT

error_m() {
	message="${1-}"
	printf '%b' "\n\033[1;97;41m ERROR \033[0m \033[1;31m${message}\033[0m\n\n" >&2
}

done_m() {
	message="${1-}"
	printf '%b' "\033[1;32m✔ ${message}\033[0m\n"
}

info_m() {
	message="${1-}"
	color="38;5;51"
	printf '%b' "\033[1;${color}m:: ${message} ...\033[0m\n"
}

sub_info_m() {
	message="${1-}"
	color="38;5;75"
	printf '%b' "\033[0;${color}m ↳ ${message} ...\033[0m\n"
}

# --- Helper Functions ---
check_var() {
    if [ -z "${2:-}" ]; then
        error_m "${1} is empty"
        exit 1
    fi
}

# --- Initialization & Validation ---
check_var "output_theme_name" "$output_theme_name"
info_m "building ${output_theme_name}"
check_var "theme_file" "$theme_file"

source "$theme_file"

# --- Theme Processing Styles ---
case "$themes_style_name" in
    materia)
    	info_m "Using $themes_style_name"
    	"${root}"/theme_materia/materia-theme/change_color.sh --hidpi True --target "$themes_output_dir" --output "${output_theme_name}" "${theme_file}"
        ;;
    oomox)
    	info_m "Using $themes_style_name"
    	"${root}"/theme_oomox/change_color.sh --hidpi True --target-dir "$themes_output_dir" --output "${output_theme_name}" "${theme_file}" --make-opts gtk320 css_cinnamon
        ;;
    arc)
    	info_m "Using $themes_style_name"
        ;;
esac
