
get_wm_X11() {
            # xprop can be used to grab the window manager's properties
            # which contains the window manager's name under '_NET_WM_NAME'.
            #
            # The upside to using 'xprop' is that you don't need to hardcode
            # a list of known window manager names. The downside is that
            # not all window managers conform to setting the '_NET_WM_NAME'
            # atom..
            #
            # List of window managers which fail to set the name atom:
            # catwm, fvwm, dwm, 2bwm, monster, wmaker and sowm [mine! ;)].
            #
            # The final downside to this approach is that it does _not_
            # support Wayland environments. The only solution which supports
            # Wayland is the 'ps' parsing mentioned below.
            #
            # A more naive implementation is to parse the last line of
            # '~/.xinitrc' to extract the second white-space separated
            # element.
            #
            # The issue with an approach like this is that this line data
            # does not always equate to the name of the window manager and
            # could in theory be _anything_.
            #
            # This also fails when the user launches xorg through a display
            # manager or other means.
            #
            #
            # Another naive solution is to parse 'ps' with a hardcoded list
            # of window managers to detect the current window manager (based
            # on what is running).
            #
            # The issue with this approach is the need to hardcode and
            # maintain a list of known window managers.
            #
            # Another issue is that process names do not always equate to
            # the name of the window manager. False-positives can happen too.
            #
            # This is the only solution which supports Wayland based
            # environments sadly. It'd be nice if some kind of standard were
            # established to identify Wayland environments.
            #
            # pfetch's goal is to remain _simple_, if you'd like a "full"
            # implementation of window manager detection use 'neofetch'.
            #
            # Neofetch use a combination of 'xprop' and 'ps' parsing to
            # support all window managers (including non-conforming and
            # Wayland) though it's a lot more complicated!
		while read -r ps_line; do
                        case $ps_line in
                            (*catwm*)     wm=catwm ;;
                            (*fvwm*)      wm=fvwm ;;
                            (*dwm*)       wm=dwm ;;
                            (*2bwm*)      wm=2bwm ;;
                            (*monsterwm*) wm=monsterwm ;;
                            (*wmaker*)    wm='Window Maker' ;;
                            (*sowm*)      wm=sowm ;;
							(*penrose*)   wm=penrose ;;
                        esac
                    done <<-EOF
                        $(ps x)
					EOF
}
