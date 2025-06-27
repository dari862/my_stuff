#!/bin/sh
__SocksPort=9050

if curl -sx socks5h://127.0.0.1:$__SocksPort 'https://check.torproject.org/' --stderr - | grep -qm1 Congratulations;then
	return
else
	return 1
fi
