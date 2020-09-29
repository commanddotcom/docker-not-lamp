#!/bin/bash

. "$(dirname "$0")"/libs/colors.sh
. "$(dirname "$0")"/libs/functions.sh

echo -e "\n";
testContainer $1 "nginx-proxy" "Nginx Proxy"
testContainer $2 "mysql" "MySQL"
testContainer $2 "postgres" "PostgreSQL"
echo -e "\n";

getProject 0;
