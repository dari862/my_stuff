#!/bin/sh
# need superuser : var (_SUPERUSER)
# need superuser : sourced by create_DB.sh
. "${__distro_path_root}/lib/common/pipemenu"
. "${__distro_path_root}/lib/common/DB"
. "${__distro_path_root}/lib/common/my_installer_and_DB_dir"

mkdir -p "${pipemenu_output_dir}"

create_exec_pipemenu(){
	echo "<menu id=\"$1\" execute=\"$2\" label=\"$3\"/>"
}

{
	menuStart
	create_exec_pipemenu "GuiAppsPipemenu" "gui-apps-pipemenu" "$__distro_title GUI Apps"
	create_exec_pipemenu "InstallFavouritePackages" "sh -c 'cat ${my_installer_pipemenu_X11_file}'" "Install Favourite Packages"
	create_exec_pipemenu "InstallGamingPackages" "sh -c 'cat ${gaming_pipemenu_file}'" "Install Gaming Packages"
	create_exec_pipemenu "DeployFavouriteContainers" "sh -c 'cat ${containers_deployer_pipemenu_file}'" "Deploy Distrobox and Containers"
	create_exec_pipemenu "RunDistroTweeks" "sh -c 'cat ${my_tweeks_pipemenu_file}'" "Run Distro Tweeks"
	create_exec_pipemenu "InstallFullEnvironments" "sh -c 'cat ${full_environment_pipemenu_file}'" "Install Full Environments"
	create_exec_pipemenu "PanelPipeMenu" "change-panel-pipemenu" "Change Panel"
	menuSubmenu "preferences-openbox" "Openbox"
    	create_exec_pipemenu "ob-menu-pipemenu" "ob-menu-pipemenu" "Menu Style"
    	menuItem "Edit rc.xml" "my-text-editor &openboxconfig;/rc.xml"
    	menuSeparator
    	menuItem "WM Preferences" "obconf --config-file &openboxconfig;/rc.xml"
    	menuSeparator
    	menuItem "Reconfigure" "reconfigure-openbox"
    	menuItem "Restart" "restart-openbox"
	menuSubmenuEnd
	create_exec_pipemenu "Compositor" "compositor-pipemenu" "Compositor"
	create_exec_pipemenu "XrandrPipeMenu" "randr-pipemenu" "Display / Monitor"
	create_exec_pipemenu "ScalePipeMenu" "scale-randr-pipemenu" "Display / Monitor Scaling"
	create_exec_pipemenu "Conky" "conky-pipemenu" "Conky"
	create_exec_pipemenu "panel_settings" "panel-settings-pipemenu" "Taskbar"
	menuItem "Appearance" "appearance_settings_"
	menuItem "Reload GTK" "${__distro_path_root}/bin/X11/WM/reload_gtk23"
	menuItem "Font configuration" "my-text-editor ~/.config/fontconfig/fonts.conf"
	menuItem "Wallpaper" "popup_terminal pickbg"
	menuItem "Notifications" "notification-d-session edit"
	menuItem "Power Management" "power_manager_settings"
	menuSubmenu "preferences-rofi" "rofi"
    	menuItem "Edit Config File" "rofi_editer"
    	menuSeparator "Help"
    	menuItem "man page" "popup_terminal --man rofi"
	menuSubmenuEnd
	menuSubmenu "preferences-display" "display"
    	menuItem "ARandR Screen Layout Editor" "arandr"
    	menuSeparator "Help"
    	menuItem "man xrandr" "popup_terminal --man xrandr"
	menuSubmenuEnd
	menuEnd
} | $_SUPERUSER tee "${bl_preferences_pipemenu_file}" >/dev/null 2>&1

