
get_uptime() {
    # Uptime works by retrieving the data in total seconds and then
    # converting that data into days, hours and minutes using simple
    # math.
    # Split the output of 'kstat' on '.' and any white-space
            # which exists in the command output.
            #
            # The output is as follows:
            # unix:0:system_misc:snaptime	14809.906993005
            #
            # The parser extracts:          ^^^^^
            IFS='	.' read -r _ s _ <<-EOF
				$(kstat -p unix:0:system_misc:snaptime)
			EOF

    # Convert the uptime from seconds into days, hours and minutes.
    d=$((s / 60 / 60 / 24))
    h=$((s / 60 / 60 % 24))
    m=$((s / 60 % 60))

    # Only append days, hours and minutes if they're non-zero.
    case "$d" in ([!0]*) uptime="${uptime}${d}d "; esac
    case "$h" in ([!0]*) uptime="${uptime}${h}h "; esac
    case "$m" in ([!0]*) uptime="${uptime}${m}m "; esac

    log uptime "${uptime:-0m}" >&6
}
