#!/bin/bash
set -e  # exit on error and unset variables
unalias -a
. "$__distro_path_lib"
"${__distro_path_root}/bin/not_add_2_path"/check_4_dependencies_if_installed openssl || exit 1

# Display usage instructions
usage() {
    echo "Usage:"
    echo "  $0 encrypt <input_file|input_folder> [output_file|output_folder]"
    echo "  $0 decrypt <input_file|input_folder> [output_file|output_folder]"
    exit 1
}

die() {
    printf 'error: %s.\n' "$1" >&2
    exit 1
}

sread() {
    printf '%s: ' "$2"
    stty -echo
    read -r "$1"
    stty echo
    printf '\n'
}

get_password() {
	while :; do
		sread password  "Enter ${mode}sion password"
		[ "$mode" = "decrypt" ] && break
		sread password2 "Enter password (again)"
		[ "$password" = "$password2" ] && break || echo "Passwords do not match. Try again."
	done
	unset password2
}

# Process files/folders securely with OpenSSL
process_openssl() {
    input=$2
    output=$3

	get_password

    openssl_cmd="openssl enc -aes-256-cbc -pbkdf2"
    [ "$mode" = "encrypt" ] && openssl_cmd="$openssl_cmd -salt"
    [ "$mode" = "decrypt" ] && openssl_cmd="$openssl_cmd -d"

    if [ -d "$input" ]; then
        [ -z "$output" ] && output="${input}_${mode}ed"
        find "$input" -type f | while IFS= read -r file; do
            rel_path=${file#"$input"/}
            out_file="$output/$rel_path"
            [ "$mode" = "encrypt" ] && out_file="$out_file.enc" || out_file=${out_file%.enc}
            mkdir -p "$(dirname "$out_file")"

            if printf "%s" "$password" | $openssl_cmd -in "$file" -out "$out_file" -pass stdin; then
                echo "${mode^}ed: $out_file"
            else
                echo "Failed to $mode: $file" >&2
            fi
        done
    else
        [ -z "$output" ] && {
            output="$input"
            [ "$mode" = "encrypt" ] && output="$input.enc" || output=${input%.enc}
        }
        [ -d "$output" ] && {
            echo "Error: Output must be a file when processing a single file." >&2
            exit 1
        }
        mkdir -p "$(dirname "$output")"

        if printf "%s" "$password" | $openssl_cmd -in "$input" -out "$output" -pass stdin; then
            echo "${mode^}ed: $output"
        else
            echo "Failed to $mode: $input" >&2
        fi
    fi
}

[ $# -lt 2 ] && usage

command=$1
input=$2
output=${3:-}

case "$command" in
    e*)
		mode="encrypt"
        process_openssl "$command" "$input" "$output"
        ;;
    d*)
		mode="decrypt"
        process_openssl "$command" "$input" "$output"
        ;;
    *)
        usage
        ;;
esac
