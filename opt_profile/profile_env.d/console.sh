
# File Name: console.sh
# Author: Evan Chen
# Date: 2003/10/07
# Docs: 此檔案被執行於shell,且與作業系統與程式有相關.
#
# $USERNAME 這個環境變量來自於 Winodos 所提供.
# $SESSIONNAME 此環境變量來自於 rxvt 這支程式.
#

if [ $SESSIONNAME. == Console. ] ; then

   alias start=cygstart

   # CYGWIN SETUP PROGRAM.
   if [ $TERM == cygwin ] ; then
      alias cygsetup='"`/bin/cygpath "E:\\Documents and Settings\\Administrator\\My Documents\\setup"`" & '
   else
      alias cygsetup='echo cygsetup cannot run on none-console mode!'
   fi


   USER_CONSOLE_SH=$HOME/scripts/profile/winapps/$USERNAME-console.sh

   if [ -e $USER_CONSOLE_SH ] ; then
	. $UESR_CONSOLE_SH
   else
	echo SCRIPT FILE: $UER_CONSOLE_SH  NOT EXIST.
   fi
   
else
   
   alias pu@lo='echo You are not in console mode, pu@lo cannot run.'
fi
