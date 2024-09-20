if [ -f "${My_shell_DIR}/shared_plugin/lfcd" ]; then 
  source "${My_shell_DIR}/shared_plugin/lfcd"
else 
  echo "lfcd does not exist wget it from (https://codeberg.org/tplasdio/lf-config/raw/branch/main/.config/dash/functions/lfcd)."
fi
