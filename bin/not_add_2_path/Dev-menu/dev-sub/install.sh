run_ascii_art
packages=(
	"1password     Manage your passwords securely across devices"
	"Alacritty     GPU-accelerated terminal emulator focused on performance and simplicity. "
	"Audacity      Record and edit audio"
	"Brave         Chrome-based browser with built-in ad blocking"
	"Doom Emacs    Emacs framework with curated list of packages"
	"Dropbox       Sync files across computers with ease"
	"Flameshot     Take screenshots with many built-in features to save you time."
	"Localsend     File sharing tool that allows you to share files to nearby devices."
	"Neovim        a Vim-based text editor engineered for extensibility and usability,"
	"Obsidian      Personal knowledge base and note-taking software application that operates on Markdown files. "
	"OBS Studio    Record screencasts with inputs from both display + webcam"
	"Ollama        Run LLMs, like Meta's Llama3, locally"
	"Pinta         Bitmap image drawing and editing program inspired by Paint.NET"
	"RubyMine      IntelliJ's commercial Ruby editor"
	"Signal        encrypted messaging service for instant messaging, voice calls, and video calls."
	"Typora        Simple and configurable document editor that provides excellent Markdown support."
	"VirtualBox    Virtual machines to run Windows/Linux"
	"VLC           Multimedia player and framework that plays most multimedia files, and various streaming protocols."
	"VScode        Source-code editor developed by Microsoft for Windows, Linux, macOS and web browsers. "
	"Xournalpp     Note-taking software that is fast, flexible, and functional."
	"Zed           Fast all-purpose editor"
	"Zoom          Attend and host video chat meetings"
)
CHOICES=(
	"Dev Language  Install programming language environment"
	"Dev Database  Install development database in Docker"
)

for package in ${!packages[*]};do
	CHOICES+=("${packages[${package}]}")
done

CHOICES+=(
	"> All         Re-run any of the default installers"
	"<< Back       "
)

echo "Install application"
bash_active_select -i "${CHOICES[@]}"
CHOICE=$(echo "${CHOICES[${UI_WIDGET_RC}]}" | tr '[:upper:]' '[:lower:]')

if [[ "$CHOICE" == "<< back"* ]] || [[ -z "$CHOICE" ]]; then
	# Don't install anything
	echo ""
elif [[ "$CHOICE" == "dev database"* ]]; then
	run_ascii_art
	source "$DEV_PATH/install/select-dev-storage.sh" && echo "Install completed!" && sleep 3
elif [[ "$CHOICE" == "dev language"* ]]; then
	run_ascii_art
	source "$DEV_PATH/install/select-dev-language.sh" && echo "Install completed!" && sleep 3
elif [[ "$CHOICE" == "> all"* ]]; then
	for package in ${!packages[*]};do
		package="${packages[${package}]}"
		INSTALLER=$(echo "$packages" | awk -F '   ' '{print $1}' | tr '[:upper:]' '[:lower:]')
		echo "Do you want to install ${INSTALLER}?" && run_confirmtion && source "$DEV_PATH/install/app-$INSTALLER.sh" && echo "Install completed!" && sleep 3
	done
else
	INSTALLER=$(echo "$CHOICE" | awk -F '   ' '{print $1}' | tr '[:upper:]' '[:lower:]')
	source "$DEV_PATH/install/app-$INSTALLER.sh" && echo "Install completed!" && sleep 3
fi

clear
source $DEV_PATH/Dev-menu
