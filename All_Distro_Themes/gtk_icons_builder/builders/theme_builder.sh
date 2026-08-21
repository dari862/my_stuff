#!/usr/bin/env bash
set -ueo pipefail

# --- Inputs ---
root="${1:-}"
icons_style_name="${2:-}"
output_theme_name="${3:-}"
icons_output_dir="${4:-$HOME/.icons/$output_theme_name}"
theme_file="${5:-}"

ICONS_PLACES_DEVICES_LIGHT_FOLDER=""
ICONS_PLACES_DEVICES_MEDIUM=""
ICONS_PLACES_DEVICES_DARK=""
ICONS_PLACES_DEVICES_SYMBOLIC_ACTION=""

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

copying_theme_template() {
	theme_template_path_="${1:-$icons_style_name_to_copy}"
    info_m "Copying ${theme_template_path_} theme template"
    cp -R "$root"/${theme_template_path_} "$tmp_dir/"
}

export_theme() {
    template_name="${1:-$icons_style_name_to_copy}"
    info_m "Exporting theme"
    sed -i "s/Name=.*/Name=$output_theme_name/g" "$tmp_dir/${template_name}/index.theme"
    
    rm -rf "$icons_output_dir"
    mkdir -p "$icons_output_dir"
    mv "$tmp_dir/${template_name}"/* "$icons_output_dir/"
    done_m "Theme was generated in $icons_output_dir"
}

replace_svg_colors() {
    hex_find="$1"
    hex_replace="$2"
    hex_fallover="$3"
    if [ -z "$hex_replace" ]; then
    	sub_info_m "set hex color to fallover"
    	hex_replace="$hex_fallover"
    fi
    info_m "Replacing colors ($hex_find -> $hex_replace)"
    for icon_path in ${targets[@]}; do
    	sed -i'' -e "s/$hex_find/$hex_replace/g" "${icon_path}"
    done
}

replacing_gradient_colors(){
	if [ -z "${SURUPLUS_GRADIENT1}" ] || [ "$SURUPLUS_GRADIENT_ENABLED" = false ]; then
		SURUPLUS_GRADIENT1="efefe7"
		sub_info_m "var SURUPLUS_GRADIENT1 are set to default colors"
	fi
	
	if [ -z "${SURUPLUS_GRADIENT2}" ] || [ "$SURUPLUS_GRADIENT_ENABLED" = false ]; then
		SURUPLUS_GRADIENT2="8f8f8b"
		sub_info_m "var SURUPLUS_GRADIENT2 are set to default colors"
	fi
	
	if [ "$SURUPLUS_GRADIENT_ENABLED" = false ]; then
		replacecolour_gradient="currentColor"
		sub_info_m "replaceing gradient default"
	else
		replacecolour_gradient="url(#oomox)"
		sub_info_m "replaceing gradient to new value"
	fi
	info_m "Replacing gradient colors"
   	for icon_path in ${targets[@]}; do
   		sed -i'' \
       		-e "s/replacecolour_gradient/$replacecolour_gradient/g" \
       		-e "s/replacecolour6/$SURUPLUS_GRADIENT1/g" \
       		-e "s/replacecolour7/$SURUPLUS_GRADIENT2/g" "$icon_path"
	done
}

change_icons_view_style(){
	source_places_icons_path="${1:-}"
	source_devices_icons_path="${2:-}"
	destination_places_icons_path="${3:-}"
	destination_devices_icons_path="${4:-}"
	destination_symbolic_place_path="${5:-}"
	destination_scalable_place_path="${6:-}"
	destination_symbolic_devices_path="${7:-}"
	replace_icons_view_with() {
		local source="$1"
		local destination_dir="$2"
		shift 2
		default_file="${1:-}"
		
		for icon_name in "$@"; do
			if [ -L "${source}/$icon_name" ];then
				cp -rfL "${source}/$icon_name" "$destination_dir"
			elif [ -f "${source}/$icon_name" ];then
				cp -rf "${source}/$icon_name" "$destination_dir"
			else
				ln -sfn "$default_file" "$destination_dir/$icon_name"
			fi
		done
		
		find "${source}" -type f -exec sed -i -e "s/replaceiconsviewcolourmain/$ICONS_VIEW/g" -e "s/replaceiconsviewcoloursecondary/$ICONS_VIEW2/g" {} +
	}
		sub_info_m "Running icon view configuration."
		if [ -f "${source_places_icons_path}/folder.svg" ]; then
			sub_info_m "Processing folder icons"
	
			replace_icons_view_with "${source_places_icons_path}" "${destination_places_icons_path}" \
				folder.svg \
				gnome-fs-directory.svg \
				gtk-directory.svg \
				inode-directory.svg \
				stock_folder.svg \
				folder-documents.svg \
				folder-download.svg \
				folder-music.svg \
				folder-pictures.svg \
				folder-video.svg \
				custom-folder.svg
	
			if [ -n "${destination_symbolic_place_path}" ]; then
				sub_info_m "Copying symbolic folder icons"
				replace_icons_view_with "${source_places_icons_path}" "${destination_symbolic_place_path}" \
					folder.svg \
					gnome-fs-directory.svg \
					gtk-directory.svg \
					inode-directory.svg \
					stock_folder.svg \
					folder-documents.svg \
					folder-download.svg \
					folder-music.svg \
					folder-pictures.svg \
					folder-video.svg \
					custom-folder.svg
			fi
	
			if [ -n "${destination_scalable_place_path}" ]; then
				sub_info_m "Copying scalable folder icons"
				replace_icons_view_with "${source_places_icons_path}" "${destination_scalable_place_path}" \
					folder.svg \
					gnome-fs-directory.svg \
					gtk-directory.svg \
					inode-directory.svg \
					stock_folder.svg \
					folder-documents.svg \
					folder-download.svg \
					folder-music.svg \
					folder-pictures.svg \
					folder-video.svg \
					custom-folder.svg
			fi
		fi
	
		# -------------------------------------------------------------------------
		# Network folder icons
		# -------------------------------------------------------------------------
		if [ -f "${source_places_icons_path}/folder-network.svg" ]; then
			sub_info_m "Processing network folder icons"
	
			replace_icons_view_with "${source_places_icons_path}" "${destination_places_icons_path}" \
				folder-network.svg \
				folder-html.svg \
				network.svg \
				repository.svg \
				network-workgroup.svg
	
			if [ -n "${destination_symbolic_place_path}" ]; then
				sub_info_m "Copying symbolic network folder icons"
				replace_icons_view_with "${source_places_icons_path}" "${destination_symbolic_place_path}" \
					folder-network.svg \
					folder-html.svg \
					network.svg \
					repository.svg \
					network-workgroup.svg
			fi
	
			if [ -n "${destination_scalable_place_path}" ]; then
				sub_info_m "Copying scalable network folder icons"
				replace_icons_view_with "${source_places_icons_path}" "${destination_scalable_place_path}" \
					folder-network.svg \
					folder-html.svg \
					network.svg \
					repository.svg \
					network-workgroup.svg
			fi
		fi
	
		# -------------------------------------------------------------------------
		# Phone device icons
		# -------------------------------------------------------------------------
		if [ -f "${source_devices_icons_path}/phone.svg" ]; then
			sub_info_m "Processing phone device icons"
	
			replace_icons_view_with "${source_devices_icons_path}" "${destination_devices_icons_path}" \
				phone.svg \
				blueman-cellular.svg \
				blueman-smart-phone.svg \
				gnome-phone-manager.svg \
				smartphone.svg \
				stock_cell-phone.svg
	
			if [ -n "${destination_symbolic_devices_path}" ]; then
				sub_info_m "Copying symbolic phone icons"
				replace_icons_view_with "${source_devices_icons_path}" "${destination_symbolic_devices_path}" \
					phone.svg \
					blueman-cellular.svg \
					blueman-smart-phone.svg \
					gnome-phone-manager.svg \
					smartphone.svg \
					stock_cell-phone.svg
			fi
		fi
	
		# -------------------------------------------------------------------------
		# USB removable media icons
		# -------------------------------------------------------------------------
		if [ -f "${source_devices_icons_path}/drive-removable-media-usb.svg" ]; then
			sub_info_m "Processing USB removable media icons"
	
			replace_icons_view_with "${source_devices_icons_path}" "${destination_devices_icons_path}" \
				drive-removable-media-usb.svg \
				device-notifier.svg \
				device_usb.svg
	
			if [ -n "${destination_symbolic_devices_path}" ]; then
				sub_info_m "Copying symbolic USB removable media icons"
				replace_icons_view_with "${source_devices_icons_path}" "${destination_symbolic_devices_path}" \
					drive-removable-media-usb.svg \
					device-notifier.svg \
					device_usb.svg
			fi
		fi
	
		# -------------------------------------------------------------------------
		# Hard disk drive icons
		# -------------------------------------------------------------------------
		if [ -f "${source_devices_icons_path}/drive-harddisk.svg" ]; then
			sub_info_m "Processing hard disk drive icons"
	
			replace_icons_view_with "${source_devices_icons_path}" "${destination_devices_icons_path}" \
				drive-harddisk.svg \
				drive-harddisk-root.svg \
				drive-harddisk-system.svg \
				drive-harddisk-ieee1394.svg \
				drive-removable-media.svg \
				gnome-dev-harddisk-1394.svg \
				gnome-dev-harddisk.svg \
				gnome-dev-harddisk-usb.svg \
				gnome-fs-blockdev.svg
	
			if [ -n "${destination_symbolic_devices_path}" ]; then
				sub_info_m "Copying symbolic hard disk drive icons"
				replace_icons_view_with "${source_devices_icons_path}" "${destination_symbolic_devices_path}" \
					drive-harddisk.svg \
					drive-harddisk-root.svg \
					drive-harddisk-system.svg \
					drive-harddisk-ieee1394.svg \
					drive-removable-media.svg \
					gnome-dev-harddisk-1394.svg \
					gnome-dev-harddisk.svg \
					gnome-dev-harddisk-usb.svg \
					gnome-fs-blockdev.svg
			fi
		fi
}

replace_icons_view_colors() {
	if [ "$icons_style_name_to_copy" = "gnome-colors" ];then
		return
	fi
	local base_dir="$tmp_dir/$icons_style_name_to_copy"
	local extra_icons_path="$root/extra_icons/$REPLACE_ICONS_VIEW"

	local use_x=""
	local skip_final_part=false

	local dir_16_path_=""
	local dir_22_path_=""
	local dir16_place_path_=""
	local dir16_devices_path_=""
	local dir22_place_path_=""
	local dir22_devices_path_=""
	local dir_symbolic_place_path_=""
	local dir_symbolic_devices_path_=""
	local dir_scalable_place_path_=""
	local dir_scalable_devices_path_=""

	replace_icon_colors() {
		local file="$1"
		
		sed -i \
			-e "s/replaceiconsviewcolourmain/$ICONS_VIEW/g" \
			-e "s/replaceiconsviewcoloursecondary/$ICONS_VIEW2/g" \
			"$file"
	}

	install_icon() {
		local source="$1"
		local destination_dir="$2"
		shift 2

		if [ -z "$destination_dir" ] || [ ! -f "$source" ] || [ ! -d "$destination_dir" ];then
			return 0
		fi

		local filename
		filename=$(basename "$source")

		cp -f "$source" "$destination_dir/$filename" || return 1

		local icon_name
		for icon_name in "$@"; do
			ln -sfn "$filename" "$destination_dir/$icon_name"
		done
	}

	process_icon() {
		local source="$1"
		local destination_dir="$2"
		shift 2

		if [ ! -f "$source" ] || [ ! -d "$destination_dir" ];then
			return 0
		fi

		local filename
		filename=$(basename "$source")

		cp -f "$source" "$destination_dir/$filename" || return 1
		replace_icon_colors "$destination_dir/$filename" || return 1

		local icon_name
		for icon_name in "$@"; do
			ln -sfn "$filename" "$destination_dir/$icon_name"
		done
	}

	change_icons_size_for_view() {
		local size_type="${1:-}"
		local from_size="${2:-}"
		local to_size="${3:-}"
		local directories="${4:-}"

		if [ "$size_type" = "x" ]; then
			from_size="${from_size}x${from_size}"
			to_size="${to_size}x${to_size}"
		fi

		local picked_dir
		local from_path
		local to_path

		for picked_dir in $directories; do
			sub_info_m "Applying changes to ${picked_dir}."

			if [ "$layout" = "places-first" ]; then
				from_path="$base_dir/$picked_dir/$from_size"
				to_path="$base_dir/$picked_dir/$to_size"

				rm -rdf "$from_path"
				ln -sfn "$from_size" "$to_path"
			else
				from_path="$base_dir/$from_size/$picked_dir"
				to_path="$base_dir/$to_size/$picked_dir"

				rm -rdf "$from_path"
				ln -sfn "$to_path" "$from_path"
			fi
		done
	}

	process_extra_icon() {
		local source="$1"
		local destination="$2"
		local symbolic_destination="$3"
		local scalable_destination="$4"
		shift 4

		[ -f "$source" ] || return 0

		process_icon "$source" "$destination" "$@"

		if [ -n "$symbolic_destination" ]; then
			install_icon "$destination/$(basename "$source")" \
				"$symbolic_destination" "$@"
		fi

		if [ -n "$scalable_destination" ]; then
			install_icon "$destination/$(basename "$source")" \
				"$scalable_destination" "$@"
		fi
	}

	info_m "Replacing icons view colors"

	sub_info_m "Locating base directory for icon style: $icons_style_name_to_copy"

	local switch_icons_view=false

	case "$REPLACE_ICONS_VIEW:$icons_style_name_to_copy" in
		simple:archdroid-icon-theme|simple:Suru++-Asprómauros|normal:Suru++-Asprómauros)
			switch_icons_view=true
			;;
	esac

	if [ "$switch_icons_view" = true ]; then
		error_m "Switch icons view from '$REPLACE_ICONS_VIEW' to 'original'."
		REPLACE_ICONS_VIEW=original
		extra_icons_path="$root/extra_icons/$REPLACE_ICONS_VIEW"
	fi

	sub_info_m "Checking directory structure and setting up paths"

	local size_dir=""
	local layout=""

	if [ -d "$base_dir/16" ]; then
		layout="size-first"
		size_dir="16"
		use_x=""
	elif [ -d "$base_dir/16x16" ]; then
		layout="size-first"
		size_dir="16x16"
		use_x="x"
	elif [ -d "$base_dir/places/16" ]; then
		layout="places-first"
		size_dir="16"
		use_x=""
	elif [ -d "$base_dir/places/16x16" ]; then
		layout="places-first"
		size_dir="16x16"
		use_x="x"
	else
		error_m "Unable to determine icon theme directory structure: $base_dir"
		return 1
	fi

	sub_info_m "Detected '$layout' icon directory structure"

	local dir_16_name="$size_dir"
	local dir_22_name

	if [ "$use_x" = "x" ]; then
		dir_22_name="22x22"
	else
		dir_22_name="22"
	fi

	if [ "$layout" = "places-first" ]; then
		dir_16_path_="$base_dir/places/$dir_16_name"
		dir_22_path_="$base_dir/places/$dir_22_name"

		dir16_place_path_="$base_dir/places/$dir_16_name"
		dir16_devices_path_="$base_dir/devices/$dir_16_name"

		dir22_place_path_="$base_dir/places/$dir_22_name"
		dir22_devices_path_="$base_dir/devices/$dir_22_name"
	else
		dir_16_path_="$base_dir/$dir_16_name"
		dir_22_path_="$base_dir/$dir_22_name"

		dir16_place_path_="$dir_16_path_/places"
		dir16_devices_path_="$dir_16_path_/devices"

		dir22_place_path_="$dir_22_path_/places"
		dir22_devices_path_="$dir_22_path_/devices"
	fi

	if [ -d "$dir_16_path_/symbolic" ]; then
		sub_info_m "Found symbolic directory"

		dir_symbolic_place_path_="$dir_16_path_/symbolic/places"
		dir_symbolic_devices_path_="$dir_16_path_/symbolic/devices"
	fi

	if [ -d "$base_dir/scalable" ]; then
		sub_info_m "Found scalable directory structure"

		dir_scalable_place_path_="$base_dir/scalable/places"
		dir_scalable_devices_path_="$base_dir/scalable/devices"
	fi

	case "$REPLACE_ICONS_VIEW" in

	original)
		sub_info_m "'original' icon view configuration was picked."
		;;

	normal)
		if [ "$icons_style_name_to_copy" = "Suru++" ]; then
			sub_info_m "Applying 'normal' configuration related to 'Suru++'"

			change_icons_view_style \
				"$base_dir/places/64" \
				"$base_dir/devices/64" \
				"$dir16_place_path_" \
				"$dir16_devices_path_" \
				"$dir_symbolic_place_path_" \
				"$dir_scalable_place_path_" \
				"$dir_symbolic_devices_path_"

			skip_final_part=true
		else
			sub_info_m "Applying 'normal' icon view configuration"

			ICONS_VIEW="$ICONS_LIGHT_FOLDER"

			change_icons_view_style \
				"$dir22_place_path_" \
				"$dir22_devices_path_" \
				"$dir16_place_path_" \
				"$dir16_devices_path_" \
				"$dir_symbolic_place_path_" \
				"$dir_scalable_place_path_" \
				"$dir_symbolic_devices_path_"

			if [ -d "${dir_16_path_}@2x" ]; then
				sub_info_m "Removing and linking ${dir_16_path_}@2x"

				rm -rdf "${dir_16_path_}@2x"
				ln -sfn "$dir_22_name" "${dir_16_path_}@2x"
			fi
		fi
		;;

	simple)
		case "$icons_style_name_to_copy" in

		Suru++)
			sub_info_m "Applying 'simple' configuration related to 'Suru++'"

			change_icons_size_for_view \
				"$use_x" 24 64 \
				"devices places mimetypes"

			change_icons_size_for_view \
				"$use_x" "24@2x" 64 \
				"devices places mimetypes"
			;;

		Papirus)
			sub_info_m "Applying 'simple' configuration related to 'Papirus'"

			rm -rdf "$base_dir/22x22"
			ln -sfn 16x16 "$base_dir/22x22"

			rm -rdf "$base_dir/24x24"
			ln -sfn 16x16 "$base_dir/24x24"
			;;

		Numix)
			sub_info_m "Applying 'simple' configuration related to 'Numix'"

			rm -rdf "$base_dir/22"
			ln -sfn 16 "$base_dir/22"

			rm -rdf "$base_dir/24"
			ln -sfn 16 "$base_dir/24"
			;;

		*)
			sub_info_m "Applying 'simple' configuration and copying extra templates"

			if [ "$APPLY_SIMPLE" = "all" ] ||
				[ "$APPLY_SIMPLE" = "devices" ]; then

				sub_info_m "Applying simple 'devices'"

				change_icons_view_style \
					"$dir16_devices_path_" "" \
					"$dir22_devices_path_" "" \
					"" "" ""
			fi

			if [ "$APPLY_SIMPLE" = "all" ] ||
				[ "$APPLY_SIMPLE" = "places" ]; then

				sub_info_m "Applying simple 'places'"

				change_icons_view_style \
					"$dir16_place_path_" "" \
					"$dir22_place_path_" "" \
					"" "" ""
			fi
			;;
		esac
		;;

	circle)
		sub_info_m "Applying 'circle' icon view configuration"

		process_extra_icon \
			"$extra_icons_path/folder.svg" \
			"$dir16_place_path_" \
			"$dir_symbolic_place_path_" \
			"$dir_scalable_place_path_" \
			gnome-fs-directory.svg \
			gtk-directory.svg \
			inode-directory.svg \
			stock_folder.svg \
			folder-documents.svg \
			folder-download.svg \
			folder-music.svg \
			folder-pictures.svg \
			folder-video.svg \
			custom-folder.svg

		process_extra_icon \
			"$extra_icons_path/folder-network.svg" \
			"$dir16_place_path_" \
			"$dir_symbolic_place_path_" \
			"$dir_scalable_place_path_" \
			folder-html.svg \
			network.svg \
			repository.svg \
			network-workgroup.svg

		process_extra_icon \
			"$extra_icons_path/phone.svg" \
			"$dir16_devices_path_" \
			"$dir_symbolic_devices_path_" \
			"" \
			blueman-cellular.svg \
			blueman-smart-phone.svg \
			gnome-phone-manager.svg \
			smartphone.svg \
			stock_cell-phone.svg

		process_extra_icon \
			"$extra_icons_path/drive-removable-media-usb.svg" \
			"$dir16_devices_path_" \
			"$dir_symbolic_devices_path_" \
			"" \
			device-notifier.svg \
			device_usb.svg

		process_extra_icon \
			"$extra_icons_path/drive-harddisk.svg" \
			"$dir16_devices_path_" \
			"$dir_symbolic_devices_path_" \
			"" \
			drive-harddisk-root.svg \
			drive-harddisk-system.svg \
			drive-harddisk-ieee1394.svg \
			drive-removable-media.svg \
			gnome-dev-harddisk-1394.svg \
			gnome-dev-harddisk.svg \
			gnome-dev-harddisk-usb.svg \
			gnome-fs-blockdev.svg
		;;

	*)
		error_m "Unknown icon view: $REPLACE_ICONS_VIEW"
		return 1
		;;
	esac

	if [ "$skip_final_part" = false ]; then
		sub_info_m "Gathering target files for global color replacement"
		targets=($(find "${dir16_place_path_}"/* -type f))
		
		if [ -z "$ICONS_VIEW" ]; then
			sub_info_m "Setting default fallback for ICONS_VIEW"
			ICONS_VIEW="$ICONS_LIGHT_FOLDER"
		fi
		info_m "Replacing colors (replaceiconsviewcolourmain -> $ICONS_VIEW)"
		
		sub_info_m "Applying color changes to all target files"
		for icon_path in ${targets[@]}; do
			if [ -f "$icon_path" ]; then
				replace_icon_colors "${icon_path}"
			fi
		done
	fi
}

# --- Initialization & Validation ---
check_var "output_theme_name" "$output_theme_name"
info_m "building ${output_theme_name}"
check_var "theme_file" "$theme_file"

source "$theme_file"

if [ -z "$ICONS_PLACES_DEVICES_LIGHT_FOLDER" ];then
	ICONS_PLACES_DEVICES_LIGHT_FOLDER="$ICONS_LIGHT_FOLDER"
fi

if [ -z "$ICONS_PLACES_DEVICES_MEDIUM" ];then
	ICONS_PLACES_DEVICES_MEDIUM="$ICONS_MEDIUM"
fi

if [ -z "$ICONS_PLACES_DEVICES_DARK" ];then
	ICONS_PLACES_DEVICES_DARK="$ICONS_DARK"
fi

if [ -z "$ICONS_PLACES_DEVICES_SYMBOLIC_ACTION" ];then
	ICONS_PLACES_DEVICES_SYMBOLIC_ACTION="$ICONS_SYMBOLIC_ACTION"
fi

SURUPLUS_GRADIENT_ENABLED=$(echo "${SURUPLUS_GRADIENT_ENABLED-False}" | tr '[:upper:]' '[:lower:]')
targets=()

# --- Theme Processing Styles ---
case "$icons_style_name" in
    archdroid)
    	icons_style_name_to_copy="archdroid-icon-theme"
        check_var "ICONS_ARCHDROID" "${ICONS_ARCHDROID:-}"
        copying_theme_template
        targets=($(find "$tmp_dir/archdroid-icon-theme" -type f))
        replace_svg_colors "replacecolour1" "$ICONS_ARCHDROID" "CDDC39"
        ;;
    papirus_icons)
    	icons_style_name_to_copy="Papirus"
        copying_theme_template
        
        for size in 22x22 24x24 32x32 48x48 64x64; do
			for icon_path in \
				"$tmp_dir/Papirus/$size/places/folder-generated"{-*,}.svg \
				"$tmp_dir/Papirus/$size/places/user-generated"{-*,}.svg
			do
				[ -f "$icon_path" ] || continue
				[ -L "$icon_path" ] && continue
				targets+=("$icon_path")
			done
		done
		info_m "Replacing accent colors"
		find "$tmp_dir/Papirus/22x22/places" "$tmp_dir/Papirus/24x24/places" "$tmp_dir/Papirus/32x32/places" "$tmp_dir/Papirus/48x48/places" "$tmp_dir/Papirus/64x64/places" \
			\( -name "folder-generated*.svg" -o -name "user-generated*.svg" \) -type f ! -type l -exec sed -i'' -e "s|replacecolour1|$ICONS_LIGHT_FOLDER|g" -e "s|replacecolour2|$ICONS_MEDIUM|g" -e "s|replacecolour3|$ICONS_DARK|g" {} +
		
		targets=($(find "$tmp_dir"/Papirus/{16x16,22x22,24x24}/{symbolic,actions} \
		-type f -name '*.svg'))
        replace_svg_colors "replacecolour4" "${ICONS_SYMBOLIC_ACTION}" "444444"
        
        targets=($(find "$tmp_dir"/Papirus/16x16/devices \
		-type f -name '*.svg'))
        replace_svg_colors "replacecolour4" "${ICONS_PLACES_DEVICES_SYMBOLIC_ACTION}" "444444"
        
        targets=($(find "$tmp_dir"/Papirus/{16x16,22x22,24x24}/panel \
		"$tmp_dir"/Papirus/{22x22,24x24}/animations \
		-type f -name '*.svg'))
        replace_svg_colors "replacecolour5" "${ICONS_SYMBOLIC_PANEL}" "dfdfdf"
        ;;
    numix_icons)
    	icons_style_name_to_copy="Numix"
        NUMIX_SHAPE="${ICONS_NUMIX_SHAPE-normal}"
        copying_theme_template "numix-icon-theme/Numix"
        copying_theme_template "numix-icon-theme/numix-folders/${ICONS_NUMIX_STYLE}/*"
        
        info_m "Replacing colors"
        find "${tmp_dir}"/Numix/*/actions/*custom* -type f -exec sed -i --follow-symlinks \
            -e "s/replacecolour1/${ICONS_LIGHT_FOLDER}/g" \
            -e "s/replacecolour2/${ICONS_MEDIUM}/g" \
            -e "s/replacecolour3/${ICONS_DARK}/g" {} +
		
		find "${tmp_dir}"/Numix/*/places/*custom* -type f -exec sed -i --follow-symlinks \
            -e "s/replacecolour1/${ICONS_PLACES_DEVICES_LIGHT_FOLDER}/g" \
            -e "s/replacecolour2/${ICONS_PLACES_DEVICES_MEDIUM}/g" \
            -e "s/replacecolour3/${ICONS_PLACES_DEVICES_DARK}/g" {} +
            
        info_m "Creating symlinks"
        currentcolour=$(readlink "${tmp_dir}"/Numix/16/places/folder.svg | cut -d '-' -f 1)
        while IFS= read -r -d '' link; do
            [[ $link == *folder_color* ]] && continue
            newlink=$(readlink "${link}")
            if [[ $newlink == *"$currentcolour"* ]]; then
                ln -sf "${newlink/${currentcolour}/custom}" "${link}"
            fi
        done < <(find -L "${tmp_dir}"/Numix/*/{actions,places} -xtype l -print0)

        info_m "Applying style"
        if [[ ${NUMIX_SHAPE} == 'circle' || ${NUMIX_SHAPE} == 'square' ]] ; then
            cp -rH "${tmp_dir}/Numix-${NUMIX_SHAPE^}/"* "${tmp_dir}"/Numix/
        fi
        ;;
    suruplus_aspromauros_icons)
    	icons_style_name_to_copy="Suru++-Asprómauros"
        copying_theme_template
        targets=($(find "$tmp_dir"/Suru++-Asprómauros/actions/{16,22,24,symbolic} \
		"$tmp_dir"/Suru++-Asprómauros/apps/{16,symbolic} \
		"$tmp_dir"/Suru++-Asprómauros/emblems/symbolic \
		"$tmp_dir"/Suru++-Asprómauros/emotes/symbolic \
		"$tmp_dir"/Suru++-Asprómauros/mimetypes/16 \
		"$tmp_dir"/Suru++-Asprómauros/panel/{16,22,24} \
		"$tmp_dir"/Suru++-Asprómauros/status/symbolic \
		-type f -name '*.svg'))
        
        replace_svg_colors "replacecolour4" "${ICONS_SYMBOLIC_ACTION}" "ececec"
        
        targets=($(find "$tmp_dir"/Suru++-Asprómauros/places/{16,symbolic} \
        "$tmp_dir"/Suru++-Asprómauros/devices/{16,symbolic}	-type f -name '*.svg'))
        
        replace_svg_colors "replacecolour4" "${ICONS_PLACES_DEVICES_SYMBOLIC_ACTION}" "ececec"
        
		targets=($(find "$tmp_dir"/Suru++-Asprómauros/animations/{22,24} -type f -name '*.svg'))
		replace_svg_colors "replacecolour5" "${ICONS_SYMBOLIC_PANEL}" "d3dae3"
		
        targets=($(find "$tmp_dir"/Suru++-Asprómauros/actions/{16,22,24,symbolic} \
		"$tmp_dir"/Suru++-Asprómauros/apps/{16,symbolic} \
		"$tmp_dir"/Suru++-Asprómauros/devices/{16,symbolic} \
		"$tmp_dir"/Suru++-Asprómauros/emblems/symbolic \
		"$tmp_dir"/Suru++-Asprómauros/emotes/symbolic \
		"$tmp_dir"/Suru++-Asprómauros/mimetypes/16 \
		"$tmp_dir"/Suru++-Asprómauros/panel/{16,22,24} \
		"$tmp_dir"/Suru++-Asprómauros/places/{16,symbolic} \
		"$tmp_dir"/Suru++-Asprómauros/status/symbolic \
		-type f -name '*.svg'))
		replacing_gradient_colors
        ;;
    suruplus_icons)
    	icons_style_name_to_copy="Suru++"
        copying_theme_template
        
		info_m "Replacing accent colors"
		find "$tmp_dir/Suru++/places/64" \( -name "folder-generated*.svg" -o -name "user-generated*.svg" \) -type f ! -type l \
			-exec sed -i'' -e "s|replacecolour1|$ICONS_LIGHT_FOLDER|g" -e "s|replacecolour2|$ICONS_MEDIUM|g" -e "s|replacecolour3|$ICONS_DARK|g" {} +
			
		targets=($(find "$tmp_dir"/Suru++/actions/{16,22,24,symbolic} \
		"$tmp_dir"/Suru++/apps/{16,symbolic} \
		"$tmp_dir"/Suru++/mimetypes/16 \
		"$tmp_dir"/Suru++/status/symbolic \
		-type f -name '*.svg'))
        replace_svg_colors "replacecolour4" "${ICONS_SYMBOLIC_ACTION}" "5c616c"
        
        targets=($(find "$tmp_dir"/Suru++/devices/{16,symbolic} \
		"$tmp_dir"/Suru++/places/{16,symbolic} \
		-type f -name '*.svg'))
        replace_svg_colors "replacecolour4" "${ICONS_PLACES_DEVICES_SYMBOLIC_ACTION}" "5c616c"
        
        targets=($(find "$tmp_dir"/Suru++/panel/{16,22,24} "$tmp_dir"/Suru++/animations/{22,24} -type f -name '*.svg'))
        replace_svg_colors "replacecolour5" "${ICONS_SYMBOLIC_PANEL}" "d3dae3"

		targets=($(find "$tmp_dir"/Suru++/apps/16 \
		"$tmp_dir"/Suru++/devices/16 \
		"$tmp_dir"/Suru++/mimetypes/16 \
		"$tmp_dir"/Suru++/places/16 \
		-type f -name '*.svg'))
		replacing_gradient_colors 
        ;;
    gnome_colors)
    	icons_style_name_to_copy="gnome-colors"
        copying_theme_template
        if [ -z "$ICONS_LIGHT_FOLDER" ];then
        	ICONS_LIGHT_FOLDER="8fb3d9"
        fi
        if [ -z "$ICONS_MEDIUM" ];then
        	ICONS_MEDIUM="3465a4"
        fi
        if [ -z "$ICONS_DARK" ];then
        	ICONS_DARK="204a87"
        fi
        if [ -z "$ICONS_LIGHT" ];then
        	ICONS_LIGHT="729fcf"
        fi
        info_m "Replacing 4 colors (replacecolour1 -> $ICONS_LIGHT_FOLDER)"
        info_m "                   (replacecolour2 -> $ICONS_MEDIUM)"
        info_m "                   (replacecolour3 -> $ICONS_DARK)"
        info_m "                   (replacecolour8 -> $ICONS_LIGHT)"
        targets=($(find "${tmp_dir}/${icons_style_name_to_copy}" ! -type l -type f -name '*.svg'))
    	for icon_path in ${targets[@]}; do
    		sed -i'' -e "s/replacecolour1/${ICONS_LIGHT_FOLDER}/g;s/replacecolour2/${ICONS_MEDIUM}/g;s/replacecolour3/${ICONS_DARK}/g;s/replacecolour8/${ICONS_LIGHT}/g" "${icon_path}"
    	done
    	
    	targets=($(find "${tmp_dir}/${icons_style_name_to_copy}" -name '*.render2png.svg'))
    	for svgfile in ${targets[@]}; do
    		pngfile=""
    		pngfile="${svgfile%.render2png.svg}.png"
    		magick "$svgfile" -format png "$pngfile" || true
    	done
    	targets=($(cd "${tmp_dir}/${icons_style_name_to_copy}/22x22" && find . -name '*.render2png.svg'))
    	for svgfile in ${targets[@]}; do
    		pngfile=""
    		pngfile="${svgfile%.render2png.svg}.png"
    		magick "${tmp_dir}/${icons_style_name_to_copy}/22x22/$svgfile" -bordercolor Transparent -border 1x1 "${tmp_dir}/${icons_style_name_to_copy}/24x24/$pngfile" || true
    	done
        ;;
esac
replace_icons_view_colors
export_theme
