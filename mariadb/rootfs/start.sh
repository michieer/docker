#!/bin/bash

LOGFILE="/var/log/messages"

exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
