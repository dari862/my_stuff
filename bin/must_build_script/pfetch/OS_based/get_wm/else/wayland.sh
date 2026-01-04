get_wm_wayland() {
	grep_ps="$(ps -e | grep -Ei 'gnome-shell|kwin_wayland|sway|wayfire|hyprland|weston|labwc|cage|river|hikari|velox|dwl|gamescope|mirco|cagebreak')"
	case $grep_ps in
        (*gnome-shell*)   wm="GNOME (Mutter)" ;;
        (*kwin_wayland*)  wm="KDE (KWin)" ;;
        (*sway*)          wm="Sway" ;;
        (*wayfire*)       wm="Wayfire" ;;
        (*hyprland*)      wm="Hyprland" ;;
        (*weston*)        wm="Weston" ;;
        (*labwc*)         wm="LabWC" ;;
        (*cage*)          wm="Cage" ;;
        (*river*)         wm="River" ;;
        (*hikari*)        wm="Hikari" ;;
        (*velox*)         wm="Velox" ;;
        (*dwl*)           wm="dwl" ;;
        (*gamescope*)     wm="Gamescope" ;;
        (*mirco*)         wm="Mirco" ;;
        (*cagebreak*)     wm="Cagebreak" ;;
        (*)               wm="Unknown Wayland Compositor" ;;
	esac
}
