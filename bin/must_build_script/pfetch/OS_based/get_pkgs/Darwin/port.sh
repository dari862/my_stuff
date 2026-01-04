
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
            (Darwin*)
                # 'port' prints a single line of output to 'stdout'
                # when no packages are installed and exits with
                # success causing a false-positive of 1 package
                # installed.
                #
                # 'port' should really exit with a non-zero code
                # in this case to allow scripts to cleanly handle
                # this behavior.
                has_package port       && {
                    pkg_list=$(port installed)

                    case "$pkg_list" in
                        ("No ports are installed.")
                            # do nothing
                        ;;

                        (*)
                            printf '%s\n' "$pkg_list"
                        ;;
                    esac
                }
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
