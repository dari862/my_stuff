
get_memory() {
    hw_pagesize=$(pagesize)

            # 'kstat' outputs memory in the following format:
            # unix:0:system_pages:pagestotal	1046397
            # unix:0:system_pages:pagesfree		885018
            #
            # This simply uses the first "element" (white-space
            # separated) as the key and the second element as the
            # value.
            #
            # A variable is then assigned based on the key.
            while read -r key val; do
                case $key in
                    (*total)
                        pages_full=$val
                    ;;

                    (*free)
                        pages_free=$val
                    ;;
                esac
            done <<-EOF
				$(kstat -p unix:0:system_pages:pagestotal \
                           unix:0:system_pages:pagesfree)
			EOF

            mem_full=$((pages_full * hw_pagesize / 1024 / 1024))
            mem_free=$((pages_free * hw_pagesize / 1024 / 1024))
            mem_used=$((mem_full - mem_free))

    log memory "${mem_used:-?}M / ${mem_full:-?}M" >&6
}
