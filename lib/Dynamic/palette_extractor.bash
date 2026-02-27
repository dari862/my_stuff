#!/bin/bash
# work on this : colors not 100% accurete
unalias -a

wal="${1:-}"
output_colors="${2:-/tmp/output_colors}"

if [[ -z "$wal" ]]; then
	printf "%s\n" "Error: 'wal' no wallpaper provided" >&2
	exit 1
else
	wal="$(realpath "$wal")"
fi

# Speed up script by not using unicode.
sys_locale="$LANG"
export LC_ALL=C
export LANG=C

shopt -s nullglob nocasematch

# Internal variables.
_temp_theme_dir="$(dirname "$output_colors")"
newline=$'\n'
color_count=16

# GENERATE COLORSCHEME
get_colors() {
	mkdir -p "${_temp_theme_dir}"
	colors=($(magick "${wal}"  +dither -colors $color_count -unique-colors txt:- | grep -E -o " \#.{6}"))

	# If imagemagick finds less than 16 colors, use a larger source number of colors.
	while (( "${#colors[@]}" <= 15 )); do
		colors=($(magick "${wal}"  +dither -colors "$((color_count + ${index:-2}))" -unique-colors txt:- | grep -E -o " \#.{6}"))
		((index++))
		out "colors: Imagemagick couldn't generate a $color_count color palette, trying a larger palette size ($((color_count + index)))."

		# Quit the loop if we're taking too long.
		((index == 10)) && break
	done
	out "colors: Generated colorscheme"
}

export_colors() {
	set_color() {
		sh_colors+="color${1}='${2}'${newline}"
	}

	set_color 0  "${colors[0]}"

	set_color 1  "${colors[9]}"
	set_color 2  "${colors[10]}"
	set_color 3  "${colors[11]}"
	set_color 4  "${colors[12]}"
	set_color 5  "${colors[13]}"
	set_color 6  "${colors[14]}"
	set_color 7  "${colors[15]}"

	# Create a comment color based on the brightness of the background.
	case "${colors[0]:1:1}" in
		[0-1]) set_color 8 "#666666" ;;
		2)     set_color 8 "#757575" ;;
		[3-4]) set_color 8 "#999999" ;;
		5)     set_color 8 "#8a8a8a" ;;
		[6-9]) set_color 8 "#a1a1a1" ;;
		*)     set_color 8 "${colors[7]}" ;;
	esac

	set_color 9  "${colors[9]}"
	set_color 10 "${colors[10]}"
	set_color 11 "${colors[11]}"
	set_color 12 "${colors[12]}"
	set_color 13 "${colors[13]}"
	set_color 14 "${colors[14]}"
	set_color 15 "${colors[15]}"
	
	################################
	# export_colors
	printf "%s" "$sh_colors"  > "${output_colors}"
	out "export: Exported sh colors"
}

out() {
	printf "%s\n" "$1" >&2
}

# FINISH UP
main () {
	get_colors
	export_colors
	# Set the locale back to the original value.
	export LC_ALL="$sys_locale"
}

main
