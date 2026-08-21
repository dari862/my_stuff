#!/bin/sh
#===================================================================================
. "$__distro_path_lib"
screen_shot_output_dir="$HOME/Pictures/test_output"
current_path="$(dirname "$(realpath "$0")")"
current_path="$(cd "${current_path}" && cd .. && pwd)"

picknewthemes(){
	new_theme="${1:-}"
	sed -i "s|Net/ThemeName .*|Net/ThemeName \"$new_theme\"|g" $HOME/.config/xsettingsd/xsettingsd.conf
	sed -i "s/gtk-theme-name=.*/gtk-theme-name=\"$new_theme\"/g" $HOME/.config/gtk-2.0/gtkrc-2.0
	sed -i "s/gtk-theme-name=.*/gtk-theme-name=$new_theme/g" $HOME/.config/gtk-3.0/settings.ini
	"${__distro_path_root}"/bin/X11/WM/reload_gtk23
}

take_screen_show(){
	output_name="${1:-}"
	my-shots --now --path "$screen_shot_output_dir" --name "${output_name}" --no-view --no-copy --no-notify
}

info_m() {
	message="${1-}"
	color="36"
	printf '%b' "\\033[1;${color}m:: ${message} ...\\033[0m\n"
}

if [ -d "$screen_shot_output_dir" ];then
	rm -rdf "$screen_shot_output_dir"
fi

cd "${current_path}/source_base"
echo "running test:"
for i in *;do
	info_m "${i}1"
	picknewthemes "${i}1"
	sleep 1
	take_screen_show "${i}-my"
	sleep 1
	
	info_m "${i}"
	picknewthemes "${i}"
	sleep 1
	take_screen_show "${i}-org"
	sleep 1
done
echo "Done testing"
