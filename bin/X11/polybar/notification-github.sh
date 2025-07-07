#!/bin/sh
. "/usr/share/my_stuff/lib/common/WM"
. "/usr/share/my_stuff/lib/common/API"
. "${API_path}/github"

if [ -z "${USERNAME}" ] || [ -z "${ACCESS_TOKEN}" ];then
	notifications=$(echo "user = \"$USERNAME:$ACCESS_TOKEN\"" | curl -sf -K- https://api.github.com/notifications | jq ".[].unread" | grep -c true)
else
	notifications="󱉗"
fi

echo "$notifications"
