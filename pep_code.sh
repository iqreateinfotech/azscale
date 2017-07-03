#!/bin/bash

# change a run-time parameter If any errors in script then exit execution
#set -e

# Name of the environment file to be used for this environment
envfile=".env.qa"

# git repository url and branch
core_url=git@128.199.87.138:root/pepcore.git
branch=stage
#dax_url=git@128.199.87.138:root/uqdax.git

PEPCODEBASE="/home/muthu/testproject/workcicd/peptide"

################### CODE CHECKOUT PROCESS UQ CORE  ############################################

echo "Start the current release build to $PEPCODEBASE"

if [ -d "$PEPCODEBASE" ]; then

  # find the current folder is empty
  echo "Check Site folder empty or not"
  
 if [ $(find $PEPCODEBASE -maxdepth 0 -type d -empty 2>/dev/null) ]; then
      
  cd $PEPCODEBASE

  if ! [ -d "$PEPCODEBASE/.git" ]; then
    echo "git repository not found"
    echo "git repository :"$core_url
    git clone --no-checkout $core_url $PEPCODEBASE/.tmp 
    mv $PEPCODEBASE/.tmp/.git $PEPCODEBASE/
    rm -rf $PEPCODEBASE/.tmp
    cd $PEPCODEBASE
    git reset --hard HEAD
    
  fi
  
  cd $PEPCODEBASE/
  echo "Changed Directory to $PEPCODEBASE"

fi

 cd $PEPCODEBASE

if [ "$(ls -A)" ]; then
    echo "Directory already has data"   
    echo "git repository code pull from :"$core_url
    git checkout $branch
    # git fetch --all
    git checkout .
    git pull
   # git reset --hard origin/$branch
else
    echo "Empty Folder - checking out the files"
    echo "Clone project from $core_url"
    
    git clone $core_url $PEPCODEBASE
    git checkout $branch
fi

fi
