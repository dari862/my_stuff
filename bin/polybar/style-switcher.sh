#!/usr/bin/env bash
# Color files
. "/usr/share/DmDmDmdMdMdM/lib/common/polybar"
. "/usr/share/DmDmDmdMdMdM/lib/common/rofi"

style_name=""

if [ "$polybar_STYLE" == "blocks" ]
then
change_color() {
	# polybar
	sed -i -e "s/background = #.*/background = $BG/g" "$polybar_style_dir"/colors.ini
	sed -i -e "s/background-alt = #.*/background-alt = $BGA/g" "$polybar_style_dir"/colors.ini
	sed -i -e "s/foreground = #.*/foreground = $FG/g" "$polybar_style_dir"/colors.ini
	sed -i -e "s/foreground-alt = #.*/foreground-alt = $FGA/g" "$polybar_style_dir"/colors.ini
	sed -i -e "s/primary = #.*/primary = $AC/g" "$polybar_style_dir"/colors.ini
	
	# rofi
	cat > "$rofi_style_dir"/colors.rasi <<- EOF
	/* colors */

	* {
	  al:   #00000000;
	  bg:   ${BG}FF;
	  bga:  ${BGA}FF;
	  fga:  ${FGA}FF;
	  fg:   ${FG}FF;
	  ac:   ${AC}FF;
	  se:   ${AC}40;
	}
	EOF
	
	polybar-msg cmd restart
}

elif [ "$polybar_STYLE" == "cuts" ]
then
change_color() {
	# polybar
	sed -i -e "s/background = #.*/background = #${BG}/g" "$polybar_style_dir"/colors.ini
	sed -i -e "s/background-alt = #.*/background-alt = #8C${BG}/g" "$polybar_style_dir"/colors.ini
	sed -i -e "s/foreground = #.*/foreground = #${FG}/g" "$polybar_style_dir"/colors.ini
	sed -i -e "s/foreground-alt = #.*/foreground-alt = #33${FG}/g" "$polybar_style_dir"/colors.ini
	sed -i -e "s/primary = #.*/primary = $AC/g" "$polybar_style_dir"/colors.ini
	
	# rofi
	cat > "$rofi_style_dir"/colors.rasi <<- EOF
	/* colors */

	* {
	  al:   #00000000;
	  bg:   #${BG}BF;
	  bga:  #${BG}FF;
	  fg:   #${FG}FF;
	  ac:   ${AC}FF;
	  se:   ${AC}1A;
	}
	EOF
	
	polybar-msg cmd restart
}
elif [ "$polybar_STYLE" == "forest" ] || [ "$polybar_STYLE" == "forest_large" ]
then
# Change colors
change_color() {
	# polybar
	sed -i -e "s/background = #.*/background = $BG/g" "$polybar_style_dir"/colors.ini
	sed -i -e "s/foreground = #.*/foreground = $FG/g" "$polybar_style_dir"/colors.ini
	sed -i -e "s/sep = #.*/sep = $SEP/g" "$polybar_style_dir"/colors.ini
	
	# rofi
	cat > "$rofi_style_dir"/colors.rasi <<- EOF
	/* colors */

	* {
	  al:   #00000000;
	  bg:   ${BG}FF;
	  bga:  ${BGA}FF;
	  fg:   ${FG}FF;
	  ac:   ${AC}FF;
	  se:   ${SE}FF;
	}
	EOF
	
	polybar-msg cmd restart
}

elif [ "$polybar_STYLE" == "pwidgets" ]
then
# Change colors
change_color() {
	# polybar
	sed -i -e "s/bg = #.*/bg = #FF${BG}/g" "$polybar_style_dir"/colors.ini
	sed -i -e "s/fg = #.*/fg = #FF${FG}/g" "$polybar_style_dir"/colors.ini
	sed -i -e "s/fga = #.*/fga = #FF${RFG}/g" "$polybar_style_dir"/colors.ini
	sed -i -e "s/ac = #.*/ac = #FF${AC}/g" "$polybar_style_dir"/colors.ini
	
	# rofi
	cat > "$rofi_style_dir"/colors.rasi <<- EOF
	/* colors */

	* {
	  al:   #00000000;
	  bg:   #${BG}FF;
	  fg:   #${RFG}FF;
	  ac:   #${AC}FF;
	}
	EOF
	
	polybar-msg cmd restart
}


