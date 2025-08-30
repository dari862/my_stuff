# Replace batcat with cat on Fedora as batcat is not available as a RPM in any form
if command -v batcat >/dev/null;then
	alias bat='batcat'
elif ! command -v bat >/dev/null;then
	alias bat='cat'
fi
