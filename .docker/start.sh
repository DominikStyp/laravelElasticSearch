#!/bin/bash

function is_installed {
    local RUN_STRICT=0
    [[ $1 == '--strict' ]] && RUN_STRICT=1 && shift

    for PACKAGE in "$@"
    do
        if ! ${PACKAGE} --version >/dev/null 2>&1; then
            [[ $RUN_STRICT == 1 ]] && {
                echo -e "${RED}Error: No '$PACKAGE' package installed on this machine. Aborting.${UNSET}"
                exit 1
            } || return 1
        fi
    done
}


function change_question {
    read -n 1 -p "Do you want to proceed [Y/n]: " choice
    if [ "$choice" = "n" ] || [ "$choice" = "N" ]; then
        echo -e "\n\033[93m----------------============== Stop run! ==============----------------\e[0m"
        exit 0
    elif [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        echo -e "\n\033[93m----------------============== Continue run ==============----------------\n\e[0m"
    else
        echo -e "\n\033[93m----------------============== Wrong Answer! ==============----------------\e[0m"
        change_question
    fi
}

function check_system_requirements {
    echo ' ----------------============== Check if docker, docker-compose and python are installed ==============----------------'
    is_installed --strict 'docker' 'docker-compose' 'python'
    is_installed 'j2' || {
        echo ' ----------------============== Check python version and if pip is installed ==============----------------'
        PYTHON_MAIN_VERSION=$(python -c 'import platform; print(platform.python_version())' | awk -F "." '{print $1}')

        if [ "$PYTHON_MAIN_VERSION" == "3" ]; then
            is_installed 'pip3'
            pip3 install j2cli
        elif [ "$PYTHON_MAIN_VERSION" == "2" ]; then
            is_installed 'pip'
            pip install j2cli
        else
            echo '!!!!!!!!!!!============== Python error, check if you have "python" command on machine ==============!!!!!!!!!!!'
            exit 1
        fi
    }

    echo ' ----------------============== Checking python pip packages path in PATH ==============----------------'

    export PY_USER_BIN=$(python -c 'import site; print(site.USER_BASE + "/bin")')
    if echo "$PATH" | grep -q "$PY_USER_BIN"; then
      echo "pip packages path already included in user PATH"
    else
      export PATH=$PY_USER_BIN:$PATH
      echo "Adding temporary pip package path to user's PATH"
    fi
}

function prepare_common {
    mkdir -p $WORK_DIR/nginx/ssl/
    mkdir -p $WORK_DIR/nginx/vhosts/
    mkdir -p $WORK_DIR/local-env-files/
}

function prepare_dev_env {
    if [ ! -L $DOCKER_ENV_LOCATION ] && [ -e $DOCKER_ENV_LOCATION ] ; then
        rm -f $DOCKER_ENV_LOCATION
    fi
    sed -i "s/^DEVELOPMENT=.*/DEVELOPMENT=1/g" $LOCAL_ENV_LOCATION
    sed -i "s/^APP_DEBUG=.*/APP_DEBUG=true/g" $LOCAL_ENV_LOCATION
    ln -fns "$LOCAL_ENV_LOCATION" "$DOCKER_ENV_LOCATION"

    for template in $WORK_DIR/templates/*.j2; do
        template_only_filename=$(echo $template | awk -F/ '{print $NF}')
        if [[ $template_only_filename == *"nginx-conf"* ]]; then
            filename=$(echo $template | awk -F/ '{print $NF}' | cut -d "-" -f1).conf
            j2 --format=env $template $LOCAL_ENV_LOCATION > $WORK_DIR/nginx/vhosts/$filename
        elif  [[ $template_only_filename == *"common"* ]] || [[ $template_only_filename == *"env"* ]]; then
            echo -e "!!!!!!!!!!!============== File not used for development environment $template_only_filename - IGNORING ==============!!!!!!!!!!!'"
        else
            echo -e "!!!!!!!!!!!============== NOT SUPPORTED FILENAME DETECTED $template_only_filename - IGNORING ==============!!!!!!!!!!!"
            echo '!!!!!!!!!!!============== SUPPORTED TYPES FILENAMES: ==============!!!!!!!!!!!'
            echo '!!!!!!!!!!!============== common - for docker-compose .env file only ==============!!!!!!!!!!!'
            echo '!!!!!!!!!!!============== docker-env - for containers enviroment variables ==============!!!!!!!!!!!'
            echo '!!!!!!!!!!!============== nginx-conf - for nginx vhosts configuration ==============!!!!!!!!!!!'
        fi
    done
}


#############
# Main code #
#############

if [ $# -eq 0 ]
  then
    echo "No arguments supplied - give environment type \"local\" or \"production\""
    exit 0
fi

check_system_requirements

ENV=$1
WORK_DIR=$(pwd)
LOCAL_ENV_LOCATION=$(dirname "$WORK_DIR")/.env
DOCKER_ENV_LOCATION=$WORK_DIR/.env
cd "$(dirname "$0")"

echo -e " ----------------============== Generate env and config files for  \033[93m$ENV\e[0m ==============----------------"
prepare_common

# prepare env files & build
prepare_dev_env
echo " ----------------============== Building docker images ==============----------------"
docker-compose up --build

