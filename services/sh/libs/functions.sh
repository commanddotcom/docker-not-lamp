getEnvValue() {
    if [ -z $2 ]; then
        ENV_FILE_="$(pwd)/.env";
    else 
        ENV_FILE_=$2;
    fi
    echo $(eval echo $(grep $1 "$ENV_FILE_" | cut -d '=' -f2));
}

IP=$(getEnvValue "IP");
HOST_FILE=$(getEnvValue "HOST_FILE");
TEMPLATE_DIR="$(pwd)/"$(getEnvValue "TEMPLATE_DIR")
NGINX_PROXY_DIR="$(pwd)/"$(getEnvValue "NGINX_PROXY_DIR");
DATABASE_DIR="$(pwd)/"$(getEnvValue "DATABASE_DIR");
PROJECTS_DIR="$(pwd)/"$(getEnvValue "PROJECTS_DIR");
SERVICE_DIR="$(pwd)/"$(getEnvValue "SERVICE_DIR");
SHELL_DIR="$(pwd)/"$(getEnvValue "SHELL_DIR");

getRandStr() {
    if [ -z $1 ]; then
        RAND_STR_LENGTH=10;
    else 
        RAND_STR_LENGTH=$1;
    fi
    echo $(head /dev/urandom | tr -dc A-Za-z0-9 | head -c $RAND_STR_LENGTH);
}

askForNewProjectname() {
    read -r -p "$(echo -e ${Cyan} Enter project name${NC} [numbers, letters, slash]: ) " PROJECT_NAME;
    PROJECT_DIR="$PROJECTS_DIR/$PROJECT_NAME";
    if ! [[ $PROJECT_NAME =~ ^[A-Za-z0-9\.\-]+$ ]] ; then
        echo -e "${LABEL_ERROR} ${BRed}Invalid project name${NC}";
        askForNewProjectname;
    fi
}

getProject() {

    cd "$PROJECTS_DIR";

    if [ -z $1 ]; then
        echo -e "\n Loading......\n";
    fi

    i=1;
    for f in *; do
        if [ -d "$f" ]; then
            if ! [ -z $1 ] && [ $1 -eq $i ]; then
                OUTPUT=$f;
                break;
            fi
            askForProjectname_Output+="\n"
            if [ -f "$PROJECTS_DIR/$f/docker-compose.yml" ]; then
                runningConainers=$(countRunningContainersForDockerComposer "$(pwd)/$f");
                if [ $runningConainers -gt 0 ]; then
                    projectLabel="${On_Green} $runningConainers container is running ${NC}";
                else
                    projectLabel="${On_Red} Stoped ${NC}";
                fi
                askForProjectname_Output+=$(echo -e " ${On_Green} $i ${NC}|$f|$projectLabel");
                i=$((i+1));
            else 
                askForProjectname_Output+=$(echo -e " ${On_Red} x ${NC}|$f|${On_Yellow} docker-compose.yml doesn't exist ${NC}");
            fi
        fi
    done

    askForProjectname_Output+="\n";
    askForProjectname_Output+=$(echo -e " ${On_Cyan} 0 ${NC}|Quit| ");
    
    if ! [ -z $OUTPUT ]; then 
        echo $OUTPUT;
    else 
        echo -e " ${BCyan}List of projects:${NC}\n"
        column -t -s "|" <<< $(echo -e $askForProjectname_Output);
    fi

}

askForProjectname() {

    getProject;

    echo " ";
    read -r -p "$(echo -e ${Cyan} Select project from the list${NC} [Enter number]: ) " PROJECT_ID;

    if [ $PROJECT_ID -eq 0 ]; then
        echo 'Interrupted.'
        exit 0;
    fi
    
    if ! [[ $PROJECT_ID =~ ^[0-9]+$ ]] ; then
        echo -e "${LABEL_ERROR} \"$PROJECT_ID\" is not a number.";
        exit 0;
    fi

    PROJECT_NAME=$(getProject $PROJECT_ID);
    PROJECT_DIR="$PROJECTS_DIR/$PROJECT_NAME";
    DOCKER_COMPOSER_FILE="$PROJECT_DIR/docker-compose.yml";
    if ! [ -f "$DOCKER_COMPOSER_FILE" ]; then
        echo -e "${LABEL_ERROR} Project is invalid: file $UWhite$DOCKER_COMPOSER_FILE$NC doesn't exist! Try another one!";
        askForProjectname;
    fi
}

