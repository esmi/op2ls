

gvi_debug() {

if [ $DEBUG == parameter ] ; then
    echo $*
fi
}

FILE_COUNT=$#
VIM_PATH=$HOME/opt/utils/gvim72-win32
GVIM_EXE=vim72/gvim.exe
GVI=$VIM_PATH/$GVIM_EXE

DEBUG=parameter
#DEBUG=nodebug
gvi_debug File Count: $FILE_COUNT

options=false
if [ $# -gt 0 ] ; then
    options=true
    gvi_debug 0 $options
    if [  ! -e $1 ] ; then
	options=false
    fi
fi
#GVIM_Portable_EXE=$VIM_PATH/$GVIM_EXE
gvi_debug '$1:' $1
gvi_debug $options

if [ "$options". = true. ] ; then
    echo $FILE_COUNT
    $GVI -v -C -u "`cygpath -w ~/.vimrc`"  -p \
			`cygpath -w $*` &
else
    $GVI -u "`cygpath -w ~/.vimrc`" $* &
fi
