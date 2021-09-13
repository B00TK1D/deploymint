#!/bin/bash


# Default values
BUILD_DIR="/build"
DEPLOY_BRANCH="main"
BUILD_COMMAND="build.bash"


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )" > /dev/null 2>&1

if [ $EUID -ne 0 ]; then
    echo "Please run as root"
    exit
fi

ENV="/boot/.env"
if [[ ! -f "$ENV" ]]; then
    echo ".env missing, please add to boot partition"
    exit
fi

CRON="* * * * * root /bin/bash $SCRIPT_DIR/build.bash" > /dev/null 2>&1

if [ "$(cat /etc/crontab | grep -c "${CRON}")" -lt "1" ] ; then
    echo "${CRON}" | sudo tee -a /etc/crontab > /dev/null 2>&1
fi

rm -rf "${BUILD_DIR}" > /dev/null 2>&1
mkdir "${BUILD_DIR}" > /dev/null 2>&1

export $(egrep -v '^#' /boot/.env | xargs)

if [[ -z "${DEPLOY_REPO}" ]]; then
    echo "DEPLOY_REPO environment variable not set"
    exit
fi

git clone "${DEPLOY_REPO}" "${BUILD_DIR}"

if [[ ! -f "${BUILD_DIR}/${BUILD_COMMAND}" ]]; then
    echo "build file missing, skipping build"
    exit
fi

chmod +x "${BUILD_DIR}/${BUILD_COMMAND}"
eval "${BUILD_DIR}/${BUILD_COMMAND}"