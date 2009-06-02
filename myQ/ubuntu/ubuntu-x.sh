#!/bin/bash

PATH=./:/usr/bin/:$HOME/opt/utils:"$PATH"
/usr/src/qemu/ubuntu/ubuntu-start.sh TAP
cd $HOME
exit
