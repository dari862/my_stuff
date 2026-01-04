
get_os() {
            # Parse the SystemVersion.plist file to grab the macOS
            # version. The file is in the following format:
            #
            # <key>ProductVersion</key>
            # <string>10.14.6</string>
            #
            # 'IFS' is set to '<>' to enable splitting between the
            # keys and a second 'read' is used to operate on the
            # next line directly after a match.
            #
            # '_' is used to nullify a field. '_ _ line _' basically
            # says "populate $line with the third field's contents".
            while IFS='<>' read -r _ _ line _; do
                case $line in
                    # Match 'ProductVersion' and read the next line
                    # directly as it contains the key's value.
                    ProductVersion)
                        IFS='<>' read -r _ _ mac_version _
                        continue
                    ;;

                    ProductName)
                        IFS='<>' read -r _ _ mac_product _
                        continue
                    ;;
                esac
            done < /System/Library/CoreServices/SystemVersion.plist

            # Use the ProductVersion to determine which macOS/OS X codename
            # the system has. As far as I'm aware there's no "dynamic" way
            # of grabbing this information.
            case $mac_version in
                (10.4*)  distro='Mac OS X Tiger' ;;
                (10.5*)  distro='Mac OS X Leopard' ;;
                (10.6*)  distro='Mac OS X Snow Leopard' ;;
                (10.7*)  distro='Mac OS X Lion' ;;
                (10.8*)  distro='OS X Mountain Lion' ;;
                (10.9*)  distro='OS X Mavericks' ;;
                (10.10*) distro='OS X Yosemite' ;;
                (10.11*) distro='OS X El Capitan' ;;
                (10.12*) distro='macOS Sierra' ;;
                (10.13*) distro='macOS High Sierra' ;;
                (10.14*) distro='macOS Mojave' ;;
                (10.15*) distro='macOS Catalina' ;;
                (11*)    distro='macOS Big Sur' ;;
                (12*)    distro='macOS Monterey' ;;
                (*)      distro='macOS' ;;
            esac

            # Use the ProductName to determine if we're running in iOS.
            case $mac_product in
                (iP*) distro='iOS' ;;
            esac

            distro="$distro $mac_version"
            
            log os "$distro" >&6
            return
}
