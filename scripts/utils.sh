#!/bin/bash

# will print the error code and return from script
# will take two args.
# 1 = error code
# 2 = error message.

. ./scripts/variables.sh

function print_exit(){
    local error_code=${1}
    local error_msg=${2}
    echo -e "${RED}[Fail] ${error_msg} ${NOCOLOR}" 1>&2
    exit ${error_code}
}

function showBanner(){
    banner_file=${1}
    cat ${banner_file}
}

function showProgress(){
    local last_command_pid=${1}
    while ps | grep -i "${last_command_pid}" > /dev/null
    do 
        for i in '-' '\' '|' '/'
        do
            echo -ne "\b${i}"
            sleep 0.20
        done
        echo -en "\b"
    done
}

function installPackage() {
    local packageName=${1}
    apt-get install -y ${packageName} > /dev/null &
    last_command_pid=$!
    showProgress ${last_command_pid}
    wait ${last_command_pid} || print_exit 1 "not able to install ${packageName}."
}

function mavenTarget(){
    local mavenCmd=${1}
    mvn ${mavenCmd} > /dev/null &
    last_command_pid=$!
    showProgress ${last_command_pid}
    wait ${last_command_pid} || print_exit 1 "${mavenCmd} fail."
}

function install_tomcat9_using_wget() {

    TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.89/bin/apache-tomcat-9.0.89.tar.gz"
    TOMCAT_DIR="/opt/tomcat9"
    FILE_NAME="apache-tomcat-9.0.89.tar.gz"

    echo "Starting Tomcat9 installation..."

    # Check if already installed
    if [ -d "$TOMCAT_DIR" ]; then
        echo "Tomcat9 already installed at $TOMCAT_DIR"
        return 0
    fi

    # Move to /opt
    cd /opt || { echo "Failed to move to /opt"; return 1; }

    echo "Downloading Tomcat9..."
    wget -q "$TOMCAT_URL" -O "$FILE_NAME"
    if [ $? -ne 0 ]; then
        echo "Download failed"
        return 1
    fi

    echo "Extracting Tomcat..."
    tar -xzf "$FILE_NAME"
    if [ $? -ne 0 ]; then
        echo "Extraction failed"
        return 1
    fi

    echo "Renaming directory..."
    mv apache-tomcat-9.0.89 tomcat9

    echo "Cleaning up..."
    rm -f "$FILE_NAME"

    echo "Setting permissions..."
    chmod +x $TOMCAT_DIR/bin/*.sh

    echo "Starting Tomcat..."
    $TOMCAT_DIR/bin/startup.sh

    echo "Tomcat9 installed successfully!"
    echo "Access: http://<IP>:8080"
}

