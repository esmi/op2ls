
#WEBTAR_D=`pwd`/webtar
#BIN_D=`pwd`/bin
#TMP_D=`pwd`/tmp
. opt.cfg.sh

export WEBTAR_D BIN_D TMP_D
mkdir -p $WEBTAR_D
mkdir -p $BIN_D
mkdir -p $TMP_D

TMP=/tmp

./pcainfo.sh
./zh-autoconvert.sh
./js-mod.sh
./ydict.sh
