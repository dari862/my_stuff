
get_memory() {
	# Used memory is calculated using the following "formula":
        # mem_full - ((inactive + free + cache) * page_size / 1024)
    mem_full=$(($(sysctl -n hw.physmem) / 1024 / 1024))

            # Use 'set --' to store the output of the command in the
            # argument list. POSIX sh has no arrays but this is close enough.
            #
            # Disable the shellcheck warning for word-splitting
            # as it's safe and intended ('set -f' disables globbing).
            # shellcheck disable=2046
            {
                set -f
                set +f -- $(sysctl -n hw.pagesize \
                                      vm.stats.vm.v_inactive_count \
                                      vm.stats.vm.v_free_count \
                                      vm.stats.vm.v_cache_count)
            }

            # Calculate the amount of used memory.
            # $1: hw.pagesize
            # $2: vm.stats.vm.v_inactive_count
            # $3: vm.stats.vm.v_free_count
            # $4: vm.stats.vm.v_cache_count
            mem_used=$((mem_full - (($2 + $3 + $4) * $1 / 1024 / 1024)))

    log memory "${mem_used:-?}M / ${mem_full:-?}M" >&6
}
