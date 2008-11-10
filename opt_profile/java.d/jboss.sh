


#JBOSS_PROFILE=all
#JBOSS_PROFILE=minimal
JBOSS_CONFIGURATION=default

JBOSS_HOME=`  $TRANSPATH "$JBOSS_HOME_PREFIX"/jboss`
JBOSS_BIN=`   $POSIXPATH  $JBOSS_HOME/bin`
JBOSS_CLIENT=`$POSIXPATH  $JBOSS_HOME/client`
JBOSS_SERVER=`$POSIXPATH  $JBOSS_HOME/server/$JBOSS_CONFIGURATION`
JBOSS_DEPLOY=`$POSIXPATH  $JBOSS_SERVER/deploy`
JBOSS_JDBC_EXAMPLES=` $POSIXPATH $JBOSS_HOME/docs/examples/jca`

export JBOSS_HOME JBOSS_DEPLOY JBOSS_SERVER 

# $JBOSS_CLIENT/jbossall-client.jar 此檔案包含所有client所需的classes.

CLASSPATH="$CLASSPATH"';'`$TRANSPATH $JBOSS_CLIENT/jbossall-client.jar`


alias jboss_start='$JBOSS_BIN/run.sh -c $JBOSS_CONFIGURATION 2>&1 > $JBOSS_BIN/run.log &'
alias jboss_stop='$JBOSS_BIN/shutdown.sh -S'
alias jboss_shlog='tail $JBOSS_BIN/run.log'
