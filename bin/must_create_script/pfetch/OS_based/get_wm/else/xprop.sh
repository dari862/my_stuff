
get_wm() {
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

            # Don't display window manager if X isn't running.
            [ "$DISPLAY" ] || return

            # This is a two pass call to xprop. One call to get the window
            # manager's ID and another to print its properties.

                # The output of the ID command is as follows:
                # _NET_SUPPORTING_WM_CHECK: window id # 0x400000
                #
                # To extract the ID, everything before the last space
                # is removed.
                id=$(xprop -root -notype _NET_SUPPORTING_WM_CHECK)
                id=${id##* }

                # The output of the property command is as follows:
                # _NAME 8t
                # _NET_WM_PID = 252
                # _NET_WM_NAME = "bspwm"
                # _NET_SUPPORTING_WM_CHECK: window id # 0x400000
                # WM_CLASS = "wm", "Bspwm"
                #
                # To extract the name, everything before '_NET_WM_NAME = \"'
                # is removed and everything after the next '"' is removed.
                wm=$(xprop -id "$id" -notype -len 25 -f _NET_WM_NAME 8t)

            # Handle cases of a window manager _not_ populating the
            # '_NET_WM_NAME' atom. Display nothing in this case.
            case $wm in
                (*'_NET_WM_NAME = '*)
                    wm=${wm##*_NET_WM_NAME = \"}
                    wm=${wm%%\"*}
                ;;
            esac
    log wm "$wm" >&6
}
