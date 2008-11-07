
pushd `pwd`
cd $TMP_D

FLODER=ydict
svn checkout http://copslb.googlecode.com/svn/trunk/ydict $FLODER

cd $FLODER

ln -s ydict.orig ydict
tar cv ./ydict.orig ydict | tar xv --directory "$BIN_D"

cd ..
rm -r -f $FLODER

popd

