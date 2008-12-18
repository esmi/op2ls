#!/bin/bash

create_openvpn_links() {

    OPENVPN_EXE=$HOME/ln/progfiles/OpenVPN/bin/openvpn
    WORK_TAR=$WEBTAR_D/$package.tar.gz

    WEB_SRC=NOTHINGS
    DEST_D=./bin

    pushd `pwd`
    if [ "$WEB_SRC" == "NOTHINGS" ] ; then
	if [ -x $OPENVPN_EXE ]; then
	    ln -s $OPENVPN_EXE $DEST_D
	else
	    echo OPENVPN EXECUTABLE FILE: $OPENVPN_EXE NOT EXIST!.
	    echo "OpenVPN may be not installed!, please install OpenVPN first"	    
	fi
    else
	echo "'>>>>>>'It is nothing, please check varable '$WEB_SRC' !"
	#if [ ! -e $WORK_TAR ] ; then 

	#    echo get $WEB_SRC to $WORK_D/$package.py
	#    wget -q $WEB_SRC -O $WORK_D/$package.py
	#    chmod 755 $WORK_D/$package.py

	#    cd $WORK_D
	#    tar -c ./ --exclude ./.[a-z]* | gzip -9 > $WORK_TAR
	#fi
	#tar -xz --directory $DEST_D -f  $WORK_TAR
    fi

    popd


    echo `pwd`
    if [ "$DELETE_WORK_TAR". == "yes". ]; then
	rm -f $WORK_TAR
    fi
}

DELETE_WORK_D="no"                             # "yes" or "no"
DELETE_WORK_TAR="no"

. opt_package_main.sh

#package=googlecode_upload
#run_function=get_googlecode_upload
package=openvpn_links
run_function=create_openvpn_links

iam=$package.sh
caller=`basename $0`
echo $iam, $caller

WORK_D=$TMP_D/$package


package_main


