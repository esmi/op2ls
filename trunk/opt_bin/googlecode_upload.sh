#!/bin/bash

get_googlecode_upload() {

  WORK_TAR=$WEBTAR_D/$package.tar.gz

  WEB_SRC=http://support.googlecode.com/svn/trunk/scripts/googlecode_upload.py
  DEST_D=./bin

  pushd `pwd`
  if [ ! -e $WORK_TAR ] ; then 

     echo get $WEB_SRC to $WORK_D/$package.py
     wget -q $WEB_SRC -O $WORK_D/$package.py
     chmod 755 $WORK_D/$package.py

     #     env LANG=C svn co $WEB_SRC $WORK_D
     cd $WORK_D
     tar -c ./ --exclude ./.[a-z]* | gzip -9 > $WORK_TAR
  fi
  popd


  #tar -xz --directory ./bin -f  $WORK_TAR
  tar -xz --directory $DEST_D -f  $WORK_TAR

  echo `pwd`
  if [ "$DELETE_WORK_TAR". == "yes". ]; then
	rm -f $WORK_TAR
  fi
  #echo $start_line $last_line $length 

}

DELETE_WORK_D="yes"                             # "yes" or "no"
DELETE_WORK_TAR="no"

. opt_package_main.sh

package=googlecode_upload
run_function=get_googlecode_upload

iam=$package.sh
caller=`basename $0`
echo $iam, $caller

WORK_D=$TMP_D/$package


package_main


