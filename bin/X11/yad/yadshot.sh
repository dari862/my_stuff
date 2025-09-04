#!/bin/bash
# if this line exist script will be part of gui scripts.new_name=Yad_ScreenShot
# if this line exist script will be part of hub script.

# Dependencies: coreutils, yad
# need atleast one: slop, imagemagick, miam
# optional: xclip, grabc (for use with color picker)

. "$__distro_path_lib"
. "${__distro_path_root}/lib/common/WM"
# export running directory variables for use later
export YADSHOT_PATH="$(readlink -f $0)"
export RUNNING_DIR="$(dirname ${YADSHOT_PATH})"
if [ -f "${__distro_path_root}/icons/yadshot.svg" ];then
    export ICON_PATH="${__distro_path_root}/icons/yadshot.svg"
else
    export ICON_PATH="gtk-fullscreen"
fi

# check for dependencies
if ! type ffmpeg >/dev/null 2>&1;then
    MISSING_DEPS="TRUE"
    echo "$(tput setaf 1)ffmpeg not installed!$(tput sgr0)"
fi

if ! type yad >/dev/null 2>&1;then
    MISSING_DEPS="TRUE"
    echo "$(tput setaf 1)yad is not installed!$(tput sgr0)"
fi

if [ "$MISSING_DEPS" = "TRUE" ];then
    echo "$(tput setaf 1)Missing one or more packages required to run; exiting...$(tput sgr0)"
    exit 1
fi

if ! type xclip >/dev/null 2>&1;then
	export Xclip_installed=TRUE
fi

if ! type slop >/dev/null 2>&1;then
	export Slop_installed=TRUE
fi

# set default variables
SELECTION="TRUE"
if [ "$Xclip_installed" = "TRUE" ];then
    COPYONCAP="TRUE"
else
	COPYONCAP="FALSE"
fi

if [ "$Slop_installed" = "TRUE" ];then
    DECORATIONS="TRUE"
else
	DECORATIONS="FALSE"
fi

SS_DELAY=0
# source yadshot config file
if [ -f "${script_config_path}/yadshot.conf" ];then
	. "${script_config_path}/yadshot.conf"
else
	mkdir -p "${script_config_path}"
    echo "SELECTION="\"$SELECTION\""" > "${script_config_path}/yadshot.conf"
    echo "DECORATIONS="\"$DECORATIONS\""" >> "${script_config_path}/yadshot.conf"
    echo "SS_DELAY="\"$SS_DELAY\""" >> "${script_config_path}/yadshot.conf"
	. "${script_config_path}/yadshot.conf"
fi
# create ~/Pictures if it does not exist
if [ ! -d "$HOME/Pictures" ];then
    mkdir -p "$HOME"/Pictures
fi
# capture screenshot.
function yadshotcapture() {
	SS_NAME="yadshot-$(date +'%s').png"

	. "${script_config_path}/yadshot.conf"
	
	if [[ "$SELECTION" = TRUE ]];then 
		SELECTION_arg="--area"
	else
		SELECTION_arg="--full"
	fi
	
	if [[ "$DECORATIONS" = TRUE ]];then
		DECORATIONS_arg="--DECORATIONS"
	else
		DECORATIONS_arg=""
	fi
	
	if [[ "$COPYONCAP" = TRUE ]];then 
		COPYONCAP_arg=""
	else
		COPYONCAP_arg="--no-copy"
	fi
	
	my-shots "$DECORATIONS_arg" "$SELECTION_arg" --delay "$SS_DELAY" --path "/tmp/$USER" --name "${SS_NAME}" --no-view "$COPYONCAP_arg"
	displayss "${SS_NAME}"
}
export -f yadshotcapture

