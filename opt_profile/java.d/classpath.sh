

#JAVA_HOME=`$TRANSPATH /cygdrive/c/j2sdk1.4.1_02`

CLASSPATH=.';'`$TRANSPATH $JAVA_HOME/src.jar`
CLASSPATH="$CLASSPATH"';'`$TRANSPATH $JAVA_HOME/lib/dt.jar`
CLASSPATH="$CLASSPATH"';'`$TRANSPATH $JAVA_HOME/lib/tools.jar`
CLASSPATH="$CLASSPATH"';'`$TRANSPATH $JAVA_HOME/lib/jawt.lib`
CLASSPATH="$CLASSPATH"';'`$TRANSPATH $JAVA_HOME/lib/jvm.lib`

CLASSPATH="$CLASSPATH"';'`$TRANSPATH $JAVA_HOME/jre/lib/i18n.jar`
CLASSPATH="$CLASSPATH"';'`$TRANSPATH $JAVA_HOME/jre/lib/jawt.lib`
CLASSPATH="$CLASSPATH"';'`$TRANSPATH $JAVA_HOME/jre/lib/jaws.jar`
CLASSPATH="$CLASSPATH"';'`$TRANSPATH $JAVA_HOME/jre/lib/rt.jar`



export CLASSPATH
