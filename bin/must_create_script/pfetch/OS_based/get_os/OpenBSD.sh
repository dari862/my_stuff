
get_os() {
    # Show the OpenBSD version type (current if present).
            # kern.version=OpenBSD 6.6-current (GENERIC.MP) ...
            IFS=' =' read -r _ distro openbsd_ver _ <<-EOF
				$(sysctl kern.version)
			EOF

            distro="$distro $openbsd_ver"
            
            log os "$distro" >&6
            return
}
