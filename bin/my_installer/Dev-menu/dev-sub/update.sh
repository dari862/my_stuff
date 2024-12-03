run_ascii_art
CHOICES=(
	"Ollama        Run LLMs, like Meta's Llama3, locally"
	"LazyGit       TUI for Git"
	"LazyDocker    TUI for Docker"
	"Neovim        Text editor that runs in the terminal"
	"Zellij        Adds panes, tabs, and sessions to the terminal"
	"<< Back       "
)
echo "Update manually-managed applications"
bash_active_select -i "${CHOICES[@]}"
CHOICE=$(echo "${CHOICES[${UI_WIDGET_RC}]}" | tr '[:upper:]' '[:lower:]')
if [[ "$CHOICE" == "<< Back"* ]] || [[ -z "$CHOICE" ]]; then
	# Don't update anything
	echo ""
else
	INSTALLER=$(echo "$CHOICE" | awk -F '   ' '{print $1}' | tr '[:upper:]' '[:lower:]')
	source "$DEV_PATH/install/app-$INSTALLER.sh" && echo "Update completed!" && sleep 3
fi

clear
source $DEV_PATH/Dev-menu
