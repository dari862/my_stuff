#!/bin/bash
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Requires:
##          jq
##          API Key from http://openweathermap.org/api
##
## USAGE: Call this script from Conky with ( replace "<t>" with the update interval)
##          ${execpi <t> /path/to/my_stuff_weather.sh [location]}

. "/usr/share/my_stuff/lib/common/API"

#### User configurables:  ##############################################

# Either set the location manually here, or by passing it as a script parameter in the Conky.
# "yourlocation" must be a name (which doesn't have spaces), or a numeric id.
#
# id's can be obtained from http://bulk.openweathermap.org/sample/city.list.json.gz
# Download and extract the json file, then simply search for an id with grep.
#   For example:   grep "New York" city.list.json
#
# If $place is not set, then the script attempts to get a geolocation from the IP address.

place="1716924"
#place="yourlocation"   # Uncomment and add name or id. NB If the name has spaces, then you must use the id.

# Choose fahrenheit/Imperial or Celcius/metric:
#units='imperial'
units='metric'

lang="" 
	
#########################################################################
__opt="${1-}"
scaleT=""
scaleV=""
WEATHER_INFO=""
api_prefix="api.openweathermap.org/data/2.5/"
appid=$(cat "${API_path}/${weather}" || :)

get_weather_report_less(){
	__opt_for_less="${1-}"
	ICON_SUNNY="  Clear"
	ICON_CLOUDY="  Cloudy"
	ICON_RAINY="  Rainy"
	ICON_STORM="  Storm"
	ICON_SNOW="  Snow"
	ICON_FOG="  Fog"
	ICON_MISC=" "
	
	TEXT_SUNNY="Clear"
	TEXT_CLOUDY="Cloudy"
	TEXT_RAINY="Rainy"
	TEXT_STORM="Storm"
	TEXT_SNOW="Snow"
	TEXT_FOG="Fog"
	
	WEATHER_MAIN=$(echo "${WEATHER_INFO}" | grep -o -e '\"main\":\"[a-Z]*\"' | awk -F ':' '{print $2}' | tr -d '"')
	WEATHER_TEMP=$(echo "${WEATHER_INFO}" | grep -o -e '\"temp\":\-\?[0-9]*' | awk -F ':' '{print $2}' | tr -d '"')
	
	if [[ "${WEATHER_MAIN}" = *Snow* ]]; then
		if  [[ "${__opt_for_less}" = "-i" ]]; then
    		echo "${ICON_SNOW} ${WEATHER_TEMP}${scaleT}"
    	elif  [[ "${__opt_for_less}" = "-t" ]]; then
    		echo "If You go outside, don't forget to bring your jacket"
		else
    		echo "${TEXT_SNOW} ${WEATHER_TEMP}${scaleT}"
		fi
	elif [[ "${WEATHER_MAIN}" = *Rain* ]] || [[ "${WEATHER_MAIN}" = *Drizzle* ]]; then
		if  [[ "${__opt_for_less}" = "-i" ]]; then
    		echo "${ICON_RAINY} ${WEATHER_TEMP}${scaleT}"
    	elif  [[ "${__opt_for_less}" = "-t" ]]; then
    		echo "If You go outside, don't forget to bring your umbrella"
		else
    		echo "${TEXT_RAINY} ${WEATHER_TEMP}${scaleT}"
		fi
	elif [[ "${WEATHER_MAIN}" = *Cloud* ]]; then
		if  [[ "${__opt_for_less}" = "-i" ]]; then
    		echo "${ICON_CLOUDY} ${WEATHER_TEMP}${scaleT}"
    	elif  [[ "${__opt_for_less}" = "-t" ]]; then
    		echo "A perfect weather to play outside"
		else
    		echo "${TEXT_CLOUDY} ${WEATHER_TEMP}${scaleT}"
		fi
	elif [[ "${WEATHER_MAIN}" = *Clear* ]]; then
		if  [[ "${__opt_for_less}" = "-i" ]]; then
    		echo "${ICON_SUNNY} ${WEATHER_TEMP}${scaleT}"
    	elif  [[ "${__opt_for_less}" = "-t" ]]; then
    		echo "If You go outside, don't forget to bring your hat"
		else
    		echo "${TEXT_SUNNY} ${WEATHER_TEMP}${scaleT}"
		fi
	elif [[ "${WEATHER_MAIN}" = *Fog* ]] || [[ "${WEATHER_MAIN}" = *Mist* ]]; then
		if  [[ "${__opt_for_less}" = "-i" ]]; then
    		echo "${ICON_FOG} ${WEATHER_TEMP}${scaleT}"
    	elif  [[ "${__opt_for_less}" = "-t" ]]; then
    		echo "If You want to go, don't forget to check your headlamp"
		else
    		echo "${TEXT_FOG} ${WEATHER_TEMP}${scaleT}"
		fi
	else
		if  [[ "${__opt_for_less}" = "-i" ]]; then
    		echo "${ICON_MISC} ${WEATHER_MAIN} ${WEATHER_TEMP}${scaleT}"
    	elif  [[ "${__opt_for_less}" = "-t" ]]; then
    		echo "The Weather is unknown"
		else
    		echo "${WEATHER_MAIN} ${WEATHER_TEMP}${scaleT}"
		fi	
	fi
}

