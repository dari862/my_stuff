
get_memory() {
			mem_full=$(($(sysctl -n hw.physmem) / 1024 / 1024))

            # This is a really simpler parser for 'vmstat' which grabs
            # the used memory amount in a lazy way. 'vmstat' prints 3
            # lines of output with the needed value being stored in the
            # final line.
            #
            # This loop simply grabs the 3rd element of each line until
            # the EOF is reached. Each line overwrites the value of the
            # previous one so we're left with what we wanted. This isn't
            # slow as only 3 lines are parsed.
            while read -r _ _ line _; do
                mem_used=${line%%M}

            # Using '<<-EOF' is the only way to loop over a command's
            # output without the use of a pipe ('|').
            # This ensures that any variables defined in the while loop
            # are still accessible in the script.
            done <<-EOF
                $(vmstat)
			EOF

    log memory "${mem_used:-?}M / ${mem_full:-?}M" >&6
}
