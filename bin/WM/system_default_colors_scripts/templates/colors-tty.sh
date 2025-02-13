#!/bin/sh
[ "${TERM:-none}" = "linux" ] && \
    printf '%b' '\e]P0{color0}
                 \e]P1{color1}
                 \e]P2{color2}
                 \e]P3{color3}
                 \e]P4{color4}
                 \e]P5{color5}
                 \e]P6{color6}
                 \e]P7{color7}
                 \e]P8{color8}
                 \e]P9{color9}
                 \e]PA{color10}
                 \e]PB{color11}
                 \e]PC{color12}
                 \e]PD{color13}
                 \e]PE{color14}
                 \e]PF{color15}
                 \ec'
