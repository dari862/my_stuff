
get_os() {
    distro="Minix $kernel"

            # Minix and DragonFly don't support the escape
            # sequences used, clear the exit trap.
            trap '' EXIT
            
            log os "$distro" >&6
            return
}
