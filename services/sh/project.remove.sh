#!/bin/bash

. "$(dirname "$0")/libs/colors.sh"
. "$(dirname "$0")/libs/functions.sh"

sudo echo "Removing project ...";

askForProjectname
DOMAIN="$PROJECT_NAME.local";
removeHost $DOMAIN # Remove host from the host file

if [ -d "$PROJECT_DIR" ]; then
    $(cd $PROJECT_DIR; docker-compose down -v); # Remove containers
    removeProjectDir $PROJECT_NAME # Remove files
else
    echo -e "${LABEL_INFO} \"$PROJECT_DIR\" doesn't exist.";
fi

