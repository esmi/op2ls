#!/bin/bash

get_profile() {

  WORK_TAR=$WEBTAR_D/$package.tar.gz

  WEB_SRC=http://op2ls.googlecode.com/svn/trunk/opt_profile

  PROFILE_D=profile

  pushd `pwd`
  if [ ! -e $WORK_TAR ] ; then 

     env LANG=C svn co $WEB_SRC $WORK_D
     cd $WORK_D
     tar -c ./ --exclude ./.[a-z]* | gzip -9 > $WORK_TAR
  fi
  popd

  mkdir -p $PROFILE_D

  tar -xz --directory $PROFILE_D -f  $WORK_TAR

  if [ -e ../data_env.d ] ; then
     cp ../data_env.d/* $PROFILE_D/data_env.d
  fi

  echo `pwd`
  if [ "$DELETE_WORK_TAR". == "yes". ]; then
	rm -f $WORK_TAR
  fi
  #echo $start_line $last_line $length 

}

DELETE_WORK_D="yes"                             # "yes" or "no"
DELETE_WORK_TAR="yes"

. opt_package_main.sh

package=profile
run_function=get_profile

iam=$package.sh
caller=`basename $0`
echo $iam, $caller

WORK_D=$TMP_D/$package


package_main


