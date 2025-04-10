#!/bin/sh
set -e


# -----------------------------------------------------------------------------
# NOVNC-DESKTOP-AGENT
# -----------------------------------------------------------------------------
# Dependencies: x11vnc, websockify, yad
#
# -----------------------------------------------------------------------------
NOVNC_SERVER=$(get_scripts --public)


# -----------------------------------------------------------------------------
# Messages
# -----------------------------------------------------------------------------
TITLE="noVNC Desktop Agent"
MSG_CLOSE_OLD="There is an already running instance and it will be terminated.\nDo you want to continue?"
MSG_SHARE="Do you want to share your desktop?"
MSG_SHARE_INFO="\nPlease, send the connection link and the password to your colleague"
MSG_CLOSE="The desktop sharing session is started. Close this window to terminate"
MSG_CONNECTED="someone connected from"


# -----------------------------------------------------------------------------
# ENVIRONMENT
# -----------------------------------------------------------------------------
PGID=$$
USER_ID="$(id -u)"
RUNDIR="/var/run/user/$USER_ID"
PIDFILE="$RUNDIR/vnc.$PGID"
HOST=$(ip addr show $(ip route | grep default | awk '{print $5}') | grep "inet " | awk '{print $2}' | cut -d/ -f1)
PORT=6080
SHARE_LINK="http://$NOVNC_SERVER/novnc/?host=$HOST&amp;port=$PORT"

echo $PGID > $PIDFILE


# -----------------------------------------------------------------------------
# cleanup
# -----------------------------------------------------------------------------
cleanup() {
    set +e

    pkill -U $USER_ID -f " YAD-$PGID"
    pkill -U $USER_ID -f " VNC-$PGID"
    sleep 0.2 && pkill -U $USER_ID -9 -f " VNC-$PGID"
    pkill -U $USER_ID -f "websockify .*$PORT"

    rm -f $PIDFILE
    pkill -U $USER_ID -g $PGID
}

# trap func
trap cleanup EXIT


# -----------------------------------------------------------------------------
# terminate_active_instances: terminate the active instances except this one
# -----------------------------------------------------------------------------
terminate_active_instances() {
    ls $RUNDIR/vnc.* | grep -v "vnc.$PGID" | \
    while read -r pidfile
    do
        pgid=$(echo $pidfile | cut -d '.' -f2)

        pkill -U $USER_ID -f " YAD-$pgid" || true
        pkill -U $USER_ID -f " VNC-$pgid" || true
        sleep 0.2 && pkill -U $USER_ID -9 -f " VNC-$pgid" || true
        pkill -U $USER_ID -f "websockify .*$PORT" || true

        pkill -U $USER_ID -g $pgid || true
        rm -f $pidfile
    done
}


# -----------------------------------------------------------------------------
# renew_credential: regenerate the x11vnc password
# -----------------------------------------------------------------------------
renew_credential() {
    mkdir -p ~/.vnc
    PASSWD=$(shuf -i 100000-999999 -n 1)
    x11vnc -storepasswd $PASSWD ~/.vnc/passwd

    (yad --title="$TITLE" --splash --no-escape --borders=20 \
        --text-align=center --selectable-labels \
        --buttons-layout=edge --button=gtk-cancel:0 \
        --form --align=center \
        --field="<big>$SHARE_LINK</big>:LBL" --field=" :LBL" \
        --field="<b><big><big>$PASSWD</big></big></b>:LBL" \
        --field=" :LBL" --field=":LBL" --field="$MSG_SHARE_INFO:LBL" \
        -- YAD-$PGID && kill $PGID) &
}


# -----------------------------------------------------------------------------
# start_websockify
# -----------------------------------------------------------------------------
start_websockify() {
     websockify --heartbeat=30 $PORT 127.0.0.1:$VNCPORT 2>&1 | while IFS= read -r output; do
        if [ -n "$(echo $output | egrep 'connecting to')" ];then
            ip=$(echo $output | cut -d ' ' -f1)
            yad --title="" --escape-ok --fixed --borders=20 \
                --text-align=center --timeout=5 --no-buttons \
                --text="$MSG_CONNECTED" \
                --form --align=center --field=" :LBL" \
                --field="<b><big><big>$ip</big></big></b>:LBL" \
                -- YAD-$PGID &
        fi
    done
}


# -----------------------------------------------------------------------------
# share_desktop: start and manage the x11vnc and websockify instances
# -----------------------------------------------------------------------------
share_desktop() {
	splashed=false
	oldport=""
	
	x11vnc -display :0 -localhost -autoport 5900 -noipv6 -nolookup \
       	-once -loop -usepw -shared -noxdamage -nodpms \
       	-tag VNC-$PGID 2>&1 | while IFS= read -r output; do
    	if echo "$output" | egrep -q '^PORT=';then
        	VNCPORT=$(echo "$output" | cut -d '=' -f2)
	
        	# restart websockify if the port is changed
        	if [ "$oldport" != "$VNCPORT" ];then
            	pkill -U "$USER_ID" -f "websockify .*$PORT" || true
            	start_websockify &
            	oldport="$VNCPORT"
        	fi
    	# open the permanent splash window if it's not opened before
    	elif echo "$output" | egrep -q 'client_set_net:' && [ "$splashed" = false ];then
        	pkill -U "$USER_ID" -f " YAD-$PGID" || true
        	(yad --title="$TITLE" --splash --no-escape --borders=20 \
            	--buttons-layout=edge --button=gtk-close:0 \
            	--text="$MSG_CLOSE" \
            	-- YAD-$PGID && kill "$PGID") &
        	splashed=true
    	fi
	done

}

# -----------------------------------------------------------------------------
# RUN
# -----------------------------------------------------------------------------
# check the running instances. don't go on if the user don't accept to
# terminate the old instances.
[ -n "$(ls $RUNDIR/vnc.* | grep -v vnc.$PGID)" ] && \
    yad --title="$TITLE" --splash --no-escape --borders=20 \
        --buttons-layout=edge --button=gtk-yes:0 --button=gtk-no:1 \
        --text="$MSG_CLOSE_OLD" \
        -- YAD-$PGID

# terminate the running instances
terminate_active_instances

# confirmation to start a new instance
yad --title="$TITLE" --splash --no-escape --borders=20 \
    --buttons-layout=edge --button=gtk-yes:0 --button=gtk-no:1 \
    --text="$MSG_SHARE" \
    -- YAD-$PGID

# renew and share the credential
renew_credential

# start to share the desktop
share_desktop
