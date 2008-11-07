

if [ "$OPT_DEV". == "". ]; then
        . ./opt.cfg.sh
fi


HTTP=http://caspian.dotconf.net/menu/Software/SendEmail/

SRC=sendEmail
VERSION=v1.55
TYPE=.tar.gz

FOLDER=$SRC-$VERSION

FILE1="$SRC"-"$VERSION""$TYPE"

TARGET=$WEBTAR_D/"$FILE1"
WEBTAR="$HTTP"/"$FILE1"

if [ ! -e $TARGET ] ; then
# echo    wget $WEBTAR -O $TARGET
     wget $WEBTAR -O $TARGET
fi

pushd `pwd`
cd $TMP_D

tar -xzvf $TARGET

cd $FOLDER


if [ -e $SRC ] ; then
  cp $SRC $BIN_D
fi

popd

rm -rf $TMP_D/$FOLDER
