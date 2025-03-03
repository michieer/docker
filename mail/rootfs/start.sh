#!/bin/bash

# default 
echo "Running Dovecot + Postfix"

mkdir -p /run/dovecot
chmod -R +r /run/dovecot
chmod -R +w /run/dovecot
chmod 750 /run/dovecot/login
chmod 750 /run/dovecot/token-login
chown -R amavis:amavis /var/amavis

if [ -f /var/run/amavis/amavisd.pid ]; then
  rm -f /var/run/amavis/*
fi

if [ -f /var/run/dovecot/master.pid ]; then
  rm /var/run/dovecot/*
fi
if [ -f /var/run/rsyslogd.pid ]; then
  rm /var/run/rsyslogd.pid
fi

if [ -f /var/run/clamav/clamd.ctl ]; then
  rm -f /var/run/clamav/clamd.ctl
fi

if [ -f /var/run/amavis/amavis.pid ]; then
  rm -f /var/run/amavis/*
fi

postmap /etc/postfix/rbl_override

exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
