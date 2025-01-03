#!/bin/sh
__process_name="${1-}"
pidof -q ${__process_name} && killall -9 ${__process_name}
