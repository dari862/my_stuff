#!/bin/sh
sed -i \
         -e 's/rgb(0%,0%,0%)/{background}/g' \
         -e 's/rgb(100%,100%,100%)/{foreground}/g' \
    -e 's/rgb(50%,0%,0%)/{cursor}/g' \
     -e 's/rgb(0%,50%,0%)/{color3}/g' \
 -e 's/rgb(0%,50.196078%,0%)/{color3}/g' \
     -e 's/rgb(50%,0%,50%)/{cursor}/g' \
 -e 's/rgb(50.196078%,0%,50.196078%)/{cursor}/g' \
     -e 's/rgb(0%,0%,50%)/{foreground}/g' \
	"$@"
