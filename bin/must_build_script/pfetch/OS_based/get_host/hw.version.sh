
get_host() {
    host=$(sysctl -n hw.version)

    # Turn the host string into an argument list so we can iterate
    # over it and remove OEM strings and other information which
    # shouldn't be displayed.
    #
    # Disable the shellcheck warning for word-splitting
    # as it's safe and intended ('set -f' disables globbing).
    # shellcheck disable=2046,2086
    {
        set -f
        set +f -- $host
        host=
    }

    # Iterate over the host string word by word as a means of stripping
    # unwanted and OEM information from the string as a whole.
    #
    # This could have been implemented using a long 'sed' command with
    # a list of word replacements, however I want to show that something
    # like this is possible in pure sh.
    #
    # This string reconstruction is needed as some OEMs either leave the
    # identification information as "To be filled by OEM", "Default",
    # "undefined" etc and we shouldn't print this to the screen.
    for word do
        # This works by reconstructing the string by excluding words
        # found in the "blacklist" below. Only non-matches are appended
        # to the final host string.
        case $word in
           (To      | [Bb]e      | [Ff]illed | [Bb]y  | O.E.M.  | OEM  |\
            Not     | Applicable | Specified | System | Product | Name |\
            Version | Undefined  | Default   | string | INVALID | �    | os |\
            Type1ProductConfigId )
                continue
            ;;
        esac

        host="$host$word "
    done

    # '$arch' is the cached output from 'uname -m'.
    log host "${host:-$arch}" >&6
}
