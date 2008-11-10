
if [ $OSTYPE. == cygwin. ] ; then

   TRANSPATH="cygpath -w"
   POSIXPATH="cygpath "

   export USERHOME=`cygpath -u "$HOMEDRIVE/users/$USERNAME"`
   desktop="$USERHOME/Desktop"

   export desktop

   winsysdir=`cygpath 'c:\WINDOWS\system32'`
   alias winsysdir='cd "$winsysdir"'

   
   sharedocs="/cygdrive/c/Documents and Settings/All Users/Documents"
else
   TRANSPATH="echo "
   POSIXPATH="echo "
   
   PATH=/sbin:/usr/sbin:/usr/local/sbin:$PATH
   export PATH

   desktop="$HOME/Desktop"
   export desktop
   
   . $PROFILE_PATH/linux/kde-`hostname`.sh
fi
