############################################
#	pactl
############################################

get_raw_volume() {
  	hex_volume_with_sink="$(pacmd dump | grep -P '^set-sink-volume.*\s+0x[1-9a-f][0-9a-f]*$')"
  	if echo "$hex_volume_with_sink" | grep -qF "$SINK";then
   		hex_volume="$(echo "$hex_volume_with_sink" | grep -oP '0x[1-9a-f][0-9a-f]*$')"
   		raw_volume="$(printf "%d\n" "$hex_volume")"
  	else
   		raw_volume="0"
  	fi
}

# print Volume
set_volume() {
	SINK=$( pactl list short sinks | sed -e 's,^\([0-9][0-9]*\)[^0-9].*,\1,' | head -n 1 )
	current_volume="$(pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')"
}

print_volume() {
	echo "$current_volume"
}

print_icon() {
	echo "$icon_string"
}

# Get status
am_muted() {
   	if pacmd dump | grep -P '^set-sink-mute.*\s+yes$' | grep -qF "$SINK";then
		return 0
	else
		return 1
	fi
}

# Increase Volume
inc_volume() {
	get_raw_volume
	pactl -- set-sink-volume "$SINK" "+$INCR"
   	if [ "$raw_volume" -gt $MAX_VOLUME ];then
     	pactl -- set-sink-volume "$SINK" "$MAX_VOLUME"
   	fi
}

# Decrease Volume
dec_volume() {
	get_raw_volume
	pactl -- set-sink-volume "$SINK" "-$INCR"
   	if [ "$raw_volume" -lt $MIN_VOLUME ];then
	  	pactl -- set-sink-volume "$SINK" "$MIN_VOLUME"
   	fi
}
	
# Toggle Mute
toggle_mute() {
   	if am_muted;then
  		pactl -- set-sink-mute "$SINK" 0
   	else
   		pactl -- set-sink-mute "$SINK" 1
	fi
}

# Toggle Mic
toggle_mic() {
  	if pacmd dump | grep -P '^set-source-mute.*\s+yes$' | grep -qF "$SINK";then
  		pactl -- set-source-mute "$SINK" 0
   	else
  		pactl -- set-source-mute "$SINK" 1
   	fi
}

raw_volume=""
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