setDOMAIN() {

    if [ -z $1 ]; then
        read -r -p "$(echo -e ${Cyan} Print domain name${NC} [A-Za-z0-9.-]: ) " DOMAIN;
        if ! [[ $DOMAIN =~ ^[A-Za-z0-9\.\-]+$ ]]; then
            echo -e "${LABEL_ERROR} ${BRed}Invalid domain name${NC}";
            setDOMAIN;
        fi
    else
        echo -e " ${BCyan}List of options:${NC}";
        echo "  1) $1.local";
        echo "  2) dev.$1";
        echo "  3) Other (custom)";

        read -r -p "$(echo -e ${Cyan} Select domain for new project${NC} [Enter number]: ) " DOMAIN_OPTION_ID;

        if [ $DOMAIN_OPTION_ID -eq "1" ]; then
            DOMAIN="$1.local";
        elif [ $DOMAIN_OPTION_ID -eq "2" ]; then
            DOMAIN="dev.$1";
        elif [ $DOMAIN_OPTION_ID -eq "3" ]; then
            setDOMAIN;
        else 
            echo -e "${LABEL_ERROR} Invalid number. Try again!";
            setDOMAIN $1;
        fi
    fi
}

addHost() {
    DOMAIN_NAME=$1
    HOSTS_LINE="$IP\t$DOMAIN_NAME";

    if [ -n "$(grep $DOMAIN_NAME $HOST_FILE)" ]
        then
            echo -e "${LABEL_INFO} $DOMAIN_NAME already exists : $(grep $DOMAIN_NAME $HOST_FILE)"
        else
            echo "Adding $DOMAIN_NAME to $HOST_FILE";
            sudo -- sh -c -e "echo '$HOSTS_LINE' >> $HOST_FILE";

            if [ -n "$(grep $DOMAIN_NAME $HOST_FILE)" ]
                then
                    echo -e "${LABEL_SUCCESS} $DOMAIN_NAME was added to hosts file: $(grep $DOMAIN_NAME $HOST_FILE)";
                else
                    echo -e "${LABEL_ERROR} ${On_Red}Failed to add $DOMAIN_NAME${NC}";
            fi
    fi
}

removeHost() {
    DOMAIN_NAME=$1
    if [ -n "$(grep $DOMAIN_NAME $HOST_FILE)" ]
        then
            echo "Removing $DOMAIN_NAME from $HOST_FILE"
            sudo -- sh -c -e "sed -i '/$DOMAIN_NAME/d' $HOST_FILE"
            if [ -n "$(grep $DOMAIN_NAME $HOST_FILE)" ]
                then
                    echo -e "${LABEL_ERROR} ${On_Red}Failed to remove $DOMAIN_NAME${NC}";
                else
                    echo -e "${LABEL_SUCCESS} $DOMAIN_NAME was removed from $HOST_FILE";
            fi
        else
            echo -e "${LABEL_INFO} $HOST_FILE doesn't have ${UWhite}$DOMAIN_NAME${NC} record";
    fi
}

removeProjectDir() {
    PROJECT_NAME=$1
    PROJECT_DIR="$PROJECTS_DIR/$PROJECT_NAME";
    echo -e "Deleting $PROJECT_DIR ...";
    sudo rm -rf $PROJECT_DIR;

    if ! [ -d "$PROJECT_DIR" ]; then
        echo -e "${LABEL_SUCCESS} Project folder was removed";
    else
        echo -e "${LABEL_ERROR} Failed to delete $PROJECT_DIR";
    fi
}

