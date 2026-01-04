
get_os() {
			# Haiku uses 'uname -v' for version information
            # instead of 'uname -r' which only prints '1'.
            distro="$os $(uname -v)"
            
            log os "$distro" >&6
            return
}
