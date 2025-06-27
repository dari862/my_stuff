
get_memory() {
    # Read the first line of 'sysinfo -mem' splitting on
            # '(', ' ', and ')'. The needed information is then
            # stored in the 5th and 7th elements. Using '_' "consumes"
            # an element allowing us to proceed to the next one.
            #
            # The parsed format is as follows:
            # 3501142016 bytes free      (used/max  792645632 / 4293787648)
            IFS='( )' read -r _ _ _ _ mem_used _ mem_full <<-EOF
                $(sysinfo -mem)
			EOF

            mem_used=$((mem_used / 1024 / 1024))
            mem_full=$((mem_full / 1024 / 1024))

    log memory "${mem_used:-?}M / ${mem_full:-?}M" >&6
}
