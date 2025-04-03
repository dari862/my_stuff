
            if [ "$WSLENV" ]; then
                distro="${distro}${WSLENV+ on Windows 10 [WSL2]}"

            # Check to see if Linux is running in Windows 10 under
            # WSL2 (Windows subsystem for Linux [version 2]) and
            # append a string accordingly.
            #
            # This checks to see if '$WSLENV' is defined. This
            # appends the Windows 10 string even if '$WSLENV' is
            # empty. We only need to check that is has been _exported_.
            elif [ -z "${kernel%%*-Microsoft}" ]; then
                distro="$distro on Windows 10 [WSL1]"
            fi
            
            log os "$distro" >&6
            return
}
