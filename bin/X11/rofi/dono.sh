#!/bin/bash
# if this line exist script will be part of hub script.

set -e
. "/usr/share/my_stuff/lib/common/WM"
. "${Distro_config_file}"

opt="${1-h}"

HELP_List="1 Note_manager
2 Todo_Creater
3 Todo_list"

notes_and_todo_folder="$HOME/Documents/dono"
todo_folder="$notes_and_todo_folder/Todo"
todo_file="${todo_folder}/Todo.txt"

done_symbol="✔️"

#############################################################################
#############################################################################
# Note_manager
#############################################################################
#############################################################################

notes_folder="$notes_and_todo_folder/notes"
AUTHOR="$USER"

get_notes() {
    ls "${notes_folder}"
}

create_note() {
	file=$(echo "$title" | sed 's/ /_/g;s/\(.*\)/\L\1/g')
	template=$(cat <<- END
---
title: $title
date: $(date --rfc-3339=seconds)
author: $AUTHOR
---

# $title
END
            )
	
	note_location="$notes_folder/$file.md"
	if [ "$title" != "" ];then
		echo "$template" > "$note_location"	
		edit_note "$note_location"
	fi
}

edit_note() {
    note_location=$1
    popup_terminal --editor "$note_location"
}

delete_note() {
    note=$1
    action=$(echo -e "Yes\nNo" | rofi -no-config -no-lazy-grab -dmenu -r -i -l 20 -theme "$HOME/.config/rofi/$ROFI_STYLE"/runner.rasi -p "Are you sure you want to delete $note? ")

    case $action in
        "Yes")
            [ -d "notes_folder" ] && rm "$notes_folder/$note"
            Note_manager
            ;;
        "No")
            Note_manager
    esac
}

note_context() {
    note=$1
    note_location="$notes_folder/$note"
    if [ -f "$note_location" ]
    then
    	action=$(echo -e "Edit\nDelete" | rofi -no-config -no-lazy-grab -dmenu -r -i -l 20 -theme "$HOME/.config/rofi/$ROFI_STYLE"/runner.rasi -p "$note > ")
    	case $action in
			"Edit")
            	edit_note "$note_location"
            	;;
        	"Delete")
            	delete_note "$note"
	
    	esac
    else
    	new_note "$note"
    fi
}

new_note() {
	if [ "$note_option" = "New" ]
	then
		title=$(echo -e "Cancel" | rofi -no-config -no-lazy-grab -dmenu -r -i -l 20 -theme "$HOME/.config/rofi/$ROFI_STYLE"/runner.rasi -p "Input title: ")
    	case "$title" in
        	"Cancel")
            	Note_manager
            	;;
        	*)
        		create_note
            	;;
    	esac
    else
    	title="$1"
    	create_note
    fi
}

Note_manager()
{
	[ ! -d "$notes_folder" ] && mkdir -p "$notes_folder"
	
	all_notes="$(get_notes)"
	first_menu="New"
	if [ "$all_notes" ];then
		first_menu="New\n${all_notes}"
	fi
	note_option=$(echo -e "$first_menu"  | rofi -no-config -no-lazy-grab -dmenu -r -i -l 20 -theme "$HOME/.config/rofi/$ROFI_STYLE"/runner.rasi -p "Note: ")
	case $note_option in
		"New")
			new_note
			;;
		"")
			;;
		*)
			note_context "$note_option"
	esac
	
}

#############################################################################
#############################################################################
# Todo_Creater
#############################################################################
#############################################################################
# Function to copy to clipboard with different tools depending on the display server
cp2cb() {
  case "$XDG_SESSION_TYPE" in
    'x11') xclip -r -selection clipboard;;
    'wayland') wl-copy -n;; 
    *) err "Unknown display server";; 
  esac
}

# Description: Store multiple one-line texts or codes and copy one of them when needed.
Todo_Creater() {
  [ ! -f "$todo_file" ] && mkdir -p "$todo_folder" && touch "$todo_file"
  while :
  do
  	# Picking our options.
  	choice=$(printf 'Copy note\nNew note\nDelete note\nQuit' | rofi -no-config -no-lazy-grab -dmenu -r -i -l 20 -theme "$HOME/.config/rofi/$ROFI_STYLE"/runner.rasi -p 'Notes:' "$@")
	
  	# Choose what we should do with our choice.
  	case "$choice" in
    	'Copy note')
      	# shellcheck disable=SC2154
      	note_pick=$(rofi -no-config -no-lazy-grab -dmenu -r -i -l 20 -theme "$HOME/.config/rofi/$ROFI_STYLE"/runner.rasi -p 'Copy:' "$@" < "${todo_file}")
      	[ -n "${note_pick}" ] && echo "${note_pick}" | cp2cb 
      	;;
    	'New note')
      	note_new=$(echo "" | rofi -no-config -no-lazy-grab -dmenu -r -i -l 20 -theme "$HOME/.config/rofi/$ROFI_STYLE"/runner.rasi -p 'Enter new note:' "$@")
      	# Making sure the input is not empty and not already exist in todo_file.
      	# The sed command should prevent grep from taking certain characters as a regex input.
      	[ -n "$note_new" ] && ! grep -q "^$(echo "${note_new}" | sed -e 's/\[/\\[/g;s/\]/\\]/g')\$" "${todo_file}" &&
      	echo "  ${note_new}" >> "${todo_file}" 
      	;;
    	'Delete note')
      	note_del=$(rofi -no-config -no-lazy-grab -dmenu -r -i -l 20 -theme "$HOME/.config/rofi/$ROFI_STYLE"/runner.rasi -p 'Delete:' "$@" < "${todo_file}")
      	# grep should always returns 0 regardless what happens.
      	grep -v "^$(echo "${note_del}" | sed -e 's/\[/\\[/g;s/\]/\\]/g')\$" "${todo_file}" > "/tmp/$USER/dmnote" || true
      	[ -n "${note_del}" ] && cp -f "/tmp/$USER/dmnote" "${todo_file}"
      	;;
    	'Quit')
      	break
    	;;
  	esac
  done
}

Todo_list()
{
	[ ! -f "${todo_file}" ] && Todo_Creater
	while :
	do
		choice=$(cat "${todo_file}" | rofi -no-config -no-lazy-grab -dmenu -r -i -l 20 -theme "$HOME/.config/rofi/$ROFI_STYLE"/runner.rasi -p 'To Do:' "$@")
		line_number="$(grep -Fxn "$choice" "${todo_file}" | cut -f1 -d:)"
		if [ "$(echo $choice | grep "$done_symbol")" ]
		then
			new_choice="$(echo $choice | sed "s/$done_symbol/  /g")"
		else
			new_choice="$(echo $choice | sed 's/^ *//g' | sed "s/^/$done_symbol/")"
		fi
		sed -i "${line_number}s/$choice/$new_choice/g" ${todo_file}
	done
}
#############################################################################
#############################################################################
# main
#############################################################################
#############################################################################

help()
{
	Chosen_OPT="$(printf '%s\n' "${HELP_List}" | rofi -no-config -no-lazy-grab -dmenu -r -i -l 20 -theme "$HOME/.config/rofi/$ROFI_STYLE"/runner.rasi -p '')"
	opt="$(echo $Chosen_OPT | awk '{ print $1 }')"
	main
}

main()
{
case $opt in
	1) Note_manager ;;
	2) Todo_Creater ;;
	3) Todo_list ;;
	*) help ;;
esac
}
main $opt
