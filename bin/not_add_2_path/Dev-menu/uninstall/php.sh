sudo apt -y purge "php8.3*"
sudo rm -rf /usr/share/keyrings/deb.sury.org-php.gpg /etc/apt/sources.list.d/php.list
[[ -f "/usr/local/bin/composer" ]] && sudo rm /usr/local/bin/composer
