#!/bin/bash

. "$(dirname "$0")/libs/colors.sh"
. "$(dirname "$0")/libs/functions.sh"

askForProjectname;

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${On_Red} Error ${NC} ${Yellow} Directory \"$PROJECT_DIR\" doesn't exist.${NC}";
else
    cd $PROJECT_DIR; 
    if [ -f "docker-compose-$ENVIRONMENT.yml" ]; then
        echo "Loading docker-compose-$ENVIRONMENT.yml";
        docker-compose -f "docker-compose-$ENVIRONMENT.yml" $1;
    else
        echo -e "${LABEL_INFO} File docker-compose-$ENVIRONMENT.yml doesn't exist. Using: docker-compose.yml";
        docker-compose $1;
    fi
fi
