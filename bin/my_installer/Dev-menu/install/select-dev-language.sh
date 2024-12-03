# Install default programming languages
if [[ -v OMAKUB_FIRST_RUN_LANGUAGES ]]; then
	languages=$OMAKUB_FIRST_RUN_LANGUAGES
else
	AVAILABLE_LANGUAGES=("Ruby on Rails" "Node.js" "Go" "PHP" "Python" "Elixir" "Rust" "Java")
	echo "Select programming languages"
	bash_active_select -i "${AVAILABLE_LANGUAGES[@]}"
	languages=$(echo "${AVAILABLE_LANGUAGES[${UI_WIDGET_RC}]}")
fi

if [[ -n "$languages" ]]; then
	for language in $languages; do
		case $language in
		Ruby)
			my-installer --install-needed ruby
			;;
		Node.js)
			my-installer --install-needed node
			;;
		Go)
			my-installer --install-needed go
			;;
		PHP)
			my-installer --install-needed php
			;;
		Python)
			my-installer --install-needed python
			;;
		Elixir)
			my-installer --install-needed elixir
			;;
		Rust)
			my-installer --install-needed rust
			;;
		Java)
			my-installer --install-needed java
			;;
		esac
	done
fi
