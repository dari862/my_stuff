
get_pkgs() {
    # This works by first checking for which package managers are
    # installed and finally by printing each package manager's
    # package list with each package one per line.
    #
    # The output from this is then piped to 'wc -l' to count each
    # line, giving us the total package count of whatever package
    # managers are installed.
    packages=$(
        case $os in
            (Linux*)
                printf '%s\n' /var/log/packages/*
        ;;
        esac | wc -l
    )

    # 'wc -l' can have leading and/or trailing whitespace
    # depending on the implementation, so strip them.
    # Procedure explained at https://github.com/dylanaraps/pure-sh-bible
    # (trim-leading-and-trailing-white-space-from-string)
    packages=${packages#"${packages%%[![:space:]]*}"}
    packages=${packages%"${packages##*[![:space:]]}"}

    case $packages in
        (1?*|[2-9]*)
            log pkgs "$packages" >&6
        ;;
    esac
}
