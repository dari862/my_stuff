if [ -f "${My_shell_DIR}/z/z.sh" ]; then 
  _Z_CMD=j
  _Z_DATA="${My_shell_DIR}/z/z_database"
  source "${My_shell_DIR}/z/z.sh"
else 
  echo "z.sh does not exist wget it from (https://github.com/rupa/z)."
fi
