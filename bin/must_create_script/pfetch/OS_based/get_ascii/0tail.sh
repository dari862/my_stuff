    # Store the "width" (longest line) and "height" (number of lines)
    # of the ascii art for positioning. This script prints to the screen
    # *almost* like a TUI does. It uses escape sequences to allow dynamic
    # printing of the information through user configuration.
    #
    # Iterate over each line of the ascii art to retrieve the above
    # information. The 'sed' is used to strip '\033[3Xm' color codes from
    # the ascii art so they don't affect the width variable.
    while read -r line; do
        ascii_height=$((${ascii_height:-0} + 1))

        # This was a ternary operation but they aren't supported in
        # Minix's shell.
        [ "${#line}" -gt "${ascii_width:-0}" ] &&
            ascii_width=${#line}

    # Using '<<-EOF' is the only way to loop over a command's
    # output without the use of a pipe ('|').
    # This ensures that any variables defined in the while loop
    # are still accessible in the script.
    done <<-EOF
 		$(printf %s "$ascii" | sed 's/\[3.m//g')
	EOF

    # Add a gap between the ascii art and the information.
    ascii_width=$((ascii_width + 4))

    # Print the ascii art and position the cursor back where we
    # started prior to printing it.
    {
        esc_p SGR 1
        printf '%s' "$ascii"
        esc_p SGR 0
        esc_p CUU "$ascii_height"
    } >&6
}
