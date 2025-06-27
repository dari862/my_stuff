#!/bin/sh
#
# pfetch - Simple POSIX sh fetch script.

arch="____arch____"
os="____os____"

# Wrapper around all escape sequences used by pfetch to allow for
# greater control over which sequences are used (if any at all).
esc() {
    case $1 in
        CUU) e="${esc_c}[${2}A" ;; # cursor up
        CUD) e="${esc_c}[${2}B" ;; # cursor down
        CUF) e="${esc_c}[${2}C" ;; # cursor right
        CUB) e="${esc_c}[${2}D" ;; # cursor left

        # text formatting
        SGR)
            case ${PF_COLOR:=1} in
                (1)
                    e="${esc_c}[${2}m"
                ;;

                (0)
                    # colors disabled
                    e=
                ;;
            esac
        ;;

        # line wrap
        DECAWM)
            case $TERM in
                (dumb | minix | cons25)
                    # not supported
                    e=
                ;;

                (*)
                    e="${esc_c}[?7${2}"
                ;;
            esac
        ;;
    esac
}

# Print a sequence to the terminal.
esc_p() {
    esc "$@"
    printf '%s' "$e"
}

log() {
    # The 'log()' function handles the printing of information.
    # In 'pfetch' (and 'neofetch'!) the printing of the ascii art and info
    # happen independently of each other.
    #
    # The size of the ascii art is stored and the ascii is printed first.
    # Once the ascii is printed, the cursor is located right below the art
    # (See marker $[1]).
    #
    # Using the stored ascii size, the cursor is then moved to marker $[2].
    # This is simply a cursor up escape sequence using the "height" of the
    # ascii art.
    #
    # 'log()' then moves the cursor to the right the "width" of the ascii art
    # with an additional amount of padding to add a gap between the art and
    # the information (See marker $[3]).
    #
    # When 'log()' has executed, the cursor is then located at marker $[4].
    # When 'log()' is run a second time, the next line of information is
    # printed, moving the cursor to marker $[5].
    #
    # Markers $[4] and $[5] repeat all the way down through the ascii art
    # until there is no more information left to print.
    #
    # Every time 'log()' is called the script keeps track of how many lines
    # were printed. When printing is complete the cursor is then manually
    # placed below the information and the art according to the "heights"
    # of both.
    #
    # The math is simple: move cursor down $((ascii_height - info_height)).
    # If the aim is to move the cursor from marker $[5] to marker $[6],
    # plus the ascii height is 8 while the info height is 2 it'd be a move
    # of 6 lines downwards.
    #
    # However, if the information printed is "taller" (takes up more lines)
    # than the ascii art, the cursor isn't moved at all!
    #
    # Once the cursor is at marker $[6], the script exits. This is the gist
    # of how this "dynamic" printing and layout works.
    #
    # This method allows ascii art to be stored without markers for info
    # and it allows for easy swapping of info order and amount.
    #
    # $[2] ___      $[3] goldie@KISS
    # $[4](.· |     $[5] os KISS Linux
    #     (<> |
    #    / __  \
    #   ( /  \ /|
    #  _/\ __)/_)
    #  \/-____\/
    # $[1]
    #
    # $[6] /home/goldie $

    # End here if no data was found.
    [ "$2" ] || return

    # Store the values of '$1' and '$3' as we reset the argument list below.
    name=$1
    use_seperator=$3

    # Use 'set --' as a means of stripping all leading and trailing
    # white-space from the info string. This also normalizes all
    # white-space inside of the string.
    #
    # Disable the shellcheck warning for word-splitting
    # as it's safe and intended ('set -f' disables globbing).
    # shellcheck disable=2046,2086
    {
        set -f
        set +f -- $2
        info=$*
    }

    # Move the cursor to the right, the width of the ascii art with an
    # additional gap for text spacing.
    esc_p CUF "$ascii_width"

    # Print the info name and color the text.
    esc_p SGR "3${PF_COL1-4}";
    esc_p SGR 1
    printf '%s' "$name"
    esc_p SGR 0

    # Print the info name and info data separator, if applicable.
    [ "$use_seperator" ] || printf %s "$PF_SEP"

    # Move the cursor backward the length of the *current* info name and
    # then move it forwards the length of the *longest* info name. This
    # aligns each info data line.
    esc_p CUB "${#name}"
    esc_p CUF "${PF_ALIGN:-$info_length}"

    # Print the info data, color it and strip all leading whitespace
    # from the string.
    esc_p SGR "3${PF_COL2-9}"
    printf '%s' "$info"
    esc_p SGR 0
    printf '\n'

    # Keep track of the number of times 'log()' has been run.
    info_height=$((${info_height:-0} + 1))
}

get_title() {
    user="____user____"
    hostname="____hostname____"
    # Add escape sequences for coloring to user and host name. As we embed
    # them directly in the arguments passed to log(), we cannot use esc_p().
    esc SGR 1
    user=$e$user
    esc SGR "3${PF_COL3:-1}"
    user=$e$user
    esc SGR 1
    user=$user$e
    esc SGR 1
    hostname=$e$hostname
    esc SGR "3${PF_COL3:-1}"
    hostname=$e$hostname

    log "${user}@${hostname}" " " " " >&6
}

get_de() {
    # This only supports Xorg related desktop environments though
    # this is fine as knowing the desktop environment on Windows,
    # macOS etc is useless (they'll always report the same value).
    #
    # Display the value of '$XDG_CURRENT_DESKTOP', if it's empty,
    # display the value of '$DESKTOP_SESSION'.
    log de "${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}" >&6
}

get_shell() {
    # Display the basename of the '$SHELL' environment variable.
    log shell "${SHELL##*/}" >&6
}

get_editor() {
    # Display the value of '$VISUAL', if it's empty, display the
    # value of '$EDITOR'.
    editor=${VISUAL:-"$EDITOR"}

    log editor "${editor##*/}" >&6
}

get_palette() {
    # Print the first 8 terminal colors. This uses the existing
    # sequences to change text color with a sequence prepended
    # to reverse the foreground and background colors.
    #
    # This allows us to save hardcoding a second set of sequences
    # for background colors.
    #
    # False positive.
    # shellcheck disable=2154
    {
        esc SGR 7
        palette="$e$c1 $c1 $c2 $c2 $c3 $c3 $c4 $c4 $c5 $c5 $c6 $c6 "
        esc SGR 0
        palette="$palette$e"
    }

    # Print the palette with a new-line before and afterwards but no seperator.
    printf '\n' >&6
    log "$palette
        " " " " " >&6
}
