#!/usr/bin/env bash
set -e

CLEAR_TEXT="\033[0m"
DONE_TEXT="\033[0;32m"
SUCCESS_TEXT="\033[1;42;37m"

__SUPERUSER="my-superuser"
BIN_PATH="/usr/local/bin"
SOURCE_PATH="${BIN_PATH}/winapps-src"
APP_PATH="/usr/share/applications"
APPDATA_PATH="/usr/local/share/winapps"

CONFIG_PATH="${HOME}/.config/winapps/winapps.conf"

$__SUPERUSER rm -f "$APP_PATH/ms-office-protocol-handler.desktop"
WINAPPS_DESKTOP_FILES=()
WINAPPS_APP_BASH_SCRIPTS=()
DESKTOP_FILE_NAME=""
BASH_SCRIPT_NAME=""
$__SUPERUSER rm -f "${BIN_PATH}/winapps"
$__SUPERUSER rm -f "${BIN_PATH}/winapps-setup"
$__SUPERUSER rm -rf "$APPDATA_PATH"

readarray -t WINAPPS_DESKTOP_FILES < <(grep -l -d skip "${BIN_PATH}/winapps" "${APP_PATH}/"* 2>/dev/null || true)

for DESKTOP_FILE_PATH in "${WINAPPS_DESKTOP_FILES[@]}"; do
    DESKTOP_FILE_PATH=$(echo "$DESKTOP_FILE_PATH" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    DESKTOP_FILE_NAME=$(basename "$DESKTOP_FILE_PATH" | sed 's/\.[^.]*$//')
    echo -n "Removing '.desktop' file for '${DESKTOP_FILE_NAME}'... "
    $__SUPERUSER rm "$DESKTOP_FILE_PATH"
    echo -e "${DONE_TEXT}Done!${CLEAR_TEXT}"
done

readarray -t WINAPPS_APP_BASH_SCRIPTS < <(grep -l -d skip "${BIN_PATH}/winapps" "${BIN_PATH}/"* 2>/dev/null || true)

for BASH_SCRIPT_PATH in "${WINAPPS_APP_BASH_SCRIPTS[@]}"; do
    BASH_SCRIPT_PATH=$(echo "$BASH_SCRIPT_PATH" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    BASH_SCRIPT_NAME=$(basename "$BASH_SCRIPT_PATH" | sed 's/\.[^.]*$//')
    echo -n "Removing bash script for '${BASH_SCRIPT_NAME}'... "
    $__SUPERUSER rm "$BASH_SCRIPT_PATH"
    echo -e "${DONE_TEXT}Done!${CLEAR_TEXT}"
done
#rm -r $(dirname "$CONFIG_PATH")
#rm -rdf ${SOURCE_PATH}
echo -e "${SUCCESS_TEXT} $OPT_MODE UNINSTALLATION COMPLETE.${CLEAR_TEXT}"

