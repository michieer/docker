#!/bin/bash

BASE="debian"
PRE="deb"
VERSION="latest"
NAME=`hostname`

# Locations
DOCKER_BASE="/share/Docker"
DOCKER_MG="$DOCKER_BASE/mgmt"
DOCKER_CFG="$DOCKER_BASE/containers"
DOCKER_LOG="$DOCKER_MG/log/docker.log"
LOGFILE="$DOCKER_MG/log/cron.log"

# Build images
$DOCKER_MG/cron/docker_rebuild_images.sh

# Check if all required images exist
if [[ "$(docker images -q ${PRE}-apache:$VERSION 2> /dev/null)" == "" ]]; then
  apache=0
  echo "apache image doesn't exist" >> $DOCKER_LOG
else
  apache=1
  echo "apache image exists" >> $DOCKER_LOG
fi

if [[ "$(docker images -q ${PRE}-mail:$VERSION 2> /dev/null)" == "" ]]; then
  mail=0
  echo "mail image doesn't exist" >> $DOCKER_LOG
else
  mail=1
  echo "mail image exists" >> $DOCKER_LOG
fi

if [[ "$(docker images -q ${PRE}-mariadb:$VERSION 2> /dev/null)" == "" ]]; then
  mariadb=0
  echo "mariadb image doesn't exist" >> $DOCKER_LOG
else
  mariadb=1
  echo "mariadb image exists" >> $DOCKER_LOG
fi

# If all images are present, rebuild containers
if [[ $(($apache+$mail+$mariadb)) = 3 ]]; then
  $DOCKER_MG/cron/docker_rebuild_containers.sh $PRE $VERSION
else
  echo "Not all required images present" >> $DOCKER_LOG
fi

# Cleanup stale images
for i in `docker images | grep none | sed -e "s/  */ /g" | cut -d " " -f 3`;do docker rmi $i;done
echo "Old images cleaned" >> $DOCKER_LOG

# Cleanup logfiles older than 30 days
find $DOCKER_CFG/../mgmt/log/ -type f -name "*.log" -mtime +30 -exec rm {} \;

# Cleanup docker images
docker system prune  -a -f