{
	menuStart
	create_exec_pipemenu "GuiAppsPipemenu" "gui-apps-pipemenu" "$__distro_title GUI Apps"
	create_exec_pipemenu "InstallFavouritePackages" "sh -c 'cat ${my_installer_pipemenu_X11_file}'" "Install Favourite Packages"
	create_exec_pipemenu "InstallGamingPackages" "sh -c 'cat ${gaming_pipemenu_file}'" "Install Gaming Packages"
	create_exec_pipemenu "DeployFavouriteContainers" "sh -c 'cat ${containers_deployer_pipemenu_file}'" "Deploy Distrobox and Containers"
	create_exec_pipemenu "RunDistroTweeks" "sh -c 'cat ${my_tweeks_pipemenu_file}'" "Run Distro Tweeks"
	create_exec_pipemenu "InstallFullEnvironments" "sh -c 'cat ${full_environment_pipemenu_file}'" "Install Full Environments"
	
	menuSubmenu "obconfig" "Openbox"
    	create_exec_pipemenu "ob-menu-pipemenu" "ob-menu-pipemenu" "Menu Style"
    	menuItem "Settings" "obconf"
    	menuSeparator
    	menuItem "Edit menu.xml" "my-text-editor &openboxconfig;/menu.xml"
    	menuItem "Edit rc.xml" "my-text-editor &openboxconfig;/rc.xml"
    	menuItem "Edit autostart" "my-text-editor &openboxconfig;/autostart"
    	menuSeparator
    	menuItem "Reconfigure" "reconfigure-openbox"
    	menuItem "Restart" "restart-openbox"
	menuSubmenuEnd
	
	create_exec_pipemenu "CompositingPipeMenu" "compositor-pipemenu" "Compositor"
	create_exec_pipemenu "XrandrPipeMenu" "randr-pipemenu" "Display / Monitor"
	create_exec_pipemenu "ScalePipeMenu" "scale-randr-pipemenu" "Display / Monitor Scaling"
	menuSeparator
	create_exec_pipemenu "StylePipeMenu" "change-style-pipemenu" "Change Style"
	create_exec_pipemenu "PanelPipeMenu" "change-panel-pipemenu" "Change Panel"
	create_exec_pipemenu "FontPipeMenu" "change-fonts-pipemenu" "Change Font"
	create_exec_pipemenu "SchemePipeMenu" "change-scheme-pipemenu" "Terminal Color Scheme"
	create_exec_pipemenu "panel_settings" "panel-settings-pipemenu" "Taskbar"
	menuSeparator
	menuItem "Change Wallpaper" "popup_terminal pickbg"
	menuItem "Appearance Settings" "appearance_settings_"
	menuSeparator
	menuItem "Power Settings" "power_manager_settings"
	menuItem "Audio Settings" "volume_controller"
	menuItem "Settings Manager" "${__distro_path_root}/bin/not_add_2_path/settings_manager_"
	create_exec_pipemenu "Printers" "printing-pipemenu" "Printers"
	menuEnd
} | $_SUPERUSER tee "${ac_preferences_pipemenu_file}" >/dev/null 2>&1

