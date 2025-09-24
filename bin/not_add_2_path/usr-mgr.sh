#!/bin/sh

# -------------------- Configuration -------------------- #
export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
SEC_PATH="/root"
LOG_FILE="$SEC_PATH/actions.log"
group=""
# -------------------- Utilities -------------------- #
log() {
    echo "$(date +%F %T) $(whoami): $*" >> "$LOG_FILE"
}

msg() {
    type="$1"
    color="$2"
    shift 2
    printf "[%s] %s%s%s\n" "$type" "$color" "$*" "\033[0m"
}

error()   { msg "ERROR" "\033[0;91m" "$@"; } # RED
info()    { msg "INFO"  "\033[0;96m" "$@"; } # CYAN
success() { msg "OK"    "\033[0;92m" "$@"; } # green
warn()    { msg "WARN"  "\033[0;95m" "$@"; } # PURPLE

confirm() {
    printf "%s " "${1:-Are you sure? [y/N]}"
    read -r answer
    case "$answer" in
        [yY] | [yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "Must be run as root."
        exit 1
    fi
    #get_super_group
    if grep -q "sudo" /etc/group; then
        group="sudo"
    else
        group="wheel"
    fi
}

gen_pass() {
    tr -dc 'A-Za-z0-9_@#%+=-' < /dev/urandom | head -c "${1:-12}"
}

sread() {
    printf '%s: ' "$2"
    stty -echo
    read -r "$1"
    stty echo
    printf '\n'
}

is_current_user_only_sudo_user() {
    checked_user="${1:-}"
    group_entry=$(getent group "$group")
    [ -z "$group_entry" ] && return 1
    users_field=$(printf '%s\n' "$group_entry" | awk -F: '{print $NF}')
    users_field_newline=$(printf '%s\n' "$users_field" | tr ',' '\n')
    number_of_supeuser="$(printf '%s\n' "$users_field_newline" | wc -l)"
    if [ "$number_of_supeuser" -eq 1 ] && printf '%s\n' "$users_field_newline" | grep -qw "$checked_user";then
    	return
    else
    	return 1
    fi
}

# -------------------- Core Functions -------------------- #
create_user() {
    sread user "Enter new username: "
    # shellcheck disable=2154
    if id "$user" >/dev/null 2>&1; then
        error "User '$user' already exists."
        return 1
    fi
   useradd -m -s /bin/bash "$user"
   success "User '$user' created."
   if confirm "Add password to user '$user'? (y/N): "; then
   	if passwd "$user" ;then
   			if confirm "Promote to superuser? (y/N): "; then
					usermod -aG "$group" "$user"
    				echo "$user ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$user"
    				log "User '$user' created with superuser permission."
   			fi
   	fi
  fi
}

list_users() {
    info "System Users:"
    getent passwd | awk -F: '$7 ~ /sh|bash|zsh|fish|ksh/ {print "User:", $1}'
}

reset_password() {
    sread user "Enter username: "
    if ! id "$user" >/dev/null 2>&1; then
        error "User '$user' not found."
        return 1
    fi

    if passwd "$user" ;then
    	success "Password for '$user' reset."
    	log "Password reset for '$user'."
    fi
}

lock_user() {
    sread user "Enter username to lock: "
    if is_current_user_only_sudo_user "$user";then
    	error "User '$user' can not be locked since '$user' are only sudo user."
    elif id "$user" >/dev/null 2>&1; then
        passwd -l "$user"
        success "User '$user' locked."
        log "Locked $user"
    else
        error "Failed to lock '$user'."
    fi
}

unlock_user() {
    sread user "Enter username to unlock: "
    if id "$user" >/dev/null 2>&1; then
        passwd -u "$user"
        success "User '$user' unlocked."
        log "Unlocked $user"
    else
        error "User '$user' not found."
    fi
}

list_locked_users() {
    grep '!' /etc/shadow | cut -d: -f1
}

backup_user() {
    sread user "Enter username to backup: "
    if id "$user" >/dev/null 2>&1; then
        homedir=$(getent passwd "$user" | cut -d: -f6)
        backup_dir="$homedir/backups"
        mkdir -p "$backup_dir"
        backup_file="${backup_dir}/${user}-$(date +%F).tar.gz"

        tar -czf "$backup_file" "$homedir"
        chown -R "$user:$user" "$backup_dir"
        success "Backup saved to $backup_file"
        log "Backup created for $user"
    else
        error "User '$user' not found."
    fi
}

generate_ssh_key() {
    sread user "Enter username: "
    if id "$user" >/dev/null 2>&1; then
        ssh_dir="/home/$user/.ssh"
        keyfile="${ssh_dir}/id_rsa_${user}"

        mkdir -p "$ssh_dir"
        chown "$user:$user" "$ssh_dir"
        chmod 700 "$ssh_dir"

        su - "$user" -c "ssh-keygen -t rsa -b 4096 -f '$keyfile' -N '' -C '${user}@local'"
        success "SSH key generated at $keyfile"
        su - "$user" -c "cat '${keyfile}.pub'"
        log "SSH key generated for $user"
    else
        error "User '$user' not found."
    fi
}

delete_user() {
    sread user "Enter username to delete: "
    if is_current_user_only_sudo_user "$user";then
    	error "User '$user' can not be deleted since '$user' are only sudo user."
    elif id "$user" >/dev/null 2>&1; then
        if confirm "Delete user '$user' and home directory?"; then
            userdel -r "$user"
            rm -f "/etc/sudoers.d/$user"
            success "User '$user' deleted."
            log "Deleted user $user"
        fi
    else
        error "Failed to delete '$user'."
    fi
}

promote_user() {
    sread user "Enter username to promote: "
    if id "$user" >/dev/null 2>&1; then
        usermod -aG "$group" "$user"
        echo "$user ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$user"
        success "User '$user' promoted to $group"
        log "Promoted $user to $group"
    else
        error "User '$user' not found."
    fi
}

degrate_user() {
    sread user "Enter username to remove from admin: "
    if is_current_user_only_sudo_user "$user";then
    	error "User '$user' can not be degrate since '$user' are only sudo user."
    elif id "$user" >/dev/null 2>&1; then
        gpasswd -d "$user" "$group"
        rm -f "/etc/sudoers.d/$user"
        success "User '$user' removed from $group"
        log "Degrated user $user"
    else
        error "Failed to degrate '$user'."
    fi
}

# -------------------- Menu -------------------- #
main_menu() {
    while true; do
		i=1
		while IFS= read -r opt; do
    		printf "%2d) %s\n" "$i" "$opt"
    		i=$((i + 1))
		done <<-EOF
		Create new user
		List users
		Reset password for user
		Lock user
		Unlock user
		List all locked users
		Backup user
		Generate SSH key for user
		Promote user to admin
		Degrate user from admin
		Delete user
		Quit
		EOF
		
		i=$((i - 1))
		printf 'Please enter your choice:\n'
		printf 'Enter choice [1-%d]: ' "$i"
		read -r choice
        case "$choice" in
            1) create_user "$@" ;;
            2) list_users ;;
            3) reset_password "$@" ;;
            4) lock_user ;;
            5) unlock_user ;;
            6) list_locked_users ;;
            7) backup_user ;;
            8) generate_ssh_key ;;
            9) promote_user;;
            10) degrate_user;;
            11) delete_user;;
            12) info "Exit" "Goodbye!"; break ;;
            *) error "Invalid option." ;;
        esac
    done
}

# -------------------- Start Script -------------------- #
check_root
cd "$SEC_PATH" || { error "Failed to cd to $SEC_PATH"; exit 1; }
main_menu "$@"
