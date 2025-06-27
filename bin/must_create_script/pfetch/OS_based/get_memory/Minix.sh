
get_memory() {
    # Minix includes the '/proc' filesystem though the format
            # differs from Linux. The '/proc/meminfo' file is only a
            # single line with space separated elements and elements
            # 2 and 3 contain the total and free memory numbers.
            read -r _ mem_full mem_free _ < /proc/meminfo

            mem_used=$(((mem_full - mem_free) / 1024))
            mem_full=$(( mem_full / 1024))

    log memory "${mem_used:-?}M / ${mem_full:-?}M" >&6
}
