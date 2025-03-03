#!/bin/bash

LOGFILE="/var/log/messages"

# check if logrotate has run
#if ! grep -Fxq "$LOGFILE" /var/lib/logrotate/status; then
#  logrotate /etc/logrotate.conf
#  service apache2 stop
#  service rsyslog stop
#  service apache2 start
#  service rsyslog start
#fi

# Check if auth.log file exists
if [ ! -f /var/log/auth.log ]; then
  touch /var/log/auth.log
  chown root:adm /var/log/auth.log
fi

# Cleanup fail2ban chains
/beheer/scripts/cleanup-ipt.sh

exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
