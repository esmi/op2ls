
pushd `pwd`
cd $TMP_D

FLODER=js-mod-cygbuild
svn checkout http://js-mod-cygbuild.googlecode.com/svn/trunk/$FLODER $FLODER

cd $FLODER

./make.sh

cp js.exe "$BIN_D"

cd ..
rm -r -f $FLODER

popd

