
get_memory() {
     IFS='{}' read -r _ memstat _ < /proc/memstat

            set -f -- "$IFS"
            IFS=,

            for pair in $memstat; do
                case $pair in
                    (*user_physical_allocated*)
                        mem_used=${pair##*:}
                    ;;

                    (*user_physical_available*)
                        mem_free=${pair##*:}
                    ;;
                esac
            done

            IFS=$1
            set +f --

            mem_used=$((mem_used * 4096 / 1024 / 1024))
            mem_free=$((mem_free * 4096 / 1024 / 1024))

            mem_full=$((mem_used + mem_free))

    log memory "${mem_used:-?}M / ${mem_full:-?}M" >&6
}
