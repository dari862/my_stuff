
get_memory() {
	# Used memory is calculated using the following "formula":
        # MemUsed = MemTotal + Shmem - MemFree - Buffers - Cached - SReclaimable
        # Source: https://github.com/KittyKatt/screenFetch/issues/386
        
        
       # Parse the '/proc/meminfo' file splitting on ':' and 'k'.
            # The format of the file is 'key:   000kB' and an additional
            # split is used on 'k' to filter out 'kB'.
            while IFS=':k '  read -r key val _; do
                case $key in
                    (MemTotal)
                        mem_used=$((mem_used + val))
                        mem_full=$val
                    ;;

                    (Shmem)
                        mem_used=$((mem_used + val))
                    ;;

                    (MemFree | Buffers | Cached | SReclaimable)
                        mem_used=$((mem_used - val))
                    ;;

                    # If detected this will be used over the above calculation
                    # for mem_used. Available since Linux 3.14rc.
                    # See kernel commit 34e431b0ae398fc54ea69ff85ec700722c9da773
                    (MemAvailable)
                        mem_avail=$val
                    ;;
                esac
            done < /proc/meminfo

            case $mem_avail in
                (*[0-9]*)
                    mem_used=$(((mem_full - mem_avail) / 1024))
                ;;

                *)
                    mem_used=$((mem_used / 1024))
                ;;
            esac

            mem_full=$((mem_full / 1024))

    log memory "${mem_used:-?}M / ${mem_full:-?}M" >&6
}
