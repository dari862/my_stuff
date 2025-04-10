if [ -f "${My_shell_DIR}/shared_plugin/lfcd" ];then 
  source "${My_shell_DIR}/shared_plugin/lfcd"
else 
  getURL 'download2' "https://codeberg.org/tplasdio/lf-config/raw/branch/main/.config/dash/functions/lfcd" "${My_shell_DIR}/shared_plugin/lfcd"
  chmod +x "${My_shell_DIR}/shared_plugin/lfcd"
fi
