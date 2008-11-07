
#WEBTAR_D=`pwd`/webtar
#BIN_D=`pwd`/bin
#TMP_D=`pwd`/tmp

. opt.cfg.sh

export WEBTAR_D BIN_D TMP_D
mkdir -p $WEBTAR_D
mkdir -p $BIN_D
mkdir -p $TMP_D
mkdir -p $LOG_D

TMP=/tmp


if [ "$1". == "". ] ; then

  for i in `find *.sh -maxdepth 1 | sed 's/^\.\///g' | sed 's/^\./ROOT_DIR/g' |egrep -v '(^opt|build|svn|ROOT_DIR)'` ; do
	echo '>>>> RUN ' $i SCRIPT........ | tee -a $LOG_D/opt_bin.log
	echo "Please wait $i script to done...."

	 ./$i >> $LOG_D/opt_bin.log
	
#   ./pcainfo.sh
#   ./zh-autoconvert.sh
#   ./js-mod.sh
#   ./ydict.sh
  done
else

   if [ -e ./"$1" ] ; then
	. ./"$1"
   else
	echo Build script $1 not found.
   fi
fi
