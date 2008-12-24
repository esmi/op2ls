#!/bin/bash

OVPN_DIR=$HOME/PRGS/OpenVPN

$OVPN_DIR/bin/tapinstall install \
    "`cygpath -w $OVPN_DIR/driver/OemWin2K.inf`" tap0901

DEV_ORIG="區域連線"
DEV_NAME="`echo $DEV_ORIG | piconv -f UTF-8 -t big5`"
DEV_NEW="TAPN"

echo rename device name from $DEV_NAME to $DEV_NEW, please wait.
netsh interface set interface name="$DEV_NAME" newname="$DEV_NEW"

