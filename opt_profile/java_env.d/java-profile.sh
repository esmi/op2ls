
# JAVA Profile setup scripts.

if [ $OSTYPE. == cygwin. ]; then

   ANT_HOME_PREFIX=/usr/local
   JAVA_HOME_PREFIX=/usr/local
   JBOSS_HOME_PREFIX=$HOME/java-apps
   
   JAVA_APPS=$HOME/java-apps

   JDK=j2sdk
   
   GCJ_CLASSPATH=/usr/share/java/libgcj-3.3.1.jar:./java-getopt-1.0.9.jar:./easynoter-0.1.1.jar
#   if [ ! -d  J: ] ; then
#      if [ $SSH_TTY. = . ] ; then
#         if [ -d $JAVA_APPS ] ; then
#            subst J: `cygpath -w $JAVA_APPS`
#		echo ""
#         fi
#      fi
#   fi
else

#   echo $OSTYPE
   
   JAVA_APPS_HOME=/usr/java
   
   ANT_HOME_PREFIX=$JAVA_APPS_HOME
   JAVA_HOME_PREFIX=$JAVA_APPS_HOME
   JBOSS_HOME_PREFIX=$JAVA_APPS_HOME
   JAVA_APPS=$JAVA_APPS_HOME

#   echo JAVA_HOME_PREFIX: $JAVA_HOME_PREFIX
   if [ -a $JAVA_APPS_HOME/jdk ] ;then
       JDK_PATH=jdk
   else
	   if [ -a $JAVA_APPS_HOME/j2sdk ] ; then
	       JDK_PATH=j2sdk
	   else
	       JDK_PATH=j2sdk
	   fi
   fi
fi

ANT_HOME=$ANT_HOME_PREFIX/ant

JAVA_HOME=`$TRANSPATH $JAVA_HOME_PREFIX/$JDK_PATH`

#echo JAVA_HOME: $JAVA_HOME

if [ ! $CATALINA_HOME. = . ] ; then
   CATALINA_HOME=`$TRANSPATH $CATALINA_HOME`
fi

APPS=$JAVA_APPS
export ANT_HOME JAVA_HOME CATALINA_HOME
export JAVA_APPS JAPPS

PATH=$PATH:`$POSIXPATH $JAVA_HOME/bin`

. $HOME/scripts/profile/java/classpath.sh
. $HOME/scripts/profile/java/tomcat.sh
. $HOME/scripts/profile/java/axis.sh
. $HOME/scripts/profile/java/ant.sh
. $HOME/scripts/profile/java/jboss.sh
. $HOME/scripts/profile/java/mssql2000.sh
. $HOME/scripts/profile/java/eclipse.sh


# JAVA RELATIVE ENVIRONMENT...
alias java='java -classpath "$WIN_CLASSPATH"'

# TOMCAT
WEBAPPS="$TOMCAT"/webapps
alias tomcat='cd "$TOMCAT"'

webapps="$TOMCAT"/webapps
mydocs="$TOMCAT"/webapps/evan/mydocs

alias mydocs='cd "$TOMCAT"/webapps/evan/mydocs'
alias webapps='cd "$TOMCAT"/webapps/'

# JPORTAL
alias jportal='cd $HOME/jportal'


if [ $OSTYPE. != cygwin. ] ; then

   CLASSPATH=`echo $CLASSPATH | sed 's/;/:/g'`
else

   WIN_CLASSPATH=$CLASSPATH';.\easynoter-0.1.1.jar'
   CYGWIN_CLASSPATH=$(echo $WIN_CLASSPATH | tr '\\' '\/' | sed "s/[cC]:/\/cygdrive\/c/g" | tr ';' ':')
   export WIN_CLASSPATH CYGWIN_CLASSPATH
fi

