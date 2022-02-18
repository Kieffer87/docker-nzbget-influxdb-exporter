#!/bin/bash

# Set sane bash defaults
set -o errexit
set -o pipefail

OPTION="$1"
CRON_SCHEDULE=${CRON_SCHEDULE:-* * * * *}

LOCKFILE="/tmp/influxdb-export.lock"
LOG="/var/log/influxdb-export.log"

trap 'rm -f $LOCKFILE' EXIT

if [ ! -e $LOG ]; then
  touch $LOG
fi

if [[ $OPTION = "start" ]]; then
  echo "Collecting metrics on the following CRON schedule: $CRON_SCHEDULE"
  echo "$CRON_SCHEDULE bash /run.sh run" | crontab - && crond -f
  
elif [[ $OPTION = "run" ]]; then
  if [ -f $LOCKFILE ]; then
    echo "$LOCKFILE detected, exiting! Already running?" | tee -a $LOG
    exit 1
  else
    touch $LOCKFILE
  fi

  python3 /export.py 2>&1 | tee -a $LOG

  rm -f $LOCKFILE

else
  echo "Unsupported option: $OPTION" | tee -a $LOG
  exit 1
fi
