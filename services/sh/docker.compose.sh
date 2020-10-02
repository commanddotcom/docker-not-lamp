#!/bin/bash

. "$(dirname "$0")/libs/colors.sh"
. "$(dirname "$0")/libs/functions.sh"

askForProjectname;

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${On_Red} Error ${NC} ${Yellow}Directory \"$PROJECT_DIR\" doesn't exist.${NC}";
else
    cd $PROJECT_DIR; docker-compose $1;
fi
