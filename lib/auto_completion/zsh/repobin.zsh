#compdef repobin

_arguments -s \
  '--bin-dir=[Set binary install directory]:directory:_files' \
  '--config-file=[Set config file path]:file:_files' \
  '--sudo[Use sudo for protected installs]' \
  '1:command:(install update list remove info clean reinstall help)' \
  '2:argument:->args'

case $words[1] in
  install)
    _arguments '2:repo:user/repo'
    ;;
  remove|info|reinstall)
    _arguments '2:repo:user/repo'
    ;;
  *)
    ;;
esac
