#!/bin/sh

# Color files
. "/usr/share/my_stuff/lib/common/Distro_path"
. "${__distro_path_root}/lib/common/WM"
. "${Distro_config_file}"

# Change colors
if [ "$polybar_STYLE" = "colorblocks" ] || [ "$polybar_STYLE" = "shades" ]
then
	change_color() {
	# polybar
	if [ "$polybar_STYLE" = "colorblocks" ]
	then
		sed -i -e 's/background = #.*/background = #141C21/g' $HOME/.config/polybar/$polybar_STYLE/colors.ini
		sed -i -e "s/foreground = #.*/foreground = $FG/g" $HOME/.config/polybar/$polybar_STYLE/colors.ini
	else
		sed -i -e 's/background = #.*/background = #1F1F1F/g' $HOME/.config/polybar/$polybar_STYLE/colors.ini
		sed -i -e 's/foreground = #.*/foreground = #FFFFFF/g' $HOME/.config/polybar/$polybar_STYLE/colors.ini
	fi
	if [ "$polybar_STYLE" = "colorblocks" ]
	then
	sed -i -e 's/foreground-alt = #.*/foreground-alt = #FFFFFF/g' $HOME/.config/polybar/$polybar_STYLE/colors.ini
	else
		sed -i -e 's/foreground-alt = #.*/foreground-alt = #FFFFFF/g' $HOME/.config/polybar/$polybar_STYLE/colors.ini
	fi
	sed -i -e "s/shade1 = #.*/shade1 = $SH1/g" $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e "s/shade2 = #.*/shade2 = $SH2/g" $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e "s/shade3 = #.*/shade3 = $SH3/g" $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e "s/shade4 = #.*/shade4 = $SH4/g" $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e "s/shade5 = #.*/shade5 = $SH5/g" $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e "s/shade6 = #.*/shade6 = $SH6/g" $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e "s/shade7 = #.*/shade7 = $SH7/g" $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e "s/shade8 = #.*/shade8 = $SH8/g" $HOME/.config/polybar/$polybar_STYLE/colors.ini
	
	
	if [ "$polybar_STYLE" = "colorblocks" ]
	then
		rofi_bg="#141C21FF"
	else
		rofi_bg="#1F1F1FFF"
	fi
	# rofi
	tee $HOME/.config/rofi/$ROFI_STYLE/colors.rasi <<- EOF > /dev/null
	/* colors */

	* {
	  al:    #00000000;
	  bg:    ${rofi_bg};
	  bg1:   ${SH8}FF;
	  bg2:   ${SH7}FF;
	  bg3:   ${SH6}FF;
	  bg4:   ${SH5}FF;
	  fg:    #FFFFFFFF;
	}
	EOF
	
	polybar-msg cmd restart
	}
elif [ "$polybar_STYLE" = "docky" ] || [ "$polybar_STYLE" = "material" ]
then
	change_color() {
	# polybar
	sed -i -e 's/background = #.*/background = #1F1F1F/g' $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e 's/foreground = #.*/foreground = #FFFFFF/g' $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e 's/foreground-alt = #.*/foreground-alt = #8F8F8F/g' $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e "s/module-fg = #.*/module-fg = $MF/g" $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e "s/primary = #.*/primary = $AC/g" $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e 's/secondary = #.*/secondary = #E53935/g' $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e 's/alternate = #.*/alternate = #7cb342/g' $HOME/.config/polybar/$polybar_STYLE/colors.ini
	
	# rofi
	tee $HOME/.config/rofi/$ROFI_STYLE/colors.rasi <<- EOF > /dev/null
	/* colors */

	* {
	  al:   #00000000;
	  bg:   #1F1F1FFF;
	  bga:  ${AC}33;
	  bar:  ${MF}FF;
	  fg:   #FFFFFFFF;
	  ac:   ${AC}FF;
	}
	EOF
	
	polybar-msg cmd restart
	}
