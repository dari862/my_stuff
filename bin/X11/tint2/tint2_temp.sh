#!/usr/bin/env sh
TEMP_DEV='thermal_zone0'
TEMPERATURE_DEVICE="/sys/class/thermal/${TEMP_DEV}/temp"
cat "$thermal_zone0" | awk '{print $1/1000 "°C"}'  || echo "Invalid ${TEMPERATURE_DEVICE} interface!"
