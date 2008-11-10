
# ANT
#ANT_PREFIX=/usr/local

#ANT_HOME=$ANT_PREFIX/apache-ant-1.5.4
#ANT_HOME=$ANT_PREFIX/ant

export ANT_OPTS="-Djwsdp.home="$TOMCAT" \
           -Dusername=admin -Dpassword=1q2w3e "

PATH=$ANT_HOME/bin:$PATH

