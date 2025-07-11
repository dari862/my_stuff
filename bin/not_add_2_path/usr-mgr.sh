#!/bin/bash
# User manager script for Linux
# Created by Y.G.

# Envs
# ---------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH="$(dirname "$(realpath "$0")")"
cd $SCRIPT_PATH || echo "[ERROR] $0 : failed to cd $SCRIPT_PATH" exit 1

# Vars
# ---------------------------------------------------\
hostname=${HOSTNAME:-${hostname:-${HOST:-$(hostname)}}}
# If the hostname is still not found, fallback to the contents of the
# /etc/hostname file.
[ "$hostname" ] || read -r hostname < /etc/hostname

ME=$(basename "$0")
BACKUPS="$SCRIPT_PATH/backups"
SERVER_NAME="$hostname"
SERVER_IP="$(ip addr show $(ip route | grep default | awk '{print $5}') | grep "inet " | awk '{print $2}' | cut -d/ -f1)"
LOG="$SCRIPT_PATH/actions.log"
DISTRO_UNAME="$(uname)"

# Output messages
# ---------------------------------------------------\
RED='\033[0;91m'
GREEN='\033[0;92m'
CYAN='\033[0;96m'
YELLOW='\033[0;93m'
PURPLE='\033[0;95m'
BLUE='\033[0;94m'
BOLD='\033[1m'
WHiTE="\e[1;37m"
NC='\033[0m'

ON_SUCCESS="DONE"
ON_FAIL="FAIL"
ON_ERROR="Oops"
ON_CHECK="✓"

Info() {
  printf "[${1}] ${GREEN}${2}${NC}\n"
}

Warn() {
  printf "[${1}] ${PURPLE}${2}${NC}\n"
}

Success() {
  printf "[${1}] ${GREEN}${2}${NC}\n"
}

Error () {
  printf "[${1}] ${RED}${2}${NC}\n"
}

Splash() {
  printf "${WHiTE} ${1}${NC}\n"
}

space() { 
  printf ""
}


# Functions
# ---------------------------------------------------\

logthis() {
	__log_this_="$@"
    echo "$(date): $(whoami) - $__log_this_" >> "$LOG"
    # "$@" 2>> "$LOG"
}

isRoot() {
    if [ "$(id -u)" -ne 0 ];then
        Error "You must be root user to continue"
        exit 1
    fi
    RID=$(id -u root 2>/dev/null)
    if [ $? -ne 0 ];then
        Error "User root no found. You should create it to continue"
        exit 1
    fi
    if [ $RID -ne 0 ];then
        Error "User root UID not equals 0. User root must have UID 0"
        exit 1
    fi
}

# Checks supporting distros
checkDistro() {
    # Checking distro
    if [ -e /etc/centos-release ];then
        distro_desc=$(cat /etc/redhat-release | awk '{print $1,$4}')
        RPM=1
    elif [ -e /etc/fedora-release ];then
        distro_desc=$(cat /etc/fedora-release | awk '{print ($1,$3~/^[0-9]/?$3:$4)}')
        RPM=2
    elif [ -e "/usr/share/my_stuff/system_files/os-release" ];then
    	. "/usr/share/my_stuff/system_files/os-release"
        RPM=0
        DEB=1
    fi

    if [ "$DISTRO_UNAME" = 'Linux' ];then
        _LINUX=1
        Warn "Server info" "${SERVER_NAME} ${SERVER_IP} (${distro_desc}"
    else
        _LINUX=0
        Error "Error" "Your distribution is not supported (yet)"
    fi
}

