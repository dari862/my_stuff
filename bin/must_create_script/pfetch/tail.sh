main() {
    case $* in
        -v)
            printf '%s 0.7.0\n' "${0##*/}"
            return 0
        ;;

        -d)
            # Below exec is not run, stderr is shown.
        ;;

        '')
            exec 2>/dev/null
        ;;

        *)
            cat <<EOF
${0##*/}     show system information
${0##*/} -d  show stderr (debug mode)
${0##*/} -v  show version information
EOF
            return 0
        ;;
    esac

    # Hide 'stdout' and selectively print to it using '>&6'.
    # This gives full control over what it displayed on the screen.
    exec 6>&1 >/dev/null

    # Store raw escape sequence character for later reuse.
    esc_c=$(printf '\033')

    # Generic color list.
    # Disable warning about unused variables.
    # shellcheck disable=2034
    for _c in c1 c2 c3 c4 c5 c6 c7 c8; do
        esc SGR "3${_c#?}" 0
        export "$_c=$e"
    done

    # Disable line wrapping and catch the EXIT signal to enable it again
    # on exit. Ideally you'd somehow query the current value and retain
    # it but I'm yet to see this irk anyone.
    esc_p DECAWM l >&6
    trap 'esc_p DECAWM h >&6' EXIT

    kernel="$(uname -r)"

    # Allow the user to specify the order and inclusion of information
    # functions through the 'PF_INFO' environment variable.
    # shellcheck disable=2086
    {
        # Disable globbing and set the positional parameters to the
        # contents of 'PF_INFO'.
        set -f
        set +f -- ${PF_INFO-ascii title os host kernel uptime pkgs memory}

        # Iterate over the info functions to determine the lengths of the
        # "info names" for output alignment. The option names and subtitles
        # match 1:1 so this is thankfully simple.
        for info do
            command -v "get_$info" >/dev/null || continue

            # This was a ternary operation but they aren't supported in
            # Minix's shell.
            [ "${#info}" -gt "${info_length:-0}" ] &&
                info_length=${#info}
        done

        # Add an additional space of length to act as a gap.
        info_length=$((info_length + 1))

        # Iterate over the above list and run any existing "get_" functions.
        for info do
            "get_$info"
        done
    }

    # Position the cursor below both the ascii art and information lines
    # according to the height of both. If the information exceeds the ascii
    # art in height, don't touch the cursor (0/unset), else move it down
    # N lines.
    #
    # This was a ternary operation but they aren't supported in Minix's shell.
    [ "${info_height:-0}" -lt "${ascii_height:-0}" ] &&
        cursor_pos=$((ascii_height - info_height))

    # Print '$cursor_pos' amount of newlines to correctly position the
    # cursor. This used to be a 'printf $(seq X X)' however 'seq' is only
    # typically available (by default) on GNU based systems!
    while [ "${i:=0}" -le "${cursor_pos:-0}" ]; do
        printf '\n'
        i=$((i + 1))
    done >&6
}

main "$@"
