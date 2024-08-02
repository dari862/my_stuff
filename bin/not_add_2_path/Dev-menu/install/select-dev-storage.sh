# Install default databases
if [[ -v OMAKUB_FIRST_RUN_DBS ]]; then
	dbs=$OMAKUB_FIRST_RUN_DBS
else
	AVAILABLE_DBS=("MySQL" "Redis" "PostgreSQL")
	echo "Select databases (runs in Docker)"
	bash_active_select -i "${AVAILABLE_DBS[@]}"
	dbs=$(echo "${AVAILABLE_DBS[${UI_WIDGET_RC}]}")
fi

if [[ -n "$dbs" ]]; then
	for db in $dbs; do
		case $db in
		MySQL)
			my-installer --container mysql
			;;
		Redis)
			my-installer --container redis
			;;
		PostgreSQL)
			my-installer --container postgres
			;;
		esac
	done
fi
