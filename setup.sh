#!/bin/bash
#####
# this script will setup this project.
# run ./setup.sh to run this project.
#####
# Include files. 
. ./scripts/utils.sh
. ./scripts/variables.sh



function clean_up(){
    if rm -rf ./target
    then
        echo -e "${GREEN}clean up successfull.${NOCOLOR}"
    else
        echo -e "${GREEN}not able to do clean up.${NOCOLOR}"
    fi
}

trap "clean_up;exit 2" 2

showBanner scripts/banner.txt

if [[ $UID != 0 ]]
then
    print_exit 1 "user is not a root user"
fi

read -p "please enter access path " APP_CONTEXT
APP_CONTEXT=${APP_CONTEXT:-app}

apt-get update > /dev/null &
last_command_pid=$!
showProgress ${last_command_pid}

wait ${last_command_pid} || print_exit 1 "not able to update the repository."


installPackage maven
install_tomcat9_using_wget

cd /home/ubuntu/spring-boot-example || exit 1

mavenTarget test
mavenTarget package

PUBLIC_IP=$(curl ifconfig.me)

# Stop Tomcat before deployment (recommended)
echo "Stopping Tomcat9 before deployment..."
/opt/tomcat9/bin/shutdown.sh

# Remove old deployment
echo "Removing old deployment (if exists)..."
rm -rf /opt/tomcat9/webapps/*

# Deploy new application
echo "Deploying application to Tomcat9..."
/opt/tomcat9/bin/startup.sh

if cp -rf target/hello-world-0.0.1-SNAPSHOT.war /opt/tomcat9/webapps/${APP_CONTEXT}.war
then
    echo "Application Deployed successfully. You can access it on http://${PUBLIC_IP}:8080/${APP_CONTEXT}"
else
    print_exit 1 "not able to Deploy the application."
fi

# Clean Up code.

clean_up
exit 0