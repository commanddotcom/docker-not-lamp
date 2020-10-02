#!/bin/bash

. "$(dirname "$0")/libs/colors.sh"
. "$(dirname "$0")/libs/functions.sh"

sudo echo "Removing project ...";

askForProjectname

echo '';
read -r -p " $(echo -e Print ${Cyan}delete${NC} to delete ${On_Blue} $PROJECT_NAME ${NC}: ) " SAFTY_CONFIRMATION;

if [ $SAFTY_CONFIRMATION != 'delete' ]; then
    echo 'Interrupted by miss-click';
    exit 0;
fi

DOMAIN="$PROJECT_NAME.local";
removeHost $DOMAIN # Remove host from the host file

if [ -f "$PROJECT_DIR/.installed" ]; then
    MYSQL_DATABASE=$(getEnvValue 'MYSQL_DATABASE' "$PROJECT_DIR/.installed");
    MYSQL_USER=$(getEnvValue 'MYSQL_USER' "$PROJECT_DIR/.installed");
    if ! [ -z $MYSQL_USER ]; then
        MYSQL_removeUser $MYSQL_USER;
    fi
    if ! [ -z $MYSQL_DATABASE ]; then
        MYSQL_removeDatabase $MYSQL_DATABASE;
    fi
fi

if [ -d "$PROJECT_DIR" ]; then
    $(cd $PROJECT_DIR; docker-compose down -v); # Remove containers
    removeProjectDir $PROJECT_NAME # Remove files
else
    echo -e "${LABEL_INFO} \"$PROJECT_DIR\" doesn't exist.";
fi

