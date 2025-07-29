#!/bin/sh
USERNAME_and_ACCESS_TOKEN="$(myAPIman show github)"
if [ -z "${USERNAME}" ] || [ -z "${ACCESS_TOKEN}" ];then
	notifications=$(echo "user = \"${USERNAME_and_ACCESS_TOKEN}\"" | curl -sf -K- https://api.github.com/notifications | jq ".[].unread" | grep -c true)
else
	notifications="󱉗"
fi

echo "$notifications"
