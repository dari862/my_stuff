#!/bin/sh
set -ex

exec supervisord -c /app/supervisord.conf
