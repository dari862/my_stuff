
get_uptime() {
    # Uptime works by retrieving the data in total seconds and then
    # converting that data into days, hours and minutes using simple
    # math.
    # Grab the uptime in a pretty format. Usually,
            # 00:00:00 from the 'ps' command.
            t=$(LC_ALL=POSIX ps -o etime= -p 1)

            # Split the pretty output into days or hours
            # based on the uptime.
            case $t in
                (*-*)   d=${t%%-*} t=${t#*-} ;;
                (*:*:*) h=${t%%:*} t=${t#*:} ;;
            esac

            h=${h#0} t=${t#0}

            # Convert the split pretty fields back into
            # seconds so we may re-convert them to our format.
            s=$((${d:-0}*86400 + ${h:-0}*3600 + ${t%%:*}*60 + ${t#*:}))

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
