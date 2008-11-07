#!/bin/bash


ROOT=..
SRC_D=$(basename `pwd`)
BUILD_D=../bin_build

echo Create build directory: $BUILD_D
mkdir -p $BUILD_D

ln -sf $ROOT/$SRC_D/*.sh $BUILD_D
cd  $BUILD_D


. opt_make.sh $1

if [ "$1". == "". ]; then

   . opt_deploy.sh
   . opt_deploy_utils.sh
fi
