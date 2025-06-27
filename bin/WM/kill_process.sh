#!/bin/sh
__process_name="${1-}"
# pidof -q ${__process_name} && killall -9 ${__process_name}

__process_id="$(pgrep -x $__process_name 2>/dev/null || :)"
if [ -n "$__process_id" ];then
	for pid in $__process_id;do
		kill ${pid} >/dev/null 2>&1
	done
fi
