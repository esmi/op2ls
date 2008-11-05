#!/bin/bash


ROOT=..
SRC_D=$(basename `pwd`)
BUILD_D=../build_bin

echo Create build directory: $BUILD_D
mkdir -p $BUILD_D

ln -s $ROOT/$SRC_D/*.sh $BUILD_D
cd  $BUILD_D

. opt_make.sh

. opt_deploy.sh

. opt_deploy_utils.sh
