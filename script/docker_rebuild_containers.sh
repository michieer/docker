#!/bin/bash

PRE="deb"
VERSION="latest"
NAME=`hostname`

DOCKER_BASE="/share/Docker"
DOCKER_CFG="$DOCKER_BASE/containers"
DOCKER_LOG="$DOCKER_BASE/mgmt/log/docker.log"
DB_PATH="/share/mysql/"

# Stop all containers
#if [[ ! `docker ps | grep Mail` ]]; then
#  exit
#fi

docker stop $(docker ps -a -q)
# Remove all containers
docker rm -f $(docker ps -a -q)
echo "Containers removed" >> $DOCKER_LOG

# Rebuild all containers
#
# MariaDB
docker run -d \
    -p 3306:3306 \
    -v /share/mysql/var/lib/mysql:Z \
    -v $DOCKER_CFG/mariadb/scripts/:/beheer/scripts/:Z \
    -v $DOCKER_CFG/general/log/:/var/log/qnap/:Z \
    --network my-net \
    --ip 192.168.11.4 \
    --ulimit memlock=-1:-1 \
    --restart unless-stopped \
    --name Mysql \
    ${PRE}-mariadb:${VERSION}

# Mail
docker run -d \
    -p 25:25 \
    -p 587:587 \
    -p 993:993 \
    -v $DOCKER_CFG/mail/dovecot:/etc/dovecot:Z \
    -v $DOCKER_CFG/mail/postfix:/etc/postfix:Z \
    -v $DOCKER_CFG/mail/fail2ban:/etc/fail2ban:Z \
    -v $DOCKER_BASE/maildir:/var/maildir:Z \
    -v $DOCKER_CFG/mail/spamassassin:/etc/spamassassin:Z \
    -v $DOCKER_CFG/mail/opendkim:/etc/opendkim:Z \
    -v $DOCKER_CFG/mail/opendmarc:/etc/opendmarc:Z \
    -v $DOCKER_CFG/websrv/sslcerts:/etc/postfix/ssl:Z \
    -v $DOCKER_CFG/general/scripts/:/beheer/scripts/:Z \
    -v $DOCKER_CFG/general/var/:/beheer/log/:Z \
    -v $DOCKER_CFG/general/log/:/var/log/qnap/:Z \
    --add-host="dockerhost:192.168.1.1" \
    --network my-net \
    --ip 192.168.11.2 \
    --add-host="mysql.mydomain.local:192.168.1.4" \
    --restart unless-stopped \
    --name Mail \
    ${PRE}-mail:${VERSION}

# Apache
docker run -d \
    -p 82:80 \
    -p 83:83 \
    -p 443:443 \
    -p 8081:8080 \
    -p 8443:8443 \
    -v $DOCKER_CFG/websrv/www/:/var/www/:Z \
    -v $DOCKER_BASE/nextcloud/:/var/nextcloud/data/:Z \
    -v $DOCKER_CFG/websrv/modsecurity/:/etc/modsecurity/:Z \
    -v $DOCKER_CFG/websrv/domoticz/:/opt/domoticz/:Z \
    -v $DOCKER_CFG/websrv/ssh/:/root/.ssh/:Z \
    -v $DOCKER_CFG/websrv/conf:/etc/apache2/sites-enabled:Z \
    -v $DOCKER_CFG/websrv/sslcerts:/etc/apache2/sslcerts:Z \
    -v $DOCKER_CFG/websrv/fail2ban/:/etc/fail2ban/:Z \
    -v $DOCKER_CFG/websrv/sbfspot.3/:/usr/local/bin/sbfspot.3/:Z \
    -v $DOCKER_CFG/websrv/acme.sh:/root/.acme.sh:Z \
    -v $DOCKER_CFG/general/scripts/:/beheer/scripts/:Z \
    -v $DOCKER_CFG/general/var/:/beheer/log/:Z \
    -v $DOCKER_CFG/general/log/:/var/log/qnap/:Z \
    --network my-net \
    --ip 192.168.11.3 \
    --add-host="mysql.mydomain.local:192.168.1.4" \
    --restart unless-stopped \
    --name Web \
    ${PRE}-apache:${VERSION}
