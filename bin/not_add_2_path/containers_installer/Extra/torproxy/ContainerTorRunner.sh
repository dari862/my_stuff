#!/bin/sh
set -o nounset                              # Treat unset variables as an error

file=/etc/tor/torrc

__ControlPort=9051

BW="${BW:-""}"
EXITNODE="${EXITNODE:-""}"
LOCATION="${LOCATION:-""}"
PASSWORD="${PASSWORD:-""}"
SERVICE="${SERVICE:-""}"
USERID="${USERID:-""}"
GROUPID="${GROUPID:-""}"

### bandwidth: set the BW available for relaying
# Arguments:
#   KiB/s) KiB/s of data that can be relayed
# Return: Updated configuration file
bandwidth() { 
	kbs="${1:-10}" 
    sed -i '/^RelayBandwidth/d' $file
    echo "RelayBandwidthRate $kbs KB" >>$file
    echo "RelayBandwidthBurst $(( kbs * 2 )) KB" >>$file
}

### exitnode: Allow exit traffic
# Arguments:
#   N/A)
# Return: Updated configuration file
exitnode() {  
    sed -i '/^ExitPolicy/d' $file
}

### exitnode_country: Only allow traffic to exit in a specified country
# Arguments:
#   country) country where we want to exit
# Return: Updated configuration file
exitnode_country() { 
	country="$1" 
    sed -i '/^StrictNodes/d; /^ExitNodes/d' $file
    echo "StrictNodes 1" >>$file
    echo "ExitNodes {$country}" >>$file
}

### hidden_service: setup a hidden service
# Arguments:
#   port) port to connect to service
#   host) host:port where service is running
# Return: Updated configuration file
hidden_service() { 
	port="$1" 
	host="$2" 
    sed -i '/^HiddenServicePort '"$port"' /d' $file
    grep -q '^HiddenServiceDir' $file || echo "HiddenServiceDir /var/lib/tor/hidden_service" >>$file
    echo "HiddenServicePort $port $host" >>$file
}

### newnym: setup new circuits
# Arguments:
#   N/A)
# Return: New circuits for tor connections
newnym() { 
	authcookie_file=/etc/tor/run/control.authcookie
	printf "AUTHEN\TICATE \"$(cat add_wget_and_curl_support)\"\nSIGNAL NEWNYM\nQUIT\n" | nc 127.0.0.1 ${__ControlPort}
    if ps -ef -o comm | grep -E -v 'grep|ContainerTorRunner.sh' | grep -q tor; then
    	exit 0
    fi
}

### password: setup a hashed password
# Arguments:
#   passwd) passwd to set
# Return: Updated configuration file
password() { 
	passwd="$1"
	hashed_passwd="$(tor --hash-password "$passwd" |tail -n 1)"
    sed -i '/^HashedControlPassword/d' $file
    echo "HashedControlPassword $hashed_passwd" >>$file 2>/dev/null
}

### usage: Help
# Arguments:
#   none)
# Return: Help text
usage() { 
	RC="${1:-0}"
    Usage="Usage: ${0##*/} [-opt] [command]
Options (fields in '[]' are optional, '<>' are required):
    -h          This help
    -b \"\"       Configure tor relaying bandwidth in KB/s
                possible arg: \"[number]\" - # of KB/s to allow
    -e          Allow this to be an exit node for tor traffic
    -l \"<country>\" Configure tor to only use exit nodes in specified country
                required args: \"<country>\" (IE, "US" or "DE")
                <country> - country traffic should exit in
    -n          Generate new circuits now
    -p \"<password>\" Configure tor HashedControlPassword for control port
    -s \"<port>;<host:port>\" Configure tor hidden service
                required args: \"<port>;<host:port>\"
                <port> - port for .onion service to listen on
                <host:port> - destination for service request

The 'command' (if provided and valid) will be run instead of torproxy
" 
	echo $Usage >&2
    exit $RC
}

while getopts ":hb:el:np:s:" opt; do
    case "$opt" in
        h) usage ;;
        b) bandwidth "$OPTARG" ;;
        e) exitnode ;;
        l) exitnode_country "$OPTARG" ;;
        n) newnym ;;
        p) password "$OPTARG" ;;
        s) eval hidden_service $(echo $OPTARG | sed 's/^/"/; s/$/"/; s/;/" "/g') ;;
        "?") echo "Unknown option: -$OPTARG"; usage 1 ;;
        ":") echo "No argument value for option: -$OPTARG"; usage 2 ;;
    esac
done
shift $(( OPTIND - 1 ))

if [ -n "${BW}" ];then
	bandwidth "$BW"
fi

if [ "${EXITNODE}" ];then
	exitnode
fi

if [ "${LOCATION}" ];then
	exitnode_country "$LOCATION"
fi

if [ "${PASSWORD}" ];then
	password "$PASSWORD"
fi

if [ "${SERVICE}" ];then
	eval hidden_service $(echo $SERVICE | sed 's/^/"/; s/$/"/; s/;/" "/g')
fi

if echo "${USERID}" | grep -q "^[0-9]\+$";then
	usermod -u $USERID -o tor
fi

if echo "${USERID}" | grep -q "^[0-9]\+$";then
	groupmod -g $GROUPID -o tor
fi

for env in $(printenv | grep '^TOR_'); do
    name="$(echo ${env%%=*} | cut -c5-)"
    val="\"${env##*=}\""
    if echo "${USERID}" | grep -q "_";then
    	continue
    fi
    
    if echo "$val" | grep -E '(^\"true+\"$|^\"false+\"$|^\"[0-9]+\"$)';then
    	val="$(echo $val | sed 's|"||g')"
    fi
    
    if grep -q "^$name" /etc/tor/torrc; then
        sed -i "/^$name/s| .*| $val|" /etc/tor/torrc
    else
        echo "$name $val" >>/etc/tor/torrc
    fi
done

if [ "$#" -ge 1 ] && test -x "$(which "$1" 2>&-)"; then
    exec "$@"
elif [ "$#" -ge 1 ]; then
    echo "ERROR: command not found: $1"
    exit 13
elif ps -ef -o comm | grep -E -v 'grep|ContainerTorRunner.sh' | grep -q tor; then
    echo "Service already running, please restart container to apply changes"
else
    if test -e /srv/tor/hidden_service/hostname;then
        printf "\nHidden service hostname: "
        cat /srv/tor/hidden_service/hostname; 
        echo " "
    fi
    exec /usr/bin/tor
fi
