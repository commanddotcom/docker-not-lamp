#!/bin/bash

. "$(dirname "$0")/libs/colors.sh"
. "$(dirname "$0")/libs/functions.sh"

echo -e "\n";
testContainer $NGINX_PROXY_DIR "nginx-proxy" "Nginx Proxy"
testContainer $DATABASE_DIR "mysql" "MySQL"
testContainer $DATABASE_DIR "postgres" "PostgreSQL"
echo -e "\n";

getProject 0;
