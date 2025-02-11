# Compression
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }

# Extracts any archive(s) (if unp isn't installed)
extract() {
	for archive in "$@"; do
		if [ -f "$archive" ];then
			case $archive in
			*.tar.bz2) tar xvjf $archive ;;
			*.tar.gz) tar xvzf $archive ;;
			*.bz2) bunzip2 $archive ;;
			*.rar) rar x $archive ;;
			*.gz) gunzip $archive ;;
			*.tar) tar xvf $archive ;;
			*.tbz2) tar xvjf $archive ;;
			*.tgz) tar xvzf $archive ;;
			*.zip) unzip $archive ;;
			*.Z) uncompress $archive ;;
			*.7z) 7z x $archive ;;
			*) echo "don't know how to extract '$archive'..." ;;
			esac
		else
			echo "'$archive' is not a valid file!"
		fi
	done
}

compress(){
	case $1 in
		*.tar.*)
			name="${1%.*}"
			ext="${1#*.tar}"; shift
			tar cvf "$name" "$@"
			case $ext in
				.gz) gzip -9r "$name" ;;
				.bz2) bzip2 -9zv "$name";;
			esac
		;;
		*.gz) shift; gzip -9rk "$@" ;;
		*.zip) zip -9r "$@" ;;
		*.7z) 7z a -mx9 "$@" ;;
		*) printf "estensione non valida/non supportata"
	esac
}

# Searches for text in all files in the current folder
ftext() {
	# -i case-insensitive
	# -I ignore binary files
	# -H causes filename to be printed
	# -r recursive search
	# -n causes line number to be printed
	# optional: -F treat search term as a literal, not a regular expression
	# optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
	grep -iIHrn --color=always "$1" . | less -r
}

# Copy file with a progress bar
cpp() {
	set -e
	strace -q -ewrite cp -- "${1}" "${2}" 2>&1 |
		awk '{
	count += $NF
	if (count % 10 == 0) {
		percent = count / total_size * 100
		printf "%3d%% [", percent
		for (i=0;i<=percent;i++)
			printf "="
			printf ">"
			for (i=percent;i<100;i++)
				printf " "
				printf "]\r"
			}
		}
	END { print "" }' total_size="$(stat -c '%s' "${1}")" count=0
}

# Copy and go to the directory
cpg() {
	if [ -d "$2" ];then
		cp "$1" "$2" && cd "$2"
	else
		cp "$1" "$2"
	fi
}

# Move and go to the directory
mvg() {
	if [ -d "$2" ];then
		mv "$1" "$2" && cd "$2"
	else
		mv "$1" "$2"
	fi
}

# Create and go to the directory
mkdirg() {
	mkdir -p "$1"
	cd "$1"
}

# Goes up a specified number of directories  (i.e. up 4)
up() {
	local d=""
	limit=$1
	for ((i = 1; i <= limit; i++)); do
		d=$d/..
	done
	d=$(echo $d | sed 's/^\///')
	if [ -z "$d" ];then
		d=..
	fi
	cd $d
}

# Automatically do an ls after each cd, z, or zoxide
cd ()
{
	if [ -n "$1" ];then
		builtin cd "$@" && ls
	else
		builtin cd ~ && ls
	fi
}

# Returns the last 2 fields of the working directory
pwdtail() {
	pwd | awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
}

# IP address lookup
alias whatismyip="whatsmyip"
function whatsmyip ()
{
	# Internal IP Lookup.
	if [ -e /sbin/ip ];then
		echo -n "Internal IP: "
		/sbin/ip addr show wlan0 | grep "inet " | awk -F: '{print $1}' | awk '{print $2}'
	else
		echo -n "Internal IP: "
		/sbin/ifconfig wlan0 | grep "inet " | awk -F: '{print $1} |' | awk '{print $2}'
	fi

	# External IP Lookup
	echo -n "External IP: "
	getURL '2term' ifconfig.me
}

# View Apache logs
apachelog() {
	if [ -f /etc/httpd/conf/httpd.conf ];then
		cd /var/log/httpd && ls -xAh && multitail --no-repeat -c -s 2 /var/log/httpd/*_log
	else
		cd /var/log/apache2 && ls -xAh && multitail --no-repeat -c -s 2 /var/log/apache2/*.log
	fi
}

# Edit the Apache configuration
apacheconfig() {
	if [ -f /etc/httpd/conf/httpd.conf ];then
		my-superuser $CLI_EDITER /etc/httpd/conf/httpd.conf
	elif [ -f /etc/apache2/apache2.conf ];then
		my-superuser $CLI_EDITER /etc/apache2/apache2.conf
	else
		echo "Error: Apache config file could not be found."
		echo "Searching for possible locations:"
		my-superuser updatedb && locate httpd.conf && locate apache2.conf
	fi
}

# Edit the PHP configuration file
phpconfig() {
	if [ -f /etc/php.ini ];then
		my-superuser $CLI_EDITER /etc/php.ini
	elif [ -f /etc/php/php.ini ];then
		my-superuser $CLI_EDITER /etc/php/php.ini
	elif [ -f /etc/php5/php.ini ];then
		my-superuser $CLI_EDITER /etc/php5/php.ini
	elif [ -f /usr/bin/php5/bin/php.ini ];then
		my-superuser $CLI_EDITER /usr/bin/php5/bin/php.ini
	elif [ -f /etc/php5/apache2/php.ini ];then
		my-superuser $CLI_EDITER /etc/php5/apache2/php.ini
	else
		echo "Error: php.ini file could not be found."
		echo "Searching for possible locations:"
		my-superuser updatedb && locate php.ini
	fi
}

# Edit the MySQL configuration file
mysqlconfig() {
	if [ -f /etc/my.cnf ];then
		my-superuser $CLI_EDITER /etc/my.cnf
	elif [ -f /etc/mysql/my.cnf ];then
		my-superuser $CLI_EDITER /etc/mysql/my.cnf
	elif [ -f /usr/local/etc/my.cnf ];then
		my-superuser $CLI_EDITER /usr/local/etc/my.cnf
	elif [ -f /usr/bin/mysql/my.cnf ];then
		my-superuser $CLI_EDITER /usr/bin/mysql/my.cnf
	elif [ -f ~/my.cnf ];then
		$CLI_EDITER ~/my.cnf
	elif [ -f ~/.my.cnf ];then
		$CLI_EDITER ~/.my.cnf
	else
		echo "Error: my.cnf file could not be found."
		echo "Searching for possible locations:"
		my-superuser updatedb && locate my.cnf
	fi
}

# Trim leading and trailing spaces (for scripts)
trim() {
	local var=$*
	var="${var#"${var%%[![:space:]]*}"}" # remove leading whitespace characters
	var="${var%"${var##*[![:space:]]}"}" # remove trailing whitespace characters
	echo -n "$var"
}

# GitHub
gcom() {
	git add .
	git commit -m "$1"
}
lazyg() {
	git add .
	git commit -m "$1"
	git push
}
