
get_uptime() {
    # Uptime works by retrieving the data in total seconds and then
    # converting that data into days, hours and minutes using simple
    # math.
    s=$(sysctl -n kern.boottime)

            # Extract the uptime in seconds from the following output:
            # [...] { sec = 1271934886, usec = 667779 } Thu Apr 22 12:14:46 2010
            s=${s#*=}
            s=${s%,*}

            # The uptime format from 'sysctl' needs to be subtracted from
            # the current time in seconds.
            s=$(($(printf "%(%s)T") - s))

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
