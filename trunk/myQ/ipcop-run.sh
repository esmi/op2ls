#!/usr/bin/bash
# this script run ipcop under qemu/cygwin/vista.
# it lacked a function to combine "ICS/internet connection sharing" function.

TAP_IF="TAP1"
TAP_ADDR="192.168.100.10"
TAP_MASK="255.255.255.0"
MAC0=52:54:00:12:34:47
MAC1=52:54:00:12:34:57
MEMORY=64

IMAGE=ipcop.dsk
IMAGE_PATH=/usr/src/qemu/ipcop

Q_IMAGE="`cygpath -w $IMAGE_PATH/$IMAGE`"

#--- End of parameters
IPV4_IFS="`netsh interface ipv4 show interface | d2u | tr '\n' ';'`"
#echo $IPV4_IFS

IS_BUSY_TAP=`echo $IPV4_IFS| tr ';' '\n'  | \
    grep -v disconnect  | grep -i connect.*$TAP_IF | \
    sed -e 's/.* //g'`

# check TAP_IF is busy?
if [ $TAP_IF. == $IS_BUSY_TAP. ]; then
    echo Device busy: $TAP_IF is connected, can\'t setup $TAP_IF.
else

    CONNECTED_IFS=`echo $IPV4_IFS | tr ';' '\n' | \
	egrep -iv '(disconnected|loopback|------|idx|^$)' | \
        grep -v $TAP_IF |sed 's/^.* //g' | sort | tail -n 1`

    MASTER_IF=$CONNECTED_IFS
    MASTER_IF_ADR=`netsh interface ipv4 show address $MASTER_IF | d2u | tr '\n' ';'`
    MASTER_IF_IP=`echo $MASTER_IF_ADR | tr ';' '\n' | grep -i 'IP' | sed -e 's/^.*://g' -e 's/ //g'`
    MASTER_IF_MASK=`echo $MASTER_IF_ADR| tr ';' '\n' | grep -i '/'  | sed -e 's/^.* //g' -e 's/)//g'`

    TAP_GATWAY=$MASTER_IF_IP
#   DEBUG INFO:
    echo MASTER_IF: $TAP_GATWAY $MASTER_IF_IP, $MASTER_IF_MASK, $MASTER_IF
    echo TAP_IF: $TAP_IF, $TAP_ADDR, $TAP_MASK, $TAP_GATWAY

#   netsh interface ipv4 set address $TAP_IF static 192.168.100.10 255.255.255.0 10.7.2.34
#   netsh interface ipv4 set address $TAP_IF static $TAP_ADDR $TAP_MASK $TAP_GATWAY

    netsh interface ipv4 \
        set address name=$TAP_IF source=static \
        addr=$TAP_ADDR mask=$TAP_MASK \
        gateway=$TAP_GATWAY gwmetric=1

    #-net user,vlan=1 \
    #-net socket,vlan=1,mcast=230.0.0.1:1234 \
    #-soundhw pcspk \

    qemu -m $MEMORY \
        -net nic,vlan=1,macaddr=$MAC1 \
		-net socket,vlan=1,listen=localhost:1234 \
        -net nic,macaddr=$MAC0 -net tap,ifname=$TAP_IF \
        -hda "$Q_IMAGE"

fi