# Yes / No confirmation
confirm() {
    # call with a prompt string or use a default
    printf "${1:-Are you sure? [y/N]} "
    stty -icanon -echo time 0 min 1
	answer="$(head -c1)"
	stty icanon echo
    printf
    case "$answer" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

check_bkp_folder() {
    if [ ! -d "$BACKUPS" ];then
        mkdir -p $BACKUPS
    fi
}

gen_pass() {
	LC_ALL=C tr -dc "-_A-Z-a-z-0-9" < /dev/urandom |
		dd ibs=1 obs=1 count="${1:-9}" 2>/dev/null
}

create_user() {

    space
    printf "Enter user name: "
    read user

    if id -u "$user" >/dev/null 2>&1;then
        Error "Error" "User $user exists. Try to set another user name."
    else
        Info "Info" "User $user will be create.."

        pass=$(gen_pass)
        
        if confirm "Promote user to admin? (y/n or enter for n)";then
            useradd -m -s /bin/bash -G wheel ${user}
            echo "%$user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$user
        else
            useradd -m -s /bin/bash ${user}
        fi

        # set password
        echo "$user:$pass" | chpasswd

        Info "Info" "User created. Name: $user. Password: $pass"

    fi
    space

}

list_users() {
    space
    Info "Info" "List of /bin/bash users: "
    # grep 'bash' /etc/passwd | cut -d: -f1
    users=$(awk -F: '$7=="/bin/bash" { print $1}' /etc/passwd)
    for user in $users
    do
        echo "User: $user , $(id $user | cut -d " " -f 1)"
    done
    root_info=$(cat /etc/passwd | grep root)
    Info "Root info" "${root_info}"
    space
}

reset_password() {
    space
    while :
    do
    	printf "Enter user name: " 
        read user
        if id $user > /dev/null 2>&1 
        then
            
            if confirm "Generate password automatically? (y/n or enter for n)";then
                pass=$(gen_pass)
                echo "$user:$pass" | chpasswd
                Info "Info" "Password changed. Name: $user. Password: $pass"
                logthis "Password changed. Name: $user. Password: $pass"
            else
            	printf "Enter user passwords: " 
        		read password
                echo "$password" | passwd --stdin $user
                Info "Info" "Password changed. Name: $user. Password: $password"
                logthis "Password changed. Name: $user. Password: $password"
            fi
            space
            return 0
        else
            Error "Error" "User $user does not found!"
            space
        fi
    done

}

lock_user() {
    
    space
    while :
    do
        printf "Enter user name: " 
        read user
        if [ -z $user ]
        then
            Error "Error" "Username can't be empty"
        else
            if id $user > /dev/null 2>&1
            then
                passwd -l $user
                Info "Info" "User $user locked"
                logthis "User $user locked"
                space
                return 0
            else
                Error "Error" "User $user does not found!"
                space
            fi
        fi
    done
}

unlock_user() {
    space
    while :
    do
        printf "Enter user name: " 
        read user
        if [ -z $user ]
        then
            Error "Error" "Username can't be empty"
        else
            if id $user > /dev/null 2>&1
            then

                locked=$(cat /etc/shadow | grep $user | grep !)

                if [ -z $locked ];then
                    Info "Info" "User $user not locked"
                else
                    passwd -u $user
                    Info "Info" "User $user unlocked"
                    logthis "User $user unlocked"
                fi
                space
                return 0
            else
                Error "Error" "User $user does not found!"
                space
            fi
        fi
    done
}

list_locked_users() {
    cat /etc/shadow | grep '!'
}

backup_user() {
    space
    while :
    do
        printf "Enter user name: " 
        read user
        if [ -z $user ]
        then
            Error "Error" "Username can't be empty"
        else
            if id $user > /dev/null 2>&1
            then
                check_bkp_folder
                homedir=$(grep ${user}: /etc/passwd | cut -d ":" -f 6)
                Info "Info" "Home directory for $user is $homedir "
                Info "Info" "Creating..."
                ts=$(date +%F)
                tar -zcvf $BACKUPS/${user}-${ts}.tar.gz $homedir
                Info "Info" "Backup for $user created with name ${user}-${ts}.tar.gz"
                space
                return 0
            else
                Error "Error" "User $user does not found!"
                space
                return 1
            fi
        fi
    done
}

generate_ssh_key() {
    space
    while :
    do
        printf "Enter user name: " 
        read user
        if [ -z $user ]
        then
            Error "Error" "Username can't be empty"
        else
            if id $user > /dev/null 2>&1
            then
                sshf="/home/$user/.ssh"
                if [ ! -d "$sshf" ];then
                    mkdir -p $sshf
                    chown $user:$user $sshf
                    chmod 700 $sshf
                fi

                su - $user -c "ssh-keygen -t rsa -b 4096 -C '${user}@local' -f ~/.ssh/id_rsa_${user} -N ''"
                space
                Info "Info" "User PUB key:"
                space
                su - $user -c "cat ~/.ssh/id_rsa_${user}.pub" 
                space
                logthis "User $user ssh key is created - id_rsa_$user"
                return 0
            else
                Error "Error" "User $user does not found!"
                space
                return 1
            fi
        fi
    done
}

delete_user() {
    space
    while :
    do
        printf "Enter user name: " 
        read user
        if [ -z $user ]
        then
            Error "Error" "Username can't be empty"
        else
            if id $user > /dev/null 2>&1
            then
                
                if confirm "Completely delete user (y/n or press enter for n)";then
                    userdel -r -f $user
                    if [ -f /etc/sudoers.d/$user ];then
                        rm -rf /etc/sudoers.d/$user
                    fi
                    
                    Info "Info" "User $user deleted"
                    space
                fi
                return 0
            else
                Error "Error" "User $user does not found!"
                space
                return 1
            fi
        fi
    done
}

promote_user() {
    space
    while :
    do
        printf "Enter user name: " 
        read user
        if [ -z $user ]
        then
            Error "Error" "Username can't be empty"
        else
            if id $user > /dev/null 2>&1
            then
                
                if id $user | grep wheel > /dev/null 2>&1
                then
                    Info "Info" "User already promoted to wheel group"
                    space
                else
                    usermod -aG wheel $user
                    echo "%$user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$user
                    logthis "User $user promoted to wheel"
                    Info "Info" "User promoted to wheel group"
                    space
                fi
                return 0
            else
                Error "Error" "User $user does not found!"
                space
                return 1
            fi
        fi
    done
}

degrate_user() {
    space
    while :
    do
        printf "Enter user name: " 
        read user
        if [ -z $user ]
        then
            Error "Error" "Username can't be empty"
        else
            if id $user > /dev/null 2>&1
            then
                
                if id $user | grep wheel > /dev/null 2>&1
                then
                    Info "Info" "User already promoted to wheel group. Degrating..."
                    gpasswd -d $user wheel
                    rm -rf /etc/sudoers.d/$user
                    space
                else
                    Info "Info" "User not promoted to wheel group"
                    space
                fi
                return 0
            else
                Error "Error" "User $user does not found!"
                space
                return 1
            fi
        fi
    done
}

# Actions
# ---------------------------------------------------\
isRoot
checkDistro

# User menu rotator
  while true
    do
        PS3='Please enter your choice: '
        options="
        'Create new user'
        'List users'
        'Reset password for user'
        'Lock user'
        'Unlock user'
        'List all locked users'
        'Backup user'
        'Generate SSH key for user'
        'Promote user to admin'
        'Degrate user from admin'
        'Delete user'
        'Quit'
        "
        select opt in ${options}
        do
         case $opt in
            "Create new user")
                create_user
                break
                ;;
            "List users")
                list_users
                break
                ;;
            "Reset password for user")
                reset_password
                break
                ;;
            "Lock user")
                lock_user
                break
                ;;
            "Unlock user")
                unlock_user
                break
                ;;
            "List all locked users")
                list_locked_users
                break
                ;;
            "Backup user")
                backup_user
                break
                ;;
            "Generate SSH key for user")
                generate_ssh_key
                break
                ;;     
            "Delete user")
                delete_user
                break
                ;;
            "Promote user to admin")
                 promote_user
                 break
             ;;
            "Degrate user from admin")
                 degrate_user
                 break
            ;;
            "Quit")
                 Info "Exit" "Bye"
                 exit
             ;;
            *) echo invalid option;;
         esac
    done
   done
