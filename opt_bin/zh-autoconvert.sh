

HTTP=http://ftp.de.debian.org/debian/pool/main/z/zh-autoconvert
SRC=zh-autoconvert
VERSION=0.3.16
TYPE=.orig.tar.gz

FOLDER=autoconvert-$VERSION

FILE1="$SRC"_"$VERSION""$TYPE"

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

cat <<EOF | patch Makefile
8c8,9
< all: autob5 autogb hzlib  xchat-plugins
---
> #all: autob5 autogb hzlib  xchat-plugins
> all: autob5 autogb hzlib
18,19c19,20
< xchat-plugins:
<       cd contrib/xchat-plugins;make
---
> #xchat-plugins:
> #     cd contrib/xchat-plugins;make
EOF

make

if [ -e autogb ] ; then
 tar c autogb.exe autob5 | tar xv -C $BIN_D
fi

popd

rm -rf $TMP_D/$FOLDER
