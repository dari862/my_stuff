
get_os() {
			# Some Linux distributions (which are based on others)
            # fail to identify as they **do not** change the upstream
            # distribution's identification packages or files.
            #
            # It is senseless to add a special case in the code for
            # each and every distribution (which _is_ technically no
            # different from what it is based on) as they're either too
            # lazy to modify upstream's identification files or they
            # don't have the know-how (or means) to ship their own
            # lsb-release package.
            #
            # This causes users to think there's a bug in system detection
            # tools like neofetch or pfetch when they technically *do*
            # function correctly.
            #
            # Exceptions are made for distributions which are independent,
            # not based on another distribution or follow different
            # standards.
            #
            # This applies only to distributions which follow the standard
            # by shipping unmodified identification files and packages
            # from their respective upstreams.
            distro=$(lsb_release -sd)

            # 'os-release' and 'lsb_release' sometimes add quotes
            # around the distribution name, strip them.
            distro=${distro##[\"\']}
            distro=${distro%%[\"\']}