elif [ "$polybar_STYLE" = "cuts" ]
then
	BG="0a0a0a"
	FG="f5f5f5"

	# Change colors
	change_color() {
		# polybar
		sed -i -e "s/background = #.*/background = #${BG}/g" $HOME/.config/polybar/$polybar_STYLE/colors.ini
		sed -i -e "s/background-alt = #.*/background-alt = #8C${BG}/g" $HOME/.config/polybar/$polybar_STYLE/colors.ini
		sed -i -e "s/foreground = #.*/foreground = #${FG}/g" $HOME/.config/polybar/$polybar_STYLE/colors.ini
		sed -i -e "s/foreground-alt = #.*/foreground-alt = #33${FG}/g" $HOME/.config/polybar/$polybar_STYLE/colors.ini
		sed -i -e "s/primary = #.*/primary = $AC/g" $HOME/.config/polybar/$polybar_STYLE/colors.ini
		
		# rofi
		tee $HOME/.config/rofi/$ROFI_STYLE/colors.rasi <<- EOF > /dev/null
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
elif [ "$polybar_STYLE" = "grayblocks" ] 
then
	change_color() {
	# polybar
	sed -i -e 's/background = #.*/background = #272727/g' $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e 's/background-alt = #.*/background-alt = #383838/g' $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e 's/foreground = #.*/foreground = #CACACA/g' $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e 's/foreground-alt = #.*/foreground-alt = #CACACA/g' $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e "s/primary = #.*/primary = $AC/g" $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e 's/red = #.*/red = #EF5350/g' $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e 's/yellow = #.*/yellow = #FFEE58/g' $HOME/.config/polybar/$polybar_STYLE/colors.ini
	
	# rofi
	tee $HOME/.config/rofi/$ROFI_STYLE/colors.rasi <<- EOF > /dev/null
	/* colors */

	* {
	  al:   #00000000;
	  bg:   #272727FF;
	  bga:  #383838FF;
	  fga:  #CACACAFF;
	  fg:   #CACACAFF;
	  ac:   ${AC}FF;
	}
	EOF
	
	polybar-msg cmd restart
	}
elif [ "$polybar_STYLE" = "hack/original" ] || [ "$polybar_STYLE" = "hack/large" ] || [ "$polybar_STYLE" = "hack/more" ]
then
	change_color() {
	# polybar
	sed -i -e 's/background = #.*/background = #141C21/g' $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e 's/foreground = #.*/foreground = #FFFFFF/g' $HOME/.config/polybar/$polybar_STYLE/colors.ini
	sed -i -e "s/primary = #.*/primary = $AC/g" $HOME/.config/polybar/$polybar_STYLE/colors.ini
	
	# rofi
	tee $HOME/.config/rofi/$ROFI_STYLE/colors.rasi <<- EOF > /dev/null
	/* colors */

	* {
	  al:    #00000000;
	  bg:    #141C21FF;
	  ac:    ${AC}FF;
	  se:    ${AC}26;
	  fg:    #FFFFFFFF;
	}
	EOF
	
	polybar-msg cmd restart
	}
else
	echo "something wrong"
fi

if  [ "$1" = "--amber" ];then
	MF="#1F1F1F"
	AC="#ffb300"
	FG="#141C21"
	SH1="#FF6F00"	SH2="#FF8F00"	SH3="#FFA000"	SH4="#FFB300"
	SH5="#FFC107"	SH6="#FFCA28"	SH7="#FFD54F"	SH8="#FFE082"
	change_color
elif  [ "$1" = "--blue" ];then
	MF="#FFFFFF"
	AC="#1e88e5"
	FG="#F5F5F5"
	SH1="#0D47A1"	SH2="#1565C0"	SH3="#1976D2"	SH4="#1E88E5"
	SH5="#2196F3"	SH6="#42A5F5"	SH7="#64B5F6"	SH8="#90CAF9"
	change_color
elif  [ "$1" = "--blue-gray" ];then
	MF="#FFFFFF"
	AC="#546e7a"
	FG="#F5F5F5"
	SH1="#263238"	SH2="#37474F"	SH3="#455A64"	SH4="#546E7A"
	SH5="#607D8B"	SH6="#78909C"	SH7="#90A4AE"	SH8="#B0BEC5"
	change_color
elif  [ "$1" = "--brown" ];then
	MF="#FFFFFF"
	AC="#6d4c41"
	FG="#F5F5F5"
	SH1="#3E2723"	SH2="#4E342E"	SH3="#5D4037"	SH4="#6D4C41"
	SH5="#795548"	SH6="#8D6E63"	SH7="#A1887F"	SH8="#BCAAA4"
	change_color
elif  [ "$1" = "--cyan" ];then
	MF="#1F1F1F"
	AC="#00acc1"
	FG="#141C21"
	SH1="#006064"	SH2="#00838F"	SH3="#0097A7"	SH4="#00ACC1"
	SH5="#00BCD4"	SH6="#26C6DA"	SH7="#4DD0E1"	SH8="#80DEEA"
	change_color
elif  [ "$1" = "--deep-orange" ];then
	MF="#FFFFFF"
	AC="#f4511e"
	FG="#F5F5F5"
	SH1="#BF360C"	SH2="#D84315"	SH3="#E64A19"	SH4="#F4511E"
	SH5="#FF5722"	SH6="#FF7043"	SH7="#FF8A65"	SH8="#FFAB91"
	change_color
elif  [ "$1" = "--deep-purple" ];then
	MF="#FFFFFF"
	AC="#5e35b1"
	FG="#F5F5F5"
	SH1="#311B92"	SH2="#4527A0"	SH3="#512DA8"	SH4="#5E35B1"
	SH5="#673AB7"	SH6="#7E57C2"	SH7="#9575CD"	SH8="#B39DDB"
	change_color
elif  [ "$1" = "--green" ];then
	MF="#FFFFFF"
	AC="#43a047"
	FG="#F5F5F5"
	SH1="#1B5E20"	SH2="#2E7D32"	SH3="#388E3C"	SH4="#43A047"
	SH5="#4CAF50"	SH6="#66BB6A"	SH7="#81C784"	SH8="#A5D6A7"
	change_color
elif  [ "$1" = "--gray" ];then
	MF="#FFFFFF"
	AC="#757575"
	FG="#141C21"
	SH1="#212121"	SH2="#424242"	SH3="#616161"	SH4="#757575"
	SH5="#9E9E9E"	SH6="#BDBDBD"	SH7="#D4D4D4"	SH8="#EEEEEE"
	change_color
elif  [ "$1" = "--indigo" ];then
	MF="#FFFFFF"
	AC="#3949ab"
	FG="#F5F5F5"
	SH1="#1A237E"	SH2="#283593"	SH3="#303F9F"	SH4="#3949AB"
	SH5="#3F51B5"	SH6="#5C6BC0"	SH7="#7986CB"	SH8="#9FA8DA"
	change_color
elif  [ "$1" = "--light-blue" ];then
	MF="#1F1F1F"
	AC="#039be5"
	FG="#141C21"
	SH1="#01579B"	SH2="#0277BD"	SH3="#0288D1"	SH4="#039BE5"
	SH5="#03A9F4"	SH6="#29B6F6"	SH7="#4FC3F7"	SH8="#81D4FA"
	change_color
elif  [ "$1" = "--light-green" ];then
	MF="#1F1F1F"
	AC="#7cb342"
	FG="#141C21"
	SH1="#33691E"	SH2="#558B2F"	SH3="#689F38"	SH4="#7CB342"
	SH5="#8BC34A"	SH6="#9CCC65"	SH7="#AED581"	SH8="#C5E1A5"
	change_color
elif  [ "$1" = "--lime" ];then
	MF="#1F1F1F"
	AC="#c0ca33"
	FG="#141C21"
	SH1="#827717"	SH2="#9E9D24"	SH3="#AFB42B"	SH4="#C0CA33"
	SH5="#CDDC39"	SH6="#D4E157"	SH7="#DCE775"	SH8="#E6EE9C"
	change_color
elif  [ "$1" = "--orange" ];then
	MF="#1F1F1F"
	AC="#fb8c00"
	FG="#141C21"
	SH1="#E65100"	SH2="#EF6C00"	SH3="#F57C00"	SH4="#FB8C00"
	SH5="#FF9800"	SH6="#FFA726"	SH7="#FFB74D"	SH8="#FFCC80"
	change_color
elif  [ "$1" = "--pink" ];then
	MF="#FFFFFF"
	AC="#d81b60"
	FG="#F5F5F5"
	SH1="#880E4F"	SH2="#AD1457"	SH3="#C2185B"	SH4="#D81B60"
	SH5="#E91E63"	SH6="#EC407A"	SH7="#F06292"	SH8="#F48FB1"
	change_color
elif  [ "$1" = "--purple" ];then
	MF="#FFFFFF"
	AC="#8e24aa"
	FG="#F5F5F5"
	SH1="#4A148C"	SH2="#6A1B9A"	SH3="#7B1FA2"	SH4="#8E24AA"
	SH5="#9C27B0"	SH6="#AB47BC"	SH7="#BA68C8"	SH8="#CE93D8"
	change_color
elif  [ "$1" = "--red" ];then
	MF="#FFFFFF"
	AC="#e53935"
	FG="#F5F5F5"
	SH1="#B71C1C"	SH2="#C62828"	SH3="#D32F2F"	SH4="#E53935"
	SH5="#EE413D"	SH6="#EF5350"	SH7="#E57373"	SH8="#EF9A9A"
	change_color
elif  [ "$1" = "--teal" ];then
	MF="#FFFFFF"
	AC="#00897b"
	FG="#F5F5F5"
	SH1="#004D40"	SH2="#00695C"	SH3="#00796B"	SH4="#00897B"
	SH5="#009688"	SH6="#26A69A"	SH7="#4DB6AC"	SH8="#80CBC4"
	change_color
elif  [ "$1" = "--yellow" ];then
	MF="#1F1F1F"
	AC="#fdd835"
	FG="#141C21"
	SH1="#F57F17"	SH2="#F9A825"	SH3="#FBC02D"	SH4="#FDD835"
	SH5="#FFEB3B"	SH6="#FFEE58"	SH7="#FFF176"	SH8="#FFF59D"
	change_color
else
	cat <<- _EOF_
	No option specified, Available options:
	--amber	--blue		--blue-gray	--brown
	--cyan	--deep-orange	--deep-purple	--green
	--gray	--indigo	--light-blue	--light-green
	--lime	--orange	--pink		--purple
	--red	--teal		--yellow
	_EOF_
fi