setTemplateFolder() {

    cd "$TEMPLATE_DIR";

    echo -e " ${BCyan}List of templates:${NC}";

    i=1;
    for f in *; do
        if [ -d "$f" ]; then
            echo "  $i) $f";
            i=$((i+1))
        fi
    done

    read -r -p "$(echo -e ${Cyan} Select template for new project${NC} [Enter number]: ) " TEMPLATE_ID;
    
    if ! [[ $TEMPLATE_ID =~ ^[0-9]+$ ]] ; then
        echo -e "${LABEL_ERROR} Not a number. Try again!";
        setTemplateFolder;
    fi

    i=1;

    for f in *; do
        if [ -d "$f" ]; then
            if [ $i -eq $TEMPLATE_ID ]; then
                TEMPLATE_FOLDER=$f;
            fi
            i=$((i+1))
        fi
    done
    
    DOCKER_COMPOSER_FILE="$(pwd)/$TEMPLATE_FOLDER/docker-compose.yml.dist";
    if ! [ -f "$DOCKER_COMPOSER_FILE" ]; then
        echo -e "${LABEL_ERROR} Template is invalid: file $UWhite$DOCKER_COMPOSER_FILE$NC doesn't exist! Try another one!";
        setTemplateFolder;
    fi
}

countRunningContainersForDockerComposer() {
    cd "$1"
    docker-compose ps -q | wc -l;
}

testContainer() {

    cd $1;

    nginxProxyStatus=$(docker-compose ps | gawk '/'$2'/ {print $4}');

    if [ -z $nginxProxyStatus ]; then
        echo -e " ${On_Red}  ${NC} $3 is not running "
    elif [ $nginxProxyStatus = "Up" ]; then
        echo -e " ${On_Green}  ${NC} $3 is running "
    else 
        echo -e " ${On_Cyan}  ${NC} $3 is $nginxProxyStatus "
    fi

}

MYSQL_newDatabase() {
    MYSQL_ROOT_USER=$(getEnvValue 'MYSQL_ROOT_USER' "$DATABASE_DIR/.env");
    MYSQL_ROOT_PASSWORD=$(getEnvValue 'MYSQL_ROOT_PASSWORD' "$DATABASE_DIR/.env");
    MYSQL_NEW_DB_NAME="db_${PROJECT_NAME}";
    MYSQL_NEW_DB_USER_NAME="u_$(getRandStr 6)";
    MYSQL_NEW_DB_USER_PASS=$(getRandStr);

    docker exec -it mysql bash -c "mysql -u $MYSQL_ROOT_USER -p'$MYSQL_ROOT_PASSWORD' -e \"CREATE DATABASE IF NOT EXISTS $MYSQL_NEW_DB_NAME CHARACTER SET utf8 COLLATE utf8_general_ci; GRANT ALL PRIVILEGES ON $MYSQL_NEW_DB_NAME.* TO '$MYSQL_NEW_DB_USER_NAME'@'%' IDENTIFIED BY '$MYSQL_NEW_DB_USER_PASS'; FLUSH PRIVILEGES\""
}

MYSQL_removeUser() {
    MYSQL_ROOT_USER=$(getEnvValue 'MYSQL_ROOT_USER' "$DATABASE_DIR/.env");
    MYSQL_ROOT_PASSWORD=$(getEnvValue 'MYSQL_ROOT_PASSWORD' "$DATABASE_DIR/.env");
    docker exec -it mysql bash -c "mysql -u $MYSQL_ROOT_USER -p'$MYSQL_ROOT_PASSWORD' -e \"DROP USER IF EXISTS '$1'@'%'\""
}

MYSQL_removeDatabase() {
    MYSQL_ROOT_USER=$(getEnvValue 'MYSQL_ROOT_USER' "$DATABASE_DIR/.env");
    MYSQL_ROOT_PASSWORD=$(getEnvValue 'MYSQL_ROOT_PASSWORD' "$DATABASE_DIR/.env");
    docker exec -it mysql bash -c "mysql -u $MYSQL_ROOT_USER -p'$MYSQL_ROOT_PASSWORD' -e \"DROP DATABASE IF EXISTS $1\""
}