elif [[ "$polybar_STYLE" == "panels/"* ]]
then
	change_panel() {
		# Change Polybar style
		echo "$style_name" > "$polybar_style_name_path"
		
		# Change rofi style
		echo "$style_name" > "$rofi_style_name_path"
		
		# Change wallpaper
		nitrogen --save --set-zoom-fill /usr/share/DmDmDmdMdMdM/my_wallpapers/"$bg"
		
		# Restarting polybar
		polybar_launch
	}
fi








if [ "$polybar_STYLE" == "blocks" ]
then
	if  [[ $1 = "--default" ]]; then
		BG="#2f343f"
		BGA="#C4C7C5"
		FGA="#C4C7C5"
		FG="#1C1E20"
		AC="#B4BC67"
		change_color
	elif  [[ $1 = "--nord" ]]; then
		BG="#3B4252"
		BGA="#4C566A"
		FGA="#E5E9F0"
		FG="#ECEFF4"
		AC="#A3BE8C"
		change_color
	elif  [[ $1 = "--gruvbox" ]]; then
		BG="#282828"
		BGA="#EBDBB2"
		FGA="#EBDBB2"
		FG="#282828"
		AC="#CC241D"
		change_color
	elif  [[ $1 = "--adapta" ]]; then
		BG="#243035"
		BGA="#38444A"
		FGA="#FDF6E3"
		FG="#FFFFFF"
		AC="#4DD0E1"
		change_color
	elif  [[ $1 = "--cherry" ]]; then
		BG="#1F1626"
		BGA="#423949"
		FGA="#FFFFFF"
		FG="#FFFFFF"
		AC="#D94085"
		change_color
	else
		cat <<- _EOF_
		No option specified, Available options:
		--default    --nord    --gruvbox    --adapta    --cherry
		_EOF_
	fi

elif [ "$polybar_STYLE" == "cuts" ]
then
	if  [[ $1 = "--mode1" ]]; then
		BG="0a0a0a"
		FG="f5f5f5"
		AC="#fdd835"
		change_color
	elif  [[ $1 = "--mode2" ]]; then
		BG="263238"
		FG="DFDFDF"
		AC="#00BCD4"
		change_color
	elif  [[ $1 = "--mode3" ]]; then
		BG="112526"
		FG="C4AAA5"
		AC="#EE7313"
		change_color
	elif  [[ $1 = "--mode4" ]]; then
		BG="461320"
		FG="f5f5f5"
		AC="#fdd835"
		change_color
	elif  [[ $1 = "--mode5" ]]; then
		BG="092F1C"
		FG="f5f5f5"
		AC="#fdd835"
		change_color
	elif  [[ $1 = "--mode6" ]]; then
		BG="003C3C"
		FG="CFCFCF"
		AC="#00acc1"
		change_color
	elif  [[ $1 = "--mode7" ]]; then
		BG="3C3836"
		FG="EBDBB2"
		AC="#FB4934"
		change_color
	elif  [[ $1 = "--mode8" ]]; then
		BG="2E3440"
		FG="D8DEE9"
		AC="#BF616A"
		change_color
	elif  [[ $1 = "--mode9" ]]; then
		BG="002b36"
		FG="839496"
		AC="#b58900"
		change_color
	elif  [[ $1 = "--mode10" ]]; then
		BG="1F1626"
		FG="FFFFFF"
		AC="#FFD16F"
		change_color
	else
		cat <<- _EOF_
		No option specified, Available options:
		--mode1   --mode2   --mode3   --mode4   --mode5
		--mode6   --mode7   --mode8   --mode9   --mode10
		_EOF_
	fi
elif [ "$polybar_STYLE" == "forest" ] || [ "$polybar_STYLE" == "forest_large" ]
then
	if  [[ $1 = "--default" ]]; then
		BG="#212B30"
		FG="#C4C7C5"
		BGA="#263035"
		SEP="#3F5360"
		AC="#EC407A"
		SE="#4DD0E1"
		change_color
	elif  [[ $1 = "--nord" ]]; then
		BG="#3B4252"
		FG="#E5E9F0"
		BGA="#454C5C"
		SEP="#5B6579"
		AC="#BF616A"
		SE="#88C0D0"
		change_color
	elif  [[ $1 = "--gruvbox" ]]; then
		BG="#282828"
		FG="#EBDBB2"
		BGA="#313131"
		SEP="#505050"
		AC="#FB4934"
		SE="#8EC07C"
		change_color
	elif  [[ $1 = "--dark" ]]; then
		BG="#141C21"
		FG="#93A1A1"
		BGA="#1E262B"
		SEP="#3C4449"
		AC="#D12F2C"
		SE="#33C5BA"
		change_color
	elif  [[ $1 = "--cherry" ]]; then
		BG="#1F1626"
		FG="#FFFFFF"
		BGA="#292030"
		SEP="#473F4E"
		AC="#D94084"
		SE="#4F5D95"
		change_color
	else
		cat <<- _EOF_
		No option specified, Available options:
		--default    --nord    --gruvbox    --dark    --cherry
		_EOF_
	fi
