
get_uptime() {
    # Uptime works by retrieving the data in total seconds and then
    # converting that data into days, hours and minutes using simple
    # math.
    IFS=. read -r s _ < /proc/uptime
    
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
