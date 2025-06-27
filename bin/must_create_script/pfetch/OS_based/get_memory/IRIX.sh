
get_memory() {

        # Read the memory information from the 'top' command. Parse
            # and split each line until we reach the line starting with
            # "Memory".
            #
            # Example output: Memory: 160M max, 147M avail, .....
            while IFS=' :' read -r label mem_full _ mem_free _; do
                case $label in
                    (Memory)
                        mem_full=${mem_full%M}
                        mem_free=${mem_free%M}
                        break
                    ;;
                esac
            done <<-EOF
                $(top -n)
			EOF

            mem_used=$((mem_full - mem_free))

    log memory "${mem_used:-?}M / ${mem_full:-?}M" >&6
}
