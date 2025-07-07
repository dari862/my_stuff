#!/usr/bin/env sh
case "${1}" in
    +) volume_cli_control --inc
    ;;
    -) volume_cli_control --dec
    ;;
    0) volume_cli_control --toggle
    ;;
esac

AUDIO_VOLUME="$(volume_cli_control --get)"

if volume_cli_control --is-muted;then
	AUDIO_VOLUME="Muted"
	ICON=''
elif [ "$AUDIO_VOLUME" -eq 0 ]; then
    ICON=''
elif [ "$AUDIO_VOLUME" -lt 30 ]; then
    ICON=''
elif [ "$AUDIO_VOLUME" -lt 70 ]; then
    ICON=''
else
    ICON=''
fi

case "${1}" in
    icon) echo "${ICON:-?}"
    ;;
    per*) echo "${AUDIO_VOLUME}"
    ;;
esac
