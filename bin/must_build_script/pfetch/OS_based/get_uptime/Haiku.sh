
get_uptime() {
    # Uptime works by retrieving the data in total seconds and then
    # converting that data into days, hours and minutes using simple
    # math.
    # The boot time is returned in microseconds, convert it to
            # regular seconds.
            s=$(($(system_time) / 1000000))

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
