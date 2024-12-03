my-superuser apt -y purge "php8.3*"
my-superuser rm -rf /usr/share/keyrings/deb.sury.org-php.gpg /etc/apt/sources.list.d/php.list
[[ -f "/usr/local/bin/composer" ]] && my-superuser rm /usr/local/bin/composer
