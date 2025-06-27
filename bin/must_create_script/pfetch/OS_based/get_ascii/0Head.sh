get_ascii() {
    # This is a simple function to read the contents of
    # an ascii file from 'stdin'. It allows for the use
    # of '<<-EOF' to prevent the break in indentation in
    # this source code.
    #
    # This function also sets the text colors according
    # to the ascii color.
    read_ascii() {
        # 'PF_COL1': Set the info name color according to ascii color.
        # 'PF_COL3': Set the title color to some other color. ¯\_(ツ)_/¯
        PF_COL1=${PF_COL1:-${1:-7}}
        PF_COL3=${PF_COL3:-$((${1:-7}%8+1))}

        # POSIX sh has no 'var+=' so 'var=${var}append' is used. What's
        # interesting is that 'var+=' _is_ supported inside '$(())'
        # (arithmetic) though there's no support for 'var++/var--'.
        #
        # There is also no $'\n' to add a "literal"(?) newline to the
        # string. The simplest workaround being to break the line inside
        # the string (though this has the caveat of breaking indentation).
        while IFS= read -r line; do
            ascii="$ascii$line
"
        done
    }
