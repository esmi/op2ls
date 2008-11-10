

##
##  KeyChain.sh
##

KVER=`keychain --version 2>&1 | grep -i keychain | gawk '{print $2}' | sed 's/;//g'`

if  [ ! $TERM. = cygwin. ] ; then
  
   if [ ! $SSH_TTY. = . ] ; then

	KEYCHAIN_DIR=$HOME/.keychain/ssh

	if [ ! -d $KEYCHAIN_DIR ] ; then
	    mkdir -p $KEYCHAIN_DIR
	    chmod 700 $KEYCHAIN_DIR
	fi
   else 
	KEYCHAIN_DIR=$HOME/.keychain
   fi


   if [ $KVER. = 2.6.8. ] ; then
	AGENT_FILE=$KEYCHAIN_DIR/${HOSTNAME}-sh
   else
	AGENT_FILE=$HOME/.ssh-agent-${HOSTNAME}
   fi

   #echo KEYCHAIN_DIR: $KEYCHAIN_DIR, AGENT_FILE: $AGENT_FILE

   #echo rxvt console mode.

   if [ -e ${AGENT_FILE} ]; then

         CURR_AGENT_PID=`pidof "ssh-agent" 2> /dev/null`
	 
         eval `cat ${AGENT_FILE}`

	 #echo CURR_AGENT_PID: $CURR_AGENT_PID
	 #echo SSH_AGENT_PID: $SSH_AGENT_PID

	 if [ ! "$CURR_AGENT_PID". = "$SSH_AGENT_PID". ] ; then

		rm -f $SSH_AUTH_SOCK
		if [ -d `dirname $SSH_AUTH_SOCK` ]; then
		    rmdir `dirname $SSH_AUTH_SOCK`
		fi
		#keychain -k
		echo "Key chain directory: " $KEYCHAIN_DIR
		keychain --dir $KEYCHAIN_DIR $HOME/.ssh/id_rsa
		eval `cat ${AGENT_FILE}`
	 fi
   else

	 echo "Key shelll files not found. Key chain directory: " $KEYCHAIN_DIR
         keychain --dir $KEYCHAIN_DIR $HOME/.ssh/id_rsa
         eval `cat ${AGENT_FILE}`
   fi
#  else

#      SESSIONNAME=terminal
#      export SESSIONNAME
#  fi
   #echo ssh_tty: $SSH_TTY
else
   echo console mode actived.
fi


