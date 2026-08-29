#!/bin/sh
sed -i \
         -e 's/#1D1F28/rgb(0%,0%,0%)/g' \
         -e 's/#FDFDFD/rgb(100%,100%,100%)/g' \
    -e 's/#1F222B/rgb(50%,0%,0%)/g' \
     -e 's/#556FFF/rgb(0%,50%,0%)/g' \
     -e 's/#1D1F28/rgb(50%,0%,50%)/g' \
     -e 's/#FDFDFD/rgb(0%,0%,50%)/g' \
	"$@"
