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

if ! [ -d "$PROJECT_DIR" ]; then
    echo -e "${LABEL_INFO} \"$PROJECT_DIR\" doesn't exist.";
    exit 0;
fi

if [ -f "$PROJECT_DIR/.installed" ]; then
    
    MYSQL_USER=$(getEnvValue 'MYSQL_USER' "$PROJECT_DIR/.installed");
    if ! [ -z $MYSQL_USER ]; then
        MYSQL_removeUser $MYSQL_USER;
    fi

    MYSQL_DATABASE=$(getEnvValue 'MYSQL_DATABASE' "$PROJECT_DIR/.installed");
    if ! [ -z $MYSQL_DATABASE ]; then
        MYSQL_removeDatabase $MYSQL_DATABASE;
    fi

    DOMAIN=$(getEnvValue 'DOMAIN' "$PROJECT_DIR/.installed");
    if ! [ -z $DOMAIN ]; then
        removeHost $DOMAIN;
    fi
fi

$(cd $PROJECT_DIR; docker-compose down -v); # Remove containers
removeProjectDir $PROJECT_NAME # Remove files
