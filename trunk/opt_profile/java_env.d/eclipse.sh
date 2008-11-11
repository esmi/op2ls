ECLIPSE_HOME_PREFIX=$JAVA_APPS/eclipse

#echo $ECLIPSE_HOME_PREFIX

if [  -a $ECLIPSE_HOME_PREFIX/2.1.3/eclipse ]; then

    ECLIPSE_HOME="$ECLIPSE_HOME_PREFIX/2.1.3/eclipse"
    PATH="$ECLIPSE_HOME":$PATH
    export ECLIPSE_HOME

else
	
	if [ -a $ECLIPSE_HOME_PREFIX/3.0/eclipse ] ; then

	    ECLIPSE_HOME="$ECLIPSE_HOME_PREFIX/3.0/eclipse"
	    PATH="$ECLIPSE_HOME":$PATH
	    export ECLIPSE_HOME

	else
	    echo ECIPSE not install on this machine ....  >> $HOME/eclipse.log
	fi

fi
