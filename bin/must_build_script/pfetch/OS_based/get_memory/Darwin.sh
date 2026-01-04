
get_memory() {
	# Used memory is calculated using the following "formula":
        # (wired + active + occupied) * 4 / 1024
			mem_full=$(($(sysctl -n hw.memsize) / 1024 / 1024))

            # Parse the 'vmstat' file splitting on ':' and '.'.
            # The format of the file is 'key:   000.' and an additional
            # split is used on '.' to filter it out.
            while IFS=:. read -r key val; do
                case $key in
                    (*' wired'*|*' active'*|*' occupied'*)
                        mem_used=$((mem_used + ${val:-0}))
                    ;;
                esac

            # Using '<<-EOF' is the only way to loop over a command's
            # output without the use of a pipe ('|').
            # This ensures that any variables defined in the while loop
            # are still accessible in the script.
            done <<-EOF
                $(vm_stat)
			EOF

            mem_used=$((mem_used * 4 / 1024))

    log memory "${mem_used:-?}M / ${mem_full:-?}M" >&6
}
