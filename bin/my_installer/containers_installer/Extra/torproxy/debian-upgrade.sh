#!/bin/sh
set -e

if [ "$1" = "--up-to-date" ];then
  apt-get update -qq
  UPGRADABLE_COUNT="$(apt list --upgradable 2>/dev/null | grep -vc 'Listing...')"
  [ "$UPGRADABLE_COUNT" -gt 0 ] && exit 1 || exit 0
else
  apt-get update
  apt-get full-upgrade -y
  apt-get autoremove -y
  apt-get autoclean -y
fi
