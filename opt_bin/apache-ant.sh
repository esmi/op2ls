#!/bin/bash

get_apache-ant() {


  WORK_TAR=$WEBTAR_D/$package-$version-bin.tar.gz
  WEB_SRC=http://apache.stu.edu.tw/ant/binaries/$package-$version-bin.tar.gz

  if [ ! -e $WORK_TAR ] ; then 
     wget  $WEB_SRC -O $WORK_TAR
  fi
  
  pushd `pwd`

  cd $WORK_D

  if [ ! -e $WORK_D/$package-$version ] ; then
     tar -xzvf $WORK_TAR
  fi


  cd $package-$version

  tar -c bin etc lib | tar -xv --directory=$TARGET_dir 

  
  popd
  ln -sf ../share/ant/bin/ant ./bin/ant 
   echo `pwd`

  #echo $start_line $last_line $length 

}

DELETE_WORK_D="no"

. opt_package_main.sh

package=apache-ant
version=1.7.1
run_function=get_apache-ant

iam=$package.sh
caller=`basename $0`
echo $iam, $caller

WORK_D=$TMP_D

TARGET_dir=$SHARE_D/ant

if [ ! -d $TARGET_dir ] ; then
   mkdir -p $TARGET_dir
fi

package_main


