#!/bin/sh
#===================================================================================
. "$__distro_path_lib"
screen_shot_output_dir="$HOME/Pictures/test_output"
current_path="$(dirname "$(realpath "$0")")"
current_path="$(cd "${current_path}" && cd .. && pwd)"

picknewthemes(){
	post_new_theme_name="${1:-}"
	new_theme_name="$(grep "gtk-theme-name=" "$HOME"/.config/gtk-3.0/settings.ini | awk -F= '{print $2}')"
	new_theme_name="${new_theme_name}1"
	sed -i "s|Net/ThemeName .*|Net/ThemeName  ${new_theme_name}${post_new_theme_name}|g" $HOME/.config/xsettingsd/xsettingsd.conf
	sed -i "s/gtk-theme-name=.*/gtk-theme-name=\"${new_theme_name}${post_new_theme_name}\"/g" $HOME/.config/gtk-2.0/gtkrc-2.0
	sed -i "s/gtk-theme-name=.*/gtk-theme-name=${new_theme_name}${post_new_theme_name}/g" $HOME/.config/gtk-3.0/settings.ini
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

test_panel_style(){
	_panel_name_="${1:-polybar}"
	blob_list=""
	new_themes_list=""
	styles_list=""
	blob_path="${__distro_path_root}/blob/${_panel_name_}"
	
	info_m "Testing ${_panel_name_}"
	cd "${current_path}/source_base"

	for file in *;do
		new_themes_list="$file|${new_themes_list}"
	done
	new_themes_list="${new_themes_list%?}"
	
	cd "${blob_path}"
	styles_list="$(grep -rEi "${new_themes_list}" | grep ":gtk_theme_name=" | awk -F'/' '{print $1}' | grep -v "owl4ce")"

	for check in ${styles_list};do
		info_m "check : ${check}"
		file_name="${_panel_name_}_${check}"
		"${__distro_path_root}"/bin/X11/WM/style_changer "${_panel_name_}" "${check}"
		sleep 1
		take_screen_show "${file_name}-org"
		sleep 1
		picknewthemes "1"
		sleep 1
		take_screen_show "${file_name}-new"
		sleep 1
	done
	info_m "Done tesing ${_panel_name_}"
}

if [ -d "$screen_shot_output_dir" ];then
	rm -rdf "$screen_shot_output_dir"
fi

echo "running test:"
test_panel_style polybar
test_panel_style tint2
echo "Done testing"
