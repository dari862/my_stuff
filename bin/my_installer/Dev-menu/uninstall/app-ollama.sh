# Remove service
my-superuser service_manager stop ollama
my-superuser service_manager disable ollama
[ -f "/etc/systemd/system/ollama.service" ] && my-superuser rm /etc/systemd/system/ollama.service

# Remove command
my-superuser rm $(which ollama)

# Remove installed models
my-superuser rm -r /usr/share/ollama
my-superuser userdel ollama
my-superuser groupdel ollama
