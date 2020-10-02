#!/bin/bash

. "$(dirname "$0")/libs/colors.sh"
. "$(dirname "$0")/libs/functions.sh"

echo -e "\n";
testContainer $NGINX_PROXY_DIR "nginx-proxy" "Nginx Proxy"
testContainer $DATABASE_DIR "mysql" "MySQL"
testContainer $DATABASE_DIR "postgres" "PostgreSQL"

askForProjectname;

if [ -f "$PROJECT_DIR/.installed" ]; then
    echo -e "${BIBlue}$(cat "$PROJECT_DIR/.installed")${NC}";
else 
    echo -e " ${IYellow}No .installed file for${NC} ${BIBlue}$PROJECT_NAME${NC}"
fi
