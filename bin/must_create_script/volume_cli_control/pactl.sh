SINK="$(pactl info | grep -P '^Default Sink: ' | sed 's/[^:]\+:\s\+//')"
if echo "$SINK" | grep -q "DragonFly";then
  	INCR='24'
  	MIN_VOLUME=65050
  	MAX_VOLUME=65146
else
  	INCR='10%'
  	MIN_VOLUME=0
  	MAX_VOLUME=65536
fi

volume() {
  	VOLUME="$(pacmd dump | grep -P '^set-sink-volume.*\s+0x[1-9a-f][0-9a-f]*$')"
  	if echo "$VOLUME" | grep -qF "$SINK";then
   		VOLUME="$(echo "$VOLUME" | grep -oP '0x[1-9a-f][0-9a-f]*$')"
   		printf "%d\n" "$VOLUME"
  	else
   		echo 0
  	fi
  	unset VOLUME
}

VOLUME="$(volume)"
# Get Volume
get_volume() {
	SINK=$( pactl list short sinks | sed -e 's,^\([0-9][0-9]*\)[^0-9].*,\1,' | head -n 1 )
	pactl list sinks | grep '^[:space:]Volume:' | head -n $(( SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,'
}

# Get icons
get_icon() {
	current="$(get_volume)"
	if [ "$current" -ge 0 ] && [ "$current" -le 50 ];then
		icon=""
	elif [ "$current" -ge 50 ] && [ "$current" -le 100 ];then
		icon=""
	elif [ "$current" -ge 100 ] && [ "$current" -le 150 ];then
		icon=""
	fi
}

# Get status
get_status() {
	get_icon
	MUTED="$(pacmd dump | grep -P '^set-sink-mute.*\s+yes$')"
   	if echo "$MUTED" | grep -qF "$SINK";then
		echo ' Mute'
	else
		echo "$icon $(get_volume)%"
	fi
}

# Increase Volume
inc_volume() {
	pactl -- set-sink-volume "$SINK" "+$INCR"
   	if [ "$VOLUME" -gt $MAX_VOLUME ];then
     	pactl -- set-sink-volume "$SINK" "$MAX_VOLUME"
   	fi
}

# Decrease Volume
dec_volume() {
	pactl -- set-sink-volume "$SINK" "-$INCR"
   	if [ "$VOLUME" -lt $MIN_VOLUME ];then
	  	pactl -- set-sink-volume "$SINK" "$MIN_VOLUME"
   	fi
}
	
# Toggle Mute
toggle_mute() {
	MUTED="$(pacmd dump | grep -P '^set-sink-mute.*\s+yes$')"
   	if echo "$MUTED" | grep -qF "$SINK";then
  		pactl -- set-sink-mute "$SINK" 0
   	else
   		pactl -- set-sink-mute "$SINK" 1
	fi
}

# Toggle Mic
toggle_mic() {
	MUTED="$(pacmd dump | grep -P '^set-source-mute.*\s+yes$')"
  	if echo "$MUTED" | grep -qF "$SINK";then
  		pactl -- set-source-mute "$SINK" 0
   	else
  		pactl -- set-source-mute "$SINK" 1
   	fi
}
