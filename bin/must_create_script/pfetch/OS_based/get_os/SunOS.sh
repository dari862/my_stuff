
get_os() {
    IFS='(' read -r distro _ < /etc/release
            
            log os "$distro" >&6
            return
}
