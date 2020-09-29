HOST_FILE="/etc/hosts";
TEMPLATE_DIR="$(pwd)/services/templates"
PROJECTS_DIR="$(pwd)/domains"

askForNewProjectname() {
    read -r -p "$(echo -e ${Cyan}Enter project name${NC} [numbers, letters, slash]: ) " PROJECT_NAME;
    PROJECT_DIR="$PROJECTS_DIR/$PROJECT_NAME";
    re='^[A-Za-z0-9-]+$'
    if ! [[ $PROJECT_NAME =~ $re ]] ; then
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
            if [ -f "$(pwd)/$f/docker-compose.yml" ]; then
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
    
    re='^[0-9]+$'
    if ! [[ $PROJECT_ID =~ $re ]] ; then
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

addHost() {
    DOMAIN_NAME=$1
    HOSTS_LINE=$2
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
    
    re='^[0-9]+$'
    if ! [[ $TEMPLATE_ID =~ $re ]] ; then
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
