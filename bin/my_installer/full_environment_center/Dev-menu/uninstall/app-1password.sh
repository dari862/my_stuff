my-superuser rm /etc/apt/sources.list.d/1password.list
my-superuser rm /usr/share/keyrings/1password-archive-keyring.gpg
my-superuser rm /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
my-superuser rm -r /etc/debsig/policies/AC2D62742012EA22/
my-superuser apt-get remove --purge -y 1password 1password-cli
