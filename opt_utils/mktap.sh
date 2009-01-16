#!/bin/bash

OVPN_DIR=$HOME/PRGS/OpenVPN
TAPINSTALL=$OVPN_DIR/bin/tapinstall
DEV_TYPE=tap0901

function help() {
    cat	<<-EOF
	This script create or remove TAP device,
	    It require openssh tap-win32 intalld.

	Usage: $0 [ create [n | TAPNAME ] | remove | help ]
	    create: create [n] TAP device, and device name is TAPx.
	    remove: remove all TAP device.
	EOF
}

function remove() {
    $TAPINSTALL remove $DEV_TYPE
    echo remove TAP devices..
}


#function main()

case $1 in
test)
    DEV_ORIG="區域連線"
    DEV_NAME="`echo $DEV_ORIG | piconv -f UTF-8 -t big5`"
    DEV_NEW="TAP1"

    for i in `seq 1 $2` ; do
        DEV_NEW="TAP1"
	echo $DEV_NEW
    done 
    ;;
create)
    expr $2 + 0
    retval=$?

    if [ $retval == 2 ]; then
	echo TAP will rename to $2
	DEV_NEW=$2
	START_TAP=1
	LAST_TAP=1
	SPEC_NAME=1
    else
	START_TAP=$(expr "`netsh interface show interface | grep -i TAP |\
			sed 's/^.*TAP/TAP/g' | sort | tail -n 1 | sed -e 's/TAP//g'`" + 1 )
        if [ "$START_TAP". == "". ] ; then
	   START_TAP=1
	fi
        LAST_TAP=$(expr $2 + $START_TAP )
	#echo $START_TAP $LAST_TAP

        if [ ! $START_TAP -eq $LAST_TAP ] ; then
	   LAST_TAP=`expr $LAST_TAP - 1`
	fi
        #echo $START_TAP $LAST_TAP
    fi

    for i in `seq $START_TAP  $LAST_TAP` ; do
	befor_NICs=$(netsh interface show interface | expr $(wc -l) - 3 )
	#echo befor_NICs: $befor_NICs
	netsh interface show interface | tail -n $befor_NICs |  sed -e 's/^.*  //g' | sort > befor.nics

        $OVPN_DIR/bin/tapinstall install \
		"`cygpath -w $OVPN_DIR/driver/OemWin2K.inf`" $DEV_TYPE

	after_NICs=$(netsh interface show interface | expr $(wc -l) - 3 )
	#echo after_NICs: $after_NICs
	netsh interface show interface | tail -n $after_NICs |  sed -e 's/^.*  //g' | sort > after.nics
	
	#diff befor.devs after.devs
	#DEV_NAME="`echo "$DEV_ORIG" | piconv -f UTF-8 -t big5`"
	DEV_NAME="`diff befor.nics after.nics | tail -n 1 | sed -e 's/> //g'`"
	if [ "$SPEC_NAME". == "". ]; then
            DEV_NEW="TAP""`expr 100 + $i | cut -c 2,3`"
	fi
	#echo DEV_NEW: $DEV_NAME

	echo Rename device from "$DEV_NAME" to "$DEV_NEW", please wait...
        netsh interface set interface name="$DEV_NAME" newname="$DEV_NEW"
    done
    rm -f befor.nics after.nics
    ;;
remove)
    remove
    ;;
help)
    help
    ;;
*)
    help 
    ;;
esac

