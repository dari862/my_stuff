#!/bin/sh
__process_name="${1-}"
pidof -q ${__process_name} && killall -9 ${__process_name}
#__process_id="$(pgrep -f $__process_name)"
#if [ -n "$__process_id" ];then
#	kill -9 ${__process_id}
#fi
