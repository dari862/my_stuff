
get_memory() {
            mem_full=$(($(sysctl -n hw.physmem64) / 1024 / 1024))

            # NetBSD implements a lot of the Linux '/proc' filesystem,
            # this uses the same parser as the Linux memory detection.
            while IFS=':k ' read -r key val _; do
                case $key in
                    (MemFree)
                        mem_free=$((val / 1024))
                        break
                    ;;
                esac
            done < /proc/meminfo

            mem_used=$((mem_full - mem_free))
    log memory "${mem_used:-?}M / ${mem_full:-?}M" >&6
}
