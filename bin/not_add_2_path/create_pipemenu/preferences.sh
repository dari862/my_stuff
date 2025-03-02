#!/bin/sh
. "/usr/share/my_stuff/lib/common/pipemenu"

preferences_pipemenu_dir="/usr/share/my_stuff/system_files/preferences_pipemenu"
my-superuser mkdir -p "${preferences_pipemenu_dir}"

create_exec_pipemenu(){
	echo "<menu id=\"$1\" execute=\"$2\" label=\"$3\"/>"
}

{
	menuStart
	create_exec_pipemenu "my_stuffGuiAppsPipemenu" "gui-apps-pipemenu --openboxmenu" "My Stuff GUI Apps"
	create_exec_pipemenu "InstallFavouritePackages" "my-install-pipemenu --openboxmenu" "Install Favourite Packages"
	create_exec_pipemenu "InstallGamingPackages" "gaming-pipemenu --openboxmenu" "Install Gaming Packages"
	create_exec_pipemenu "DeployFavouriteContainers" "containers-deployer-pipemenu --openboxmenu" "Deploy Distrobox and Containers"
	create_exec_pipemenu "RunDebianTweeks" "my-tweeks-pipemenu --openboxmenu" "Run Debian Tweeks"
	create_exec_pipemenu "InstallFullEnvironments" "full_environment-pipemenu --openboxmenu" "Install Full Environments"
	create_exec_pipemenu "PanelPipeMenu" "change-panel-pipemenu" "Change Panel"
	menuSubmenu "preferences-openbox" "Openbox"
    	create_exec_pipemenu "ac-ob-menu-pipemenu" "ac-ob-menu-pipemenu" "Menu Style"
    	menuItem "Edit rc.xml" "my-text-editor &openboxconfig;/rc.xml"
    	menuSeparator
    	menuItem "WM Preferences" "obconf --config-file &openboxconfig;/rc.xml"
    	menuSeparator
    	menuItem "Reconfigure" "openbox --reconfigure"
    	menuItem "Restart" "restart-openbox"
	menuSubmenuEnd
	create_exec_pipemenu "Compositor" "ac-compositor-pipemenu" "Compositor"
	create_exec_pipemenu "Conky" "conky-pipemenu" "Conky"
	create_exec_pipemenu "panel_settings" "ac-panel-settings" "Taskbar"
	menuItem "Appearance" "appearance_settings_"
	menuItem "Reload GTK" "reload_gtk23"
	menuItem "Font configuration" "my-text-editor ~/.config/fontconfig/fonts.conf"
	menuItem "Wallpaper" "pickbg"
	menuItem "Notifications" "notifications_config"
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
} | my-superuser tee "${preferences_pipemenu_dir}/bl" >/dev/null 2>&1

{
	menuStart
	create_exec_pipemenu "my_stuffGuiAppsPipemenu" "gui-apps-pipemenu --openboxmenu" "My Stuff GUI Apps"
	create_exec_pipemenu "InstallFavouritePackages" "my-install-pipemenu --openboxmenu" "Install Favourite Packages"
	create_exec_pipemenu "InstallGamingPackages" "gaming-pipemenu --openboxmenu" "Install Gaming Packages"
	create_exec_pipemenu "DeployFavouriteContainers" "containers-deployer-pipemenu --openboxmenu" "Deploy Distrobox and Containers"
	create_exec_pipemenu "RunDebianTweeks" "my-tweeks-pipemenu --openboxmenu" "Run Debian Tweeks"
	create_exec_pipemenu "InstallFullEnvironments" "full_environment-pipemenu --openboxmenu" "Install Full Environments"
	
	menuSubmenu "obconfig" "Openbox"
    	create_exec_pipemenu "ac-ob-menu-pipemenu" "ac-ob-menu-pipemenu" "Menu Style"
    	menuItem "Settings" "obconf"
    	menuSeparator
    	menuItem "Edit menu.xml" "my-text-editor &openboxconfig;/menu.xml"
    	menuItem "Edit rc.xml" "my-text-editor &openboxconfig;/rc.xml"
    	menuItem "Edit autostart" "my-text-editor &openboxconfig;/autostart"
    	menuSeparator
    	menuItem "Reconfigure" "openbox --reconfigure"
    	menuItem "Restart" "restart-openbox"
	menuSubmenuEnd
	
	create_exec_pipemenu "CompositingPipeMenu" "ac-compositor-pipemenu" "Compositor"
	create_exec_pipemenu "XrandrPipeMenu" "ac-randr" "Display / Monitor"
	create_exec_pipemenu "ScalePipeMenu" "ac-scale-randr" "Display / Monitor Scaling"
	menuSeparator
	create_exec_pipemenu "StylePipeMenu" "change-style-pipemenu" "Change Style"
	create_exec_pipemenu "PanelPipeMenu" "change-panel-pipemenu" "Change Panel"
	create_exec_pipemenu "FontPipeMenu" "change-fonts-pipemenu" "Change Font"
	create_exec_pipemenu "SchemePipeMenu" "change-scheme-pipemenu" "Terminal Color Scheme"
	create_exec_pipemenu "panel_settings" "ac-panel-settings" "Taskbar"
	menuSeparator
	menuItem "Change Wallpaper" "pickbg"
	menuItem "Appearance Settings" "appearance_settings_"
	menuSeparator
	menuItem "Power Settings" "power_manager_settings"
	menuItem "Audio Settings" "distro_scripts --volume-controller"
	menuItem "Settings Manager" "settings_manager_"
	create_exec_pipemenu "Printers" "printing-pipemenu" "Printers"
	menuEnd
} | my-superuser tee "${preferences_pipemenu_dir}/ac" >/dev/null 2>&1

