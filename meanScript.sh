#!/bin/bash
#   Modified by Ed Arellano 2017/08
#   Based on the script by Carlin Yuen https://gist.github.com/carlinyuen/9080123
#   Run this from the folder that you want to be the root of your app,
#   which can be cloned from or later pushed to Heroku's git repo.
#   NOTE: this is best done with a clean / empty root folder!
#   
#   NOTE: Be sure to run this script as sudo
#
#   Troubleshooting: https://github.com/linnovate/mean.
#
#   This will pull the latest MEAN.io and install/update the following packages:
#       Git, Node, Bower, Grunt, Heroku Toolbelt, MongoDB, 
#       and any other local packages defined in package.json


# Update apt
echo "Updating apt"
apt update && apt upgrade

echo "Let's setup the server"
    #curl -sL https://raw.githubusercontent.com/d4mer/easy-idempiere-server/folder_system/idempiere_server_setup.sh | bash -


# Check if Git is installed
echo " - Git Check..."
which -a git 
if [[ $? != 0 ]] ; then
    #Install Git
    apt install git
#else
    #git update
fi

# Get clone of MEAN.io's repo minus the .git folder and copy to current
echo " - Cloning MEAN.io..."
rm -rf .meanStackSetupTemp
git clone https://github.com/linnovate/mean.git .meanStackSetupTemp || exit $?
rm -rf .meanStackSetupTemp/.git
mv .meanStackSetupTemp/{.,}* ./


# Check if Node is installed
#   Note that npm comes with node now
echo " - Node & npm Check..."
which -a node 
if [[ $? != 0 ]] ; then
    #Install node
    echo "Downloading and running setup scriptfor node 7"
    curl -sL https://deb.nodesource.com/setup_7.x | bash -
    apt install -y nodejs
else
    #nodejs update
fi

# Install Bower
echo " - Bower Check..."
which -a bower || npm install -g bower


# Install Grunt
echo " - Grunt Check..."
which -a grunt || npm install -g grunt


# Check if Heroku toolbelt is installed
echo " - Heroku Toolbelt Check..."
which -a heroku
if [[ $? != 0 ]] ; then
    # Install Heroku toolbelt
    echo "Downloading Heroku toolbelt"
    wget -qO- https://cli-assets.heroku.com/install-ubuntu.sh | sh
    read -p "Press return when done with Heroku installation"

    # open https://api.heroku.com/login
    # https://api.heroku.com/signup
else
    #heroku update
fi


# Install MongoDB
echo " - MongoDB Check..."
which -a mongo 
if [[ $? != 0 ]] ; then
    #Install MongoDB
    echo "Importing Mongo Key"
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
    echo "Adding to Repo"
    echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
    echo "Installing mongodb-org"
    apt install -y mongodb-org
else
    #mongodb-org update
fi

# Install node packages
echo " - Installing package.json packages..."
npm install


# Creating some folders for local db storage and startup mongoDB instance
if [[ ! -d /data/db/ ]]; then
    sudo mkdir -p /data/db/
    sudo chown `id -u` /data/db
fi
if [[ ! -d /data/dumps/ ]]; then
    sudo mkdir -p /data/dumps/
    sudo chown `id -u` /data/dumps
fi
echo " - Starting MongoDB in background"
ps -ef | grep mongod | awk '{print$2}' | xargs kill {} # Kill old mongodb process
mongod &


# Starting up nodejs server on localhost:3000
echo " - Starting app using Grunt"
grunt