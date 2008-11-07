#!/bin/bash


ROOT=..

SRC_D=$(basename `pwd`)
BUILD_D=../bin_build

echo Create build directory: $BUILD_D
mkdir -p $BUILD_D

if [ ! "$SRC_D". == "`basename $BUILD_D`". ] ; then
   ln -sf $ROOT/$SRC_D/*.sh $BUILD_D
fi

cd  $BUILD_D


. opt_make.sh $1

if [ "$1". == "". ]; then

   . opt_deploy.sh
   . opt_deploy_utils.sh
fi
