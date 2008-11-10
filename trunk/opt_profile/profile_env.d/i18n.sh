
if [ $OSTYPE. == cygwin. ] ; then

    if  [ ! $TERM. = cygwin. ] ; then
	if [  $SSH_TTY. = . ] ; then
    	    LANG="zh_TW.BIG5"
	else
    	    LANG="zh_TW.UTF-8"
	fi
        SUPPORTED="zh_TW.Big5:zh_TW:zh"
    else
	LANG="zh_TW.Big5"
    fi
else
    if [[ $OSTYPE == linu-gnu ]]; then
    
    	LANG="zh_TW.Big5"
    	SUPPORTED="zh_TW.Big5:zh_TW:zh"
    fi
fi
export LANG SUPPORTED
  