# display screenshot; resize it first if it's too large to be displayed on user's screen
function displayss() {
	SS_NAME="${1-}"
    . "${script_config_path}/yadshot.conf"
    if [ ! -f "/tmp/$USER/$SS_NAME" ];then
        echo "Failed to capture screenshot!" | yad --window-icon="$ICON_PATH" --center --height=200 --width=300 --borders=10 --text-info --wrap --title="yadshot" --button="OK!gtk-ok!OK:0"
        exit 1
    fi
    if [ "$COPYONCAP" = "TRUE" ];then
        xclip -selection clipboard -t image/png -i < /tmp/$USER/"$SS_NAME"
    fi
    WSCREEN_RES=$(xrandr | grep 'current' | cut -f2 -d"," | sed 's:current ::g' | cut -f2 -d" " | awk '{print $1 * .75}' | cut -f1 -d'.')
    HSCREEN_RES=$(xrandr | grep 'current' | cut -f2 -d"," | sed 's:current ::g' | cut -f4 -d" " | awk '{print $1 * .75}' | cut -f1 -d'.')
    WSIZE=$(file /tmp/$USER/$SS_NAME | cut -f2 -d"," | cut -f2 -d" " | cut -f1 -d'.')
    HSIZE=$(file /tmp/$USER/$SS_NAME | cut -f2 -d"," | cut -f4 -d" " | cut -f1 -d'.')
    WSIZEYAD=$(($WSIZE+75))
    HSIZEYAD=$(($HSIZE+75))
    yad_opts=()
    yad_opts+=(--window-icon="$ICON_PATH" --center --picture)
    if [ "$WSCREEN_RES" -le "$WSIZE" ] || [ "$HSCREEN_RES" -le "$HSIZE" ];then
    	yad_opts+=(--size=fit --width=$WSCREEN_RES --height=$HSCREEN_RES)
    else
    	yad_opts+=(--size=orig --width=$WSIZEYAD --height=$HSIZEYAD)
    fi
    yad_opts+=(--no-escape --filename="/tmp/$USER/$SS_NAME" --image-on-top --buttons-layout="edge" --title="yadshot" --separator="," --borders="10"
               --button="Close!gtk-cancel!Close:1" --button="Main Menu!gtk-home!Main Menu:2")
	if [ "$Xclip_installed" = "TRUE" ];then
    	yad_opts+=(--button="Copy to Clipboard!gtk-paste:3")
    fi
    yad_opts+=(--button="Upload to Filebin!gtk-go-up!Upload to Filebin:4" --button="Save!gtk-save!Save:5" --button="New Screenshot!gtk-new!New Screenshot:0")
    yad "${yad_opts[@]}"
    BUTTON_PRESSED="$?"
    case $BUTTON_PRESSED in
        1)
            rm -f /tmp/$USER/"$SS_NAME"
            exit 0
            ;;
        2)
            $0
            ;;
        3)
            xclip -selection clipboard -t image/png -i < /tmp/$USER/"$SS_NAME"
            displayss "$SS_NAME"
            ;;
        4)
            FILE="$HOME/Pictures/$SS_NAME"
            cp /tmp/$USER/"$SS_NAME" "$FILE"
            # upload screenshots and files to Filebin.net; set FAILED=1 if upload fails
    		echo -n "" | xclip -i -selection clipboard
    		files-uploader --filebiner up -f "$FILE"
    		FILE_URL="$(xclip -o -selection clipboard)"
    		if [[ -z "$FILE_URL" ]];then
        		echo 'error uploading file!\n'
        		FAILED=1
        		yad --window-icon="$ICON_PATH" --center --error --title="yadshot" --text="Failed to upload '$FILE'!"
    		else
        		FAILED=0
        		echo "$FILE_URL" | yad --window-icon="$ICON_PATH" --center --height=200 --width=300 --borders=20 --text-info --wrap --show-uri --uri-color="yellow" --title="yadshot" --button="Back!gtk-ok!OK:0" --button="Close!gtk-cancel!Close:1"
    		fi
            displayss "$SS_NAME"
            ;;
        5)
            SAVE_DIR=$(yad --window-icon="$ICON_PATH" --center --file --save --confirm-overwrite --title="yadshot" --width=800 --height=600 --text="Save $SS_NAME as...")
            cp /tmp/$USER/"$SS_NAME" "$SAVE_DIR"
            displayss "$SS_NAME"
            ;;
        0)
            rm -f /tmp/$USER/"$SS_NAME"
            yadshotcapture
            ;;
    esac
    exit 0
}
export -f displayss
# upload clipboard to Filebin.net
function yadshotpaste() {
    echo -e "$(xclip -o -selection clipboard)" > /tmp/$USER/yadshotpaste.txt
    PASTE_CONTENT="$(yad --window-icon="$ICON_PATH" --center --title="yadshot" --height=600 --width=800 --text-info --wrap --filename="/tmp/$USER/yadshotpaste.txt" --editable --borders="10" --button="Cancel!gtk-cancel!Cancel:1" --button="Ok!gtk-ok!OK:0")"
    case $? in
        0)
            echo -e "$PASTE_CONTENT" > /tmp/$USER/yadshotpaste.txt
            ;;
        *)
            rm -f /tmp/$USER/yadshotpaste.txt
            exit 0
            ;;
    esac
    echo -n "" | xclip -i -selection clipboard
    files-uploader --filebiner up -f /tmp/$USER/yadshotpaste.txt
    PASTE_URL="$(xclip -o -selection clipboard)"
    rm -f /tmp/$USER/yadshotpaste.txt
    if [[ -z "$PASTE_URL" ]];then
        echo "Failed to upload paste!"| yad --window-icon="$ICON_PATH" --center --height=200 --width=300 --borders=20 --text-info --wrap --title="yadshot" --button="OK!gtk-ok!OK:0"
        exit 1
    else
        echo "$PASTE_URL" | yad --window-icon="$ICON_PATH" --center --height=200 --width=300 --borders=20 --text-info --wrap --show-uri --uri-color="yellow" --title="yadshot" --button="OK!gtk-ok!OK:0"
    fi
}
export -f yadshotpaste
# select a file to upload to Filebin.net
function yadshotfileselect() {
    FILE="$(yad --window-icon="$ICON_PATH" --file $PWD --center --add-preview --title=yadshot --height 600 --width 800)"
    case $? in
        0)
            # upload screenshots and files to Filebin.net; set FAILED=1 if upload fails
    		echo -n "" | xclip -i -selection clipboard
    		files-uploader --filebiner up -f "$FILE"
    		FILE_URL="$(xclip -o -selection clipboard)"
    		if [[ -z "$FILE_URL" ]];then
        		echo 'error uploading file!\n'
        		FAILED=1
        		yad --window-icon="$ICON_PATH" --center --error --title="yadshot" --text="Failed to upload '$FILE'!"
    		else
        		FAILED=0
        		echo "$FILE_URL" | yad --window-icon="$ICON_PATH" --center --height=200 --width=300 --borders=20 --text-info --wrap --show-uri --uri-color="yellow" --title="yadshot" --button="Back!gtk-ok!OK:0" --button="Close!gtk-cancel!Close:1"
    		fi
            ;;
        *)
            exit 0
            ;;
    esac
}
export -f yadshotfileselect

