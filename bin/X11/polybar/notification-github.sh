#!/bin/sh
USERNAME_and_ACCESS_TOKEN="$(myAPIman show github 2>/dev/null || :)"
if [ -n "${USERNAME_and_ACCESS_TOKEN}" ];then
	notifications=$(getURL "ugn" "$USERNAME_and_ACCESS_TOKEN")
else
	notifications="󱉗"
fi

echo "$notifications"
