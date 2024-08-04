# Remove service
my-superuser systemctl stop ollama
my-superuser systemctl disable ollama
my-superuser rm /etc/systemd/system/ollama.service

# Remove command
my-superuser rm $(which ollama)

# Remove installed models
my-superuser rm -r /usr/share/ollama
my-superuser userdel ollama
my-superuser groupdel ollama
