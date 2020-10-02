#!/bin/bash

. "$(dirname "$0")/libs/colors.sh"
. "$(dirname "$0")/libs/functions.sh"

LOG_ENV="# DockLAMP .installed file keeps inforamtion about things that were automatically installed\n";
LOG_ENV="${LOG_ENV}CREATED=\"$(date)\"\n";
LOG_ENV="${LOG_ENV}CREATED_UNIXTIME=\"$(date +%s)\"\n";

sudo echo "Creating new project ...";

askForNewProjectname;
setTemplateFolder;

DOMAIN="$PROJECT_NAME.local";

LOG_ENV="${LOG_ENV}PROJECT_NAME=\"${PROJECT_NAME}\"\n";
LOG_ENV="${LOG_ENV}DOMAIN=\"${DOMAIN}\"\n";
LOG_ENV="${LOG_ENV}ORIGIN_TEMPLATE=\"${TEMPLATE_FOLDER}\"\n";

if [ -d "$PROJECT_DIR" ]; then
    echo "${LABEL_ERROR} Failed to create new project: directory \"$PROJECT_DIR\" already exist.";
    exit 1;
fi

cp -R $TEMPLATE_FOLDER $PROJECT_DIR;
sed -i "s/_name_/$PROJECT_NAME/g" "$PROJECT_DIR/docker-compose.yml.dist";
sed -i "s/_domain_/$DOMAIN/g" "$PROJECT_DIR/docker-compose.yml.dist";
mv "$PROJECT_DIR/docker-compose.yml.dist" "$PROJECT_DIR/docker-compose.yml";
echo "docker-compose.yml for \"$PROJECT_NAME\" is set succesfully!";

TEMPLATE_INSTALL_FILE="$(pwd)/$TEMPLATE_FOLDER/.install.sh";
if [ -f "$TEMPLATE_INSTALL_FILE" ]; then
    . $TEMPLATE_INSTALL_FILE
fi

addHost $DOMAIN;

echo -e "$LOG_ENV" >> "$PROJECT_DIR/.installed"; # save information about things that were installed

cd $PROJECT_DIR;
docker-compose up -d; # run containers

echo -e " 
Installation complite! 
${On_Yellow} Folder ${NC}: $PROJECT_DIR
${On_Yellow} URL ${NC}: http://$DOMAIN";

