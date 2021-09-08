#!/bin/sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

CRON="  0 0  0   0   0     /bin/sh $SCRIPT_DIR/build.sh"


if [ "$(cat /etc/crontab | grep -c $CRON)" -lt "1"] ; do
    echo "$CRON" > /etc/crontab
done