get_weather_report_more(){       
        city=$(echo "$WEATHER_INFO" | jq -r '.name') # In case location has spaces in the name
        weather_desc=$(echo "$WEATHER_INFO" | jq -r '.weather[0].description')   # In case description has spaces in the name

        # load values into array:
        all=($(echo "$WEATHER_INFO" | jq -r '.coord.lon,.coord.lat,.weather[0].main,.main.temp,.main.pressure,.main.temp_min,.main.temp_max,.wind.speed,.wind.deg,.clouds.all,.sys.sunrise,.sys.sunset,.main.humidity'))
        #                   ARRAY INDEX  0          1          2                3          4              5              6              7           8         9           10           11          12

        longitude=$(printf '%06.1f' ${all[0]})
        latitude=$(printf '%+.1f' ${all[1]})
        condition="${all[2]}"
        temperature=$(printf '%+.1f%s' ${all[3]} $scaleT)
        pressure=$(printf '%.f %s' ${all[4]} mb)
        temperature_min=$(printf '%+.1f%s' ${all[5]} $scaleT)
        temperature_max=$(printf '%+.1f%s' ${all[6]} $scaleT)
        windspeed=$(printf '%.1f %s' ${all[7]} $scaleV)
        winddir=$(printf '%3.f%s' ${all[8]} °)
        cloud_cover=$(printf '%d%s' ${all[9]} %)
        sunrise=$(date -d @${all[10]} +"%R")
        sunset=$(date -d @${all[11]} +"%R")
        humidity="${all[12]}%"
        description="$weather_desc"

        #Example format for output:
        #printf "%s; %s; %s %s" "$city" "$temperature" "$windspeed" "$winddir"
        printf "%s: %s\nTemp: %s\nHumidity: %s\n" "$city" "$description" "$temperature" "$humidity"
}

connectiontest() {
    local -i i attempts=${1-0}
    for (( i=0; i < attempts || attempts == 0; i++ )); do
        if wget -O - 'http://ftp.debian.org/debian/README' &> /dev/null; then
            return 0
        fi
        if (( i == attempts - 1 )); then # if last attempt
            return 1
        fi
    done
}

placeholder() {
    if (( $1 == 1 )) &>/dev/null;then
        echo "No internet connection"
        echo "Weather information unavailable"
    else
        echo "No API key"
        echo "Weather information unavailable"
        echo "Get API KEY by registering for one at http://openweathermap.org/api"
        echo "And save it at ${API_path}/."
    fi
}

get_json_data_(){
	if [[ -z $place ]] &>/dev/null;then
        # Geolocate IP:
        latlong=$(get_scripts --latlong)
        # Parse the latitude and longitude
        lat=${latlong%,*}
        long=${latlong#*,}
        id="lat=$lat&lon=$long"
    else
        # check if numeric id, or placename is being used
        [[ ${place##*[!0-9]*} ]] &>/dev/null && id="id=$place" || id="q=$place"
    fi
	appid="APPID=$appid"
	units="&units=$units"
	if [[ -n "${lang}" ]];then
		lang="&lang=$lang"
	fi
	
	WEATHER_URL="${api_prefix}weather?${appid}${id}${units}${lang}"
	
	if command -v wget &>/dev/null;then
		WEATHER_INFO=$(wget -qO- "${WEATHER_URL}")
	else
		WEATHER_INFO=$(curl -s "${WEATHER_URL}")
	fi
}

if [[ -z "$appid" ]] &>/dev/null;then
    placeholder 0 && exit 1
else
    connectiontest 10  
    if (( $? == 0 )) &>/dev/null;then
    	if [[ $units == metric ]] &>/dev/null;then
    		scaleT="°C"
    		scaleV="m/s"
		else
    		scaleT="°F"
    		scaleV="mph"
		fi
        # get json data from openweathermap:
        get_json_data_
        if [[ "$__opt" == "-m" ]] &>/dev/null;then
			get_weather_report_more
		else
			get_weather_report_less ${__opt}
		fi
    else
        placeholder 1
    fi
fi

exit