{
	menuStart
	create_exec_pipemenu "GuiAppsPipemenu" "gui-apps-pipemenu" "$__distro_title GUI Apps"
	menuSeparator "Install Packages and Distro Tweeks"
	create_exec_pipemenu "InstallFavouritePackages" "sh -c 'cat ${my_installer_pipemenu_X11_file}'" "Install Favourite Packages"
	create_exec_pipemenu "InstallGamingPackages" "sh -c 'cat ${gaming_pipemenu_file}'" "Install Gaming Packages"
	create_exec_pipemenu "DeployFavouriteContainers" "sh -c 'cat ${containers_deployer_pipemenu_file}'" "Deploy Distrobox and Containers"
	create_exec_pipemenu "RunDistroTweeks" "sh -c 'cat ${my_tweeks_pipemenu_file}'" "Run Distro Tweeks"
	create_exec_pipemenu "InstallFullEnvironments" "sh -c 'cat ${full_environment_pipemenu_file}'" "Install Full Environments"
	menuSeparator "GRAPHICAL PREFERENCES"
	create_exec_pipemenu "XrandrPipeMenu" "randr-pipemenu" "Display / Monitor"
	create_exec_pipemenu "ScalePipeMenu" "scale-randr-pipemenu" "Display / Monitor Scaling"
	create_exec_pipemenu "StylePipeMenu" "change-style-pipemenu" "Change Style"
	create_exec_pipemenu "PanelPipeMenu" "change-panel-pipemenu" "Change Panel"
	menuSubmenu "obConfig" "Desktop"
    	menuItem "Openbox Preferences" "obconf"
    	menuItem "Edit Openbox config file rc.xml" "my-text-editor &openboxconfig;/rc.xml"
    	menuItem "How to configure Openbox?" "my-www-browser \"http://openbox.org/wiki/Help:Contents\" \"https://wiki.archlinux.org/index.php/openbox\""
    	menuSeparator
    	menuItem "Reload Openbox configuration" "reconfigure-openbox"
    	menuItem "Restart Openbox" "restart-openbox"
	menuSubmenuEnd
	
	menuSubmenu "obmenu" "Menu"
    	create_exec_pipemenu "ob-menu-pipemenu" "ob-menu-pipemenu" "Menu Style"
    	menuItem "Edit menu.xml" "my-text-editor &openboxconfig;/menu.xml"
    	menuItem "Hide/show icons in menu" "bash -c 'if grep -q icon_hide=\" &openboxconfig;/menu.xml;then sed -i \"s/icon_hide=\"/icon=\"/g\" &openboxconfig;/menu.xml; else sed -i \"s/icon=\"/icon_hide=\"/g\" &openboxconfig;/menu.xml; fi'"
    	menuItem "How to configure menu.xml?" "my-www-browser \"http://openbox.org/wiki/Help:Menus\" \"https://wiki.archlinux.org/index.php/openbox#Menus\""
    	menuSeparator
    	menuItem "Reload Menu" "reconfigure-openbox"
	menuSubmenuEnd
	
	create_exec_pipemenu "CompositingPipeMenu" "compositor-pipemenu" "Compositor"
	create_exec_pipemenu "panel_settings" "panel-settings-pipemenu" "Taskbar"
	create_exec_pipemenu "Conky" "conky-pipemenu" "Conky"
	
	menuSubmenu "autostart" "Autostarted programs"
    	menuItem "Edit Openbox Autostart" "my-text-editor &openboxconfig;/autostart"
    	menuItem "Show XDG autostarted programs" "${__distro_path_root}/bin/not_add_2_path/sysinfo_script_ --autostart"
	menuSubmenuEnd
	
	menuSubmenu "shortcuts" "Keyboard and mouse shortcuts"
    	menuItem "Edit Openbox rc.xml" "my-text-editor &openboxconfig;/rc.xml"
    	menuItem "How to configure Openbox shortcuts?" "my-www-browser \"http://openbox.org/wiki/Help:Bindings\""
    	menuSeparator
    	menuItem "Reload shortcuts" "reconfigure-openbox"
	menuSubmenuEnd
	
	menuItem "GTK Appearance" "appearance_settings_"
	menuItem "Font Configuration" "my-text-editor ~/.config/fontconfig/fonts.conf"
	menuItem "Wallpaper" "popup_terminal pickbg"
	menuItem "Notifications" "notification-d-session edit"
	menuItem "Display" "arandr"
	
	menuSeparator "SYSTEM PREFERENCES"
	menuItem "GUI Package Manager" "${__distro_path_root}/bin/not_add_2_path/gui_packagemanager"
	menuItem "Check Pending Updates" "${__distro_path_root}/bin/WM/update-notification -n"
	menuItem "Alternatives" "edit-alternatives"
	menuItem "Power Management" "power_manager_settings"
	menuItem "Network Configuration" "nm-connection-editor"
	menuItem "Removable Drives and Media" "thunar-volman-settings"
	menuItem "GParted Partition Manager" "gparted"
	create_exec_pipemenu "Printers" "printing-pipemenu" "Printers"
	menuEnd
} | $_SUPERUSER tee "${my_preferences_pipemenu_file}" >/dev/null 2>&1

