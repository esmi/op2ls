#!/bin/bash

get_run-parts() {

  WORK_TAR=$WEBTAR_D/run-parts.html

  WORK_TXT=$WORK_D/run-part.html.txt
  RUN_PARTS=$WORK_D/run-parts

  HTML2TEXT=w3m

  WEB_SRC=http://www.cygwin.com/ml/cygwin/2005-04/msg00751.html

  if [ ! -d $WORK_D ]; then
	mkdir -p $WORK_D
  fi

  if [ ! -e $WORK_TAR ]; then
  	echo Get source code from: $WEB_SRC.
  	wget -O $WORK_TAR $WEB_SRC
  fi

  #cat $WORK_TAR | lynx -stdin -dump | d2u > $WORK_TXT
  w3m -dump $WORK_TAR | d2u > $WORK_TXT 

  start_line=`grep -in '\-CUT HERE-'.*bash $WORK_TXT | sed 's/:.*//g'`
  last_line=`grep -in "END CUT HERE" $WORK_TXT | head -n 2 | tail -n 1 | sed 's/:.*//g'`
  last_line=`expr $last_line - 1`
  length=`expr $last_line - $start_line + 1`

  #echo $start_line, $last_line, $length
  
  echo Create $RUN_PARTS script file.

  cat $WORK_TXT | head -n $last_line | tail -n $length | sed 's/.*---#/#/g' > $RUN_PARTS
  chmod 755 $RUN_PARTS
  cp $RUN_PARTS  $BIN_D

  #echo $start_line $last_line $length 

}

. opt_package_main.sh

package=run-parts
run_function=get_run-parts

iam=$package.sh
caller=`basename $0`
echo $iam, $caller

WORK_D=$TMP_D/$package

package_main