{
	menuStart
	create_exec_pipemenu "my_stuffGuiAppsPipemenu" "gui-apps-pipemenu --openboxmenu" "My Stuff GUI Apps"
	menuSeparator "Install Packages and Debian Tweeks"
	create_exec_pipemenu "InstallFavouritePackages" "my-install-pipemenu --openboxmenu" "Install Favourite Packages"
	create_exec_pipemenu "InstallGamingPackages" "gaming-pipemenu --openboxmenu" "Install Gaming Packages"
	create_exec_pipemenu "DeployFavouriteContainers" "containers-deployer-pipemenu --openboxmenu" "Deploy Distrobox and Containers"
	create_exec_pipemenu "RunDebianTweeks" "my-tweeks-pipemenu --openboxmenu" "Run Debian Tweeks"
	create_exec_pipemenu "InstallFullEnvironments" "full_environment-pipemenu --openboxmenu" "Install Full Environments"
	menuSeparator "GRAPHICAL PREFERENCES"
	create_exec_pipemenu "XrandrPipeMenu" "ac-randr" "Display / Monitor"
	create_exec_pipemenu "ScalePipeMenu" "ac-scale-randr" "Display / Monitor Scaling"
	create_exec_pipemenu "StylePipeMenu" "change-style-pipemenu" "Change Style"
	create_exec_pipemenu "PanelPipeMenu" "change-panel-pipemenu" "Change Panel"
	menuSubmenu "obConfig" "Desktop"
    	menuItem "Openbox Preferences" "obconf"
    	menuItem "Edit Openbox config file rc.xml" "my-text-editor &openboxconfig;/rc.xml"
    	menuItem "How to configure Openbox?" "my-www-browser \"http://openbox.org/wiki/Help:Contents\" \"https://wiki.archlinux.org/index.php/openbox\""
    	menuSeparator
    	menuItem "Reload Openbox configuration" "openbox --reconfigure"
    	menuItem "Restart Openbox" "restart-openbox"
	menuSubmenuEnd
	
	menuSubmenu "obmenu" "Menu"
    	create_exec_pipemenu "ac-ob-menu-pipemenu" "ac-ob-menu-pipemenu" "Menu Style"
    	menuItem "Edit menu.xml" "my-text-editor &openboxconfig;/menu.xml"
    	menuItem "Hide/show icons in menu" "bash -c 'if grep -q icon_hide=\" &openboxconfig;/menu.xml;then sed -i \"s/icon_hide=\"/icon=\"/g\" &openboxconfig;/menu.xml; else sed -i \"s/icon=\"/icon_hide=\"/g\" &openboxconfig;/menu.xml; fi'"
    	menuItem "How to configure menu.xml?" "my-www-browser \"http://openbox.org/wiki/Help:Menus\" \"https://wiki.archlinux.org/index.php/openbox#Menus\""
    	menuSeparator
    	menuItem "Reload Menu" "openbox --reconfigure"
	menuSubmenuEnd
	
	create_exec_pipemenu "CompositingPipeMenu" "ac-compositor-pipemenu" "Compositor"
	create_exec_pipemenu "panel_settings" "ac-panel-settings" "Taskbar"
	create_exec_pipemenu "Conky" "conky-pipemenu" "Conky"
	
	menuSubmenu "autostart" "Autostarted programs"
    	menuItem "Edit Openbox Autostart" "my-text-editor &openboxconfig;/autostart"
    	menuItem "Show XDG autostarted programs" "sysinfo_script_ --autostart"
	menuSubmenuEnd
	
	menuSubmenu "shortcuts" "Keyboard and mouse shortcuts"
    	menuItem "Edit Openbox rc.xml" "my-text-editor &openboxconfig;/rc.xml"
    	menuItem "How to configure Openbox shortcuts?" "my-www-browser \"http://openbox.org/wiki/Help:Bindings\""
    	menuSeparator
    	menuItem "Reload shortcuts" "openbox --reconfigure"
	menuSubmenuEnd
	
	menuItem "GTK Appearance" "appearance_settings_"
	menuItem "Font Configuration" "my-text-editor ~/.config/fontconfig/fonts.conf"
	menuItem "Wallpaper" "pickbg"
	menuItem "Notifications" "notifications_config"
	menuItem "Display" "arandr"
	
	menuSeparator "SYSTEM PREFERENCES"
	menuItem "Synaptic Package Manager" "apps_as_root synaptic"
	menuItem "Check Pending Updates" "update-notification -n"
	menuItem "Alternatives" "galternatives"
	menuItem "Power Management" "power_manager_settings"
	menuItem "Network Configuration" "nm-connection-editor"
	menuItem "Removable Drives and Media" "thunar-volman-settings"
	menuItem "GParted Partition Manager" "gparted"
	create_exec_pipemenu "Printers" "printing-pipemenu" "Printers"
	menuEnd
} | my-superuser tee "${preferences_pipemenu_dir}/my" >/dev/null 2>&1

