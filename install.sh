#!/bin/bash

. "services/sh/libs/colors.sh"
. "services/sh/libs/functions.sh"

ENV_FILE="$(pwd)/services/database/.env";

if [ -f "$ENV_FILE" ]; then
    echo "Sorry, DockLAMP is already installed.";
    exit 0;
fi

export MYSQL_ROOT_PASSWORD=$(getRandStr) MYSQL_PASSWORD=$(getRandStr) PG_PASSWORD=$(getRandStr) PGADMIN_DEFAULT_PASS=$(getRandStr);
envsubst '${MYSQL_ROOT_PASSWORD} ${MYSQL_PASSWORD} ${PG_PASSWORD} ${PGADMIN_DEFAULT_PASS}' <"./services/database/env.dist" >"$ENV_FILE"

make start

PHPMYADMIN_VIRTUAL_HOST=$(grep 'PHPMYADMIN_VIRTUAL_HOST' $ENV_FILE | cut -d '=' -f2);
PG_ADMIN_VIRTUAL_HOST=$(grep 'PG_ADMIN_VIRTUAL_HOST' $ENV_FILE | cut -d '=' -f2);

addHost "$PHPMYADMIN_VIRTUAL_HOST" "127.0.0.1\t$PHPMYADMIN_VIRTUAL_HOST"
addHost "$PG_ADMIN_VIRTUAL_HOST" "127.0.0.1\t$PG_ADMIN_VIRTUAL_HOST"

echo -e "MySQL Server:";
echo '';
echo -e "\tAddess: "$(grep 'MYSQL_HOST' $ENV_FILE | cut -d '=' -f2);
echo -e "\tphpMyAdmin: http://$PHPMYADMIN_VIRTUAL_HOST"; 
echo '';

echo -e "\tMySQL Root User:"
echo -e "\tLogin: "$(grep 'MYSQL_ROOT_USER' $ENV_FILE | cut -d '=' -f2);
echo -e "\tPassword: "$(grep 'MYSQL_ROOT_PASSWORD' $ENV_FILE | cut -d '=' -f2); 
echo '';

echo -e "\tMySQL Default User:"
echo -e "\t\tDatabase: "$(grep 'MYSQL_DATABASE' $ENV_FILE | cut -d '=' -f2);
echo -e "\t\tLogin: "$(grep 'MYSQL_USER' $ENV_FILE | cut -d '=' -f2);
echo -e "\t\tPassword: "$(grep 'MYSQL_PASSWORD' $ENV_FILE | cut -d '=' -f2);  
echo '';

echo -e "PostgreSQL Server:"
echo '';
echo -e "\tAddess: "$(grep 'PG_HOST' $ENV_FILE | cut -d '=' -f2);
echo -e "\tPgAdmin: http://$PG_ADMIN_VIRTUAL_HOST";
echo '';

echo -e "\tPostgreSQL Database User:"
echo -e "\t\tLogin: "$(grep 'MYSQL_USER' $ENV_FILE | cut -d '=' -f2); 
echo -e "\t\tPassword: "$(grep 'PG_PASSWORD' $ENV_FILE | cut -d '=' -f2);  
echo '';

echo -e "\tPgAdmin user:"
echo -e "\t\tDatabase: "$(grep 'PG_DATABASE' $ENV_FILE | cut -d '=' -f2);
echo -e "\t\tLogin: "$(grep 'PGADMIN_DEFAULT_EMAIL' $ENV_FILE | cut -d '=' -f2); 
echo -e "\t\tPassword: "$(grep 'PGADMIN_DEFAULT_PASS' $ENV_FILE | cut -d '=' -f2);  
echo '';

echo -e "You can always find db creadentials are in $ENV_FILE";
echo '';
echo 'Installation complite! Run "make" for help';
echo '';

#rm -f install.sh