# function to view upload list from tray
function upload_list() {
    LIST_ITEM="$(files-uploader --filebiner ls | tail -n +2 | yad --window-icon="$ICON_PATH" --borders=10 --center --list --height 600 --width 800 --title="yadshot" --text="\nDouble click an item to copy it to the clipboard." --dclick-action="bash -c 'echo -n %s | xclip -i -selection clipboard'" --separator="" --column="Uploads" --button="Delete Selected!gtk-delete!Delete Selected:0" --button="Close!gtk-cancel!Close:1")"
    case $? in
        1)
            sleep 0
            ;;
        0)
            local FILE_NAME="$(echo "$LIST_ITEM" | rev | cut -f2- -d'?' | cut -f1 -d'/' | rev)"
            filebiner -y rm -n "$FILE_NAME"
            case $? in
                1) echo "Failed to remove '$FILE_NAME' from Filebin!" | yad --window-icon="$ICON_PATH" --borders=20 --center --text-info --wrap --title="yadshot" --button="OK!gtk-ok!OK:0";;
                0) echo "'$FILE_NAME' has been removed from Filebin!" | yad --window-icon="$ICON_PATH" --borders=20 --center --text-info --wrap --title="yadshot" --button="OK!gtk-ok!OK:0";;
            esac
            "$YADSHOT_PATH" -l
            ;;
    esac
}
export -f upload_list
# function for launching color picker from tray
yadcolorpicker(){
	if type grabc > /dev/null 2>&1;then
		COLOR_SELECTION="$(yad --window-icon="$ICON_PATH" --center --title="yadshot" --color --init-color="$(grabc | head -n 1)" --mode=hex)"
	else
		COLOR_SELECTION="$(yad --window-icon="$ICON_PATH" --center --title="yadshot" --color --mode=hex)"
	fi
	case $? in
		0)
			echo -n "$COLOR_SELECTION" | xclip -i -selection clipboard
			exit 0
		;;
		*)
			exit 0
		;;
	esac
}
export -f yadcolorpicker
# add handler to manage process shutdown
function on_exit() {
    echo "quit" >&3
    rm -f $PIPE
    exit 0
}
export -f on_exit
# create the notification icon
function yadshottray() {
    trap on_exit EXIT
    # create a FIFO file, used to manage the I/O redirection from shell
    PIPE=$(mktemp -u --tmpdir ${0##*/}.XXXXXXXX)
    mkfifo $PIPE
    # attach a file descriptor to the file
    exec 3<> $PIPE
    yad --window-icon="gtk-zoom-fit" --notification --listen --image="gtk-zoom-fit" --text="yadshot" --command="bash -c $YADSHOT_PATH;exit 0" --item-separator="," \
    --menu="New Screenshot,bash -c yadshotcapture,gtk-new|Upload File,bash -c yadshotfileselect;exit 0;exit 0,gtk-go-up|Upload Paste,bash -c yadshotpaste;exit 0;exit 0,gtk-copy|Image Capture and Upload (Imugr),bash -c Imugr_upload -l,gtk-copy|Image Capture and Upload (Imugr) anonymous,bash -c Imugr_upload,gtk-copy|Color Picker,bash -c yadcolorpicker,gtk-color-picker|View Upload List,bash -c upload_list;exit 0,gtk-edit|Settings,bash -c yadshotsettings,gtk-preferences|Quit,quit,gtk-cancel" <&3
}
export -f yadshottray
# save settings to yadshot config dir
function yadshotsavesettings() {
    echo "SELECTION="\"$SELECTION\""" > "${script_config_path}/yadshot.conf"
    echo "DECORATIONS="\"$DECORATIONS\""" >> "${script_config_path}/yadshot.conf"
    echo "COPYONCAP="\"$COPYONCAP\""" >> "${script_config_path}/yadshot.conf"
    echo "SS_DELAY="\"$SS_DELAY\""" >> "${script_config_path}/yadshot.conf"
}
export -f yadshotsavesettings

# change yadshot's settings
function yadshotsettings() {
    . "${script_config_path}/yadshot.conf"
    yad_opts=()
	yad_opts+=(--window-icon="$ICON_PATH" --center --title="yadshot" --height=200 --columns=1 --form --no-escape --item-separator="," --separator="," --borders="10" --field="Capture selection":CHK "$SELECTION" ) 
	if [ "$Slop_installed" = "TRUE" ];then
    	yad_opts+=(--field="Capture decorations":CHK "$DECORATIONS")
	fi
	
	if [ "$Xclip_installed" = "TRUE" ];then
    	yad_opts+=(--field="Copy screenshot to clipboard on capture":CHK "$COPYONCAP")
	fi
	
	yad_opts+=(--field="Delay before capture":NUM "$SS_DELAY!0..120" --button="Back!gtk-ok!OK:0")
	
    OUTPUT="$(yad "${yad_opts[@]}")"
    if [[ "$?" = 0 ]];then
    	SELECTION="$(echo $OUTPUT | cut -f1 -d",")"
    	DECORATIONS="$(echo $OUTPUT | cut -f2 -d",")"
    	COPYONCAP="$(echo $OUTPUT | cut -f3 -d",")"
    	SS_DELAY="$(echo $OUTPUT | cut -f4 -d",")"
    	yadshotsavesettings
    fi
}
export -f yadshotsettings
Imugr_upload(){
	__mode="${1-}"
	. "${script_config_path}/yadshot.conf"
	if [[ "$SELECTION" = TRUE ]];then 
		SELECTION_arg="-s"
	else
		SELECTION_arg="-w"
	fi
	files-uploader --imgur "${__mode}" "${SELECTION_arg}" -d ${SS_DELAY}
}
export -f Imugr_upload
# main yadshot window
function startfunc() {
    yad --window-icon="$ICON_PATH" --center --title="yadshot" --height=200 --width=325 --form --no-escape --separator="" --button-layout="center" \
    --borders="20" --columns="1" --button="New Screenshot!gtk-add!New Screensho:0" --button="Close!gtk-cancel!Close:1" \
    --field="Upload File (filebin.net)!gtk-go-up":FBTN "bash -c yadshotfileselect;exit 0" --field="Upload Paste (filebin.net)!gtk-copy":FBTN "bash -c yadshotpaste;exit 0" \
    --field="Image Capture and Upload (Imugr)!gtk-copy":FBTN "bash -c Imugr_upload -l" --field="Image Capture and Upload (Imugr) anonymous!gtk-copy":FBTN "bash -c Imugr_upload" \
    --field="Color Picker!gtk-color-picker":FBTN "bash -c yadcolorpicker" --field="View Upload List!gtk-edit":FBTN "bash -c upload_list;exit 0" \
    --field="Settings!gtk-preferences":FBTN "bash -c yadshotsettings" --field="Start Tray App!gtk-go-down":FBTN "bash -c yadshottray"
    case $? in
        0)
            yadshotcapture
            ;;
        *)
            exit 0
            ;;
    esac
}

# detect arguments
case $1 in
    -t|--tray)
        yadshottray &
        exit 0
        ;;
    *)
        startfunc
        ;;
esac
