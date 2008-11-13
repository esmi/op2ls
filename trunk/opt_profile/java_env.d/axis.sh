
AXIS_PREFIX=`$TRANSPATH $CATALINA_HOME/webapps/axis/`
AXISPATH=`$TRANSPATH $AXIS_PREFIX/WEB-INF/lib/axis.jar`
AXISPATH="$AXISPATH"';'`$TRANSPATH $AXIS_PREFIX/WEB-INF/lib/commons-discovery.jar`
AXISPATH="$AXISPATH"';'`$TRANSPATH $AXIS_PREFIX/WEB-INF/lib/commons-logging.jar`
AXISPATH="$AXISPATH"';'`$TRANSPATH $AXIS_PREFIX/WEB-INF/lib/jaxrpc.jar`
AXISPATH="$AXISPATH"';'`$TRANSPATH $AXIS_PREFIX/WEB-INF/lib/saaj.jar`
AXISPATH="$AXISPATH"';'`$TRANSPATH $AXIS_PREFIX/WEB-INF/lib/log4j-1.2.4.jar`
AXISPATH="$AXISPATH"';'`$TRANSPATH $AXIS_PREFIX/WEB-INF/lib/xerces.jar`
AXISPATH="$AXISPATH"';'`$TRANSPATH $AXIS_PREFIX/WEB-INF/lib/wsdl4j.jar`

#echo $AXISPATH
#CLASSPATH="$AXISPATH"';'"$CLASSPATH"
   
# AXIS
alias AdminClient='java -classpath "$CLASSPATH" org.apache.axis.client.AdminClient'
alias Java2WSDL='java -classpath "$CLASSPATH" org.apache.axis.wsdl.Java2WSDL'
alias WSDL2Java='java -classpath "$CLASSPATH" org.apache.axis.wsdl.WSDL2Java'

