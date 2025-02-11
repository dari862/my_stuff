if [ -f "${My_shell_DIR}/shared_plugin/z.sh" ];then 
  _Z_CMD=j
  _Z_DATA="${My_shell_DIR}/shared_plugin/z_database"
  source "${My_shell_DIR}/shared_plugin/z.sh"
else 
  getURL 'download2' "https://raw.githubusercontent.com/rupa/z/refs/heads/master/z.sh" "${My_shell_DIR}/shared_plugin/z.sh"
  chmod +x "${My_shell_DIR}/shared_plugin/z.sh"
fi
