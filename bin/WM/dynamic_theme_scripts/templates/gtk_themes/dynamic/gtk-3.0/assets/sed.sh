#!/bin/sh
sed -i \
         -e 's/{background}/rgb(0%,0%,0%)/g' \
         -e 's/{foreground}/rgb(100%,100%,100%)/g' \
    -e 's/{cursor}/rgb(50%,0%,0%)/g' \
     -e 's/{color3}/rgb(0%,50%,0%)/g' \
     -e 's/{cursor}/rgb(50%,0%,50%)/g' \
     -e 's/{foreground}/rgb(0%,0%,50%)/g' \
	"$@"