elif [ "$polybar_STYLE" == "pwidgets" ]
then
	if  [[ $1 = "--default" ]]; then
		BG="212B30"
		FG="C4C7C5"
		RFG="C4C7C5"
		AC="51B4FF"
		change_color
	elif  [[ $1 = "--nord" ]]; then
		BG="3B4252"
		FG="E5E9F0"
		RFG="E5E9F0"
		AC="A3BE8C"
		change_color
	elif  [[ $1 = "--gruvbox" ]]; then
		BG="282828"
		FG="EBDBB2"
		RFG="EBDBB2"
		AC="FB4934"
		change_color
	elif  [[ $1 = "--dark" ]]; then
		BG="141C21"
		FG="f5f5f5"
		RFG="f5f5f5"
		AC="FFE744"
		change_color
	elif  [[ $1 = "--cherry" ]]; then
		BG="1F1626"
		FG="FFFFFF"
		RFG="FFFFFF"
		AC="D94084"
		change_color
	elif  [[ $1 = "--white" ]]; then
		BG="FFFFFF"
		FG="FFFFFF"
		RFG="454545"
		AC="1565C0"
		change_color
	elif  [[ $1 = "--black" ]]; then
		BG="0a0a0a"
		FG="0a0a0a"
		RFG="a0a0a0"
		AC="40D8EB"
		change_color
	else
		cat <<- _EOF_
		No option specified, Available options:
		--default    --nord    --gruvbox    --dark    --cherry
		--white      --black
		_EOF_
	fi
elif [[ "$polybar_STYLE" == "panels/"* ]]
then
	if  [[ "$1" = "--budgie" ]]; then
		style_name="panels/budgie"
		bg="budgie.jpg"
		change_panel

	elif  [[ "$1" = "--deepin" ]]; then
		style_name="panels/deepin"
		bg="deepin.jpg"
		change_panel

	elif  [[ "$1" = "--elight" ]]; then
		style_name="panels/elementary"
		bg="elementary.jpg"
		change_panel

	elif  [[ "$1" = "--edark" ]]; then
		style_name="panels/elementary_dark"
		bg="elementary_2.jpg"
		change_panel

	elif  [[ "$1" = "--gnome" ]]; then
		style_name="panels/gnome"
		bg="gnome.jpg"
		change_panel

	elif  [[ "$1" = "--klight" ]]; then
		style_name="panels/kde"
		bg="kde.jpg"
		change_panel

	elif  [[ "$1" = "--kdark" ]]; then
		style_name="panels/kde_dark"
		bg="kde_2.jpg"
		change_panel

	elif  [[ "$1" = "--liri" ]]; then
		style_name="panels/liri"
		bg="liri.png"
		change_panel

	elif  [[ "$1" = "--mint" ]]; then
		style_name="panels/mint"
		bg="mint.jpg"
		change_panel

	elif  [[ "$1" = "--ugnome" ]]; then
		style_name="panels/ubuntu_gnome"
		bg="ubuntu.jpg"
		change_panel

	elif  [[ "$1" = "--unity" ]]; then
		style_name="panels/ubuntu_unity"
		bg="ubuntu.jpg"
		change_panel

	elif  [[ "$1" = "--xubuntu" ]]; then
		style_name="panels/xubuntu"
		bg="xubuntu.png"
		change_panel

	elif  [[ "$1" = "--zorin" ]]; then
		style_name="panels/zorin"
		bg="zorin.png"
		change_panel

	else
		cat <<- _EOF_
		No option specified, Available options:
		--budgie   --deepin   --elight   --edark   --gnome   --klight
		--kdark   --liri   --mint   --ugnome   --unity   --xubuntu
		--zorin
		_EOF_
	fi
else
	echo "something wrong"
fi
