#!/bin/bash

BUILD_ROOT=op2ls.d

HTTP=http://op2ls.googlecode.com/svn/trunk

echo -p "This script will download op2ls tools to your ~/opt/bin ~/opt/utils ~/opt/profile "
read -p "Are you should to do this script! [yes/no]: " acc
    
if [ "$acc". == "yes". ]; then
       
     pushd `pwd`
     if [ ! -e $BUILD_ROOT ]; then
	mkdir $BUILD_ROOT
     fi

     cd $BUILD_ROOT

     svn co $HTTP/opt_bin opt_bin
     svn co $HTTP/opt_utils opt_utils
     svn co $HTTP/opt_profile opt_profile
    
     cd opt_bin

     ./build.sh
     popd 

     echo ''
     echo '<<<<< Script jobs has been done!'
     echo '<<<<< You can drop work directory: '$BUILD_ROOT
     echo ''

fi
