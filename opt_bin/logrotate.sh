#!/bin/bash

make_logrotate()
{

  LOGROTATE=logrotate_3.7.1
  DIFF_FILE=$LOGROTATE-3.diff.gz
  SRC_DIR=logrotate-3.7.1
  SRC_HOST=http://ftp.debian.org/debian/pool/main/l/logrotate
  SRC_TAR=$LOGROTATE.orig.tar.gz
  EXE_FILE1=logrotate.exe
  WORK_D=logrotate

  pushd `pwd`

  if [ -e $TMP_D ]; then
	cd $TMP_D
  fi
  if [ ! -d  $WORK_D ] ; then
	mkdir -p $WORK_D
  fi

  cd $WORK_D

  if [ ! -e $WEBTAR_D/$SRC_TAR ] ; then
	wget $SRC_HOST/$SRC_TAR -O $WEBTAR_D/$SRC_TAR
  fi

  if [ ! -e $WEBTAR_D/$DIFF_FILE ] ; then
	wget $SRC_HOST/$DIFF_FILE -O $WEBTAR_D/$DIFF_FILE
  fi


  rm -r -f $SRC_DIR

  tar xzvf $WEBTAR_D/$LOGROTATE.orig.tar.gz

  zcat $WEBTAR_D/$DIFF_FILE | patch -p0


  for i in `cat $SRC_DIR/debian/patches/series | \
	egrep -v '(compressutime|manpage|man-sizetypo|man-333996|man-189243)'` ; do 
	echo $i ;cat  $SRC_DIR/debian/patches/$i | patch -p0  ; 
  done


  cd $SRC_DIR
  make

  if [ -e $EXE_FILE1 ] ; then
     cp $EXE_FILE1 $BIN_D
  fi

  #
  popd

}

iam=logrotate.sh
caller=`basename $0`
echo $iam, $caller

if [ "$caller". == "$iam". ]; then

	echo You can\'t run $iam itself.
	echo Please run \"build $iam\"

	if [ -e build ]; then
		./build $iam
	fi
else

	if [ "$OPT_DEV". == "". ]; then
		echo '<<< $OPT_DEV not defined'
	        . ./opt.cfg.sh
		set | grep _D
	fi

	make_logrotate

fi
