
#WEBTAR_D=`pwd`/webtar
#BIN_D=`pwd`/bin
#TMP_D=`pwd`/tmp
. opt.cfg.sh

export WEBTAR_D BIN_D TMP_D
mkdir -p $WEBTAR_D
mkdir -p $BIN_D
mkdir -p $TMP_D

TMP=/tmp


if [ "$1". == "". ] ; then
   ./pcainfo.sh
   ./zh-autoconvert.sh
   ./js-mod.sh
   ./ydict.sh
else

   if [ -e ./"$1" ] ; then
	. ./"$1"
   else
	echo Build script $1 not found.
   fi
fi
