#!/usr/bin/bash

#orig "ubuntu.sh":
#TAP_IF="TAP2"
#
#TAP_ADDR="192.168.200.10"
#TAP_MASK="255.255.255.0"
#TAP_GATWAY="10.7.2.48"
#
#HDA_IMAGE=ubuntu-8.10.dskimg
#MEMORY=1024
#
#netsh interface ipv4 \
#    set address name=$TAP_IF source=static \
#    addr=$TAP_ADDR mask=$TAP_MASK \
#    gateway=$TAP_GATWAY gwmetric=1
#
#qemu --64 -m $MEMORY \
#    -net nic,vlan=1 -net user,vlan=1 \
#    -net nic -net tap,ifname=$TAP_IF \
#    -hda $HDA_IMAGE -cdrom Ubuntu_6.06.1_i386.iso
##    -soundhw pcspk \
##qemu -cpu pentium3 -no-kqemu -m 1024 -hda $HDA_IMAGE -cdrom Ubuntu_6.06.1_i386.iso

# OPENVPN parameters for netsh 

#TAP_IF="TAP01"
#TAP_ADDR="192.168.200.10"
#TAP_MASK="255.255.255.0"
#MAC1=52:54:00:12:34:67

#MEMORY=1024
#IMAGE_PATH=/usr/src/qemu/ubuntu
#IMAGE=ubuntu-8.10.dskimg

#CDROM_PATH=$IMAGE_PATH
#CDROM_ISO='ubuntu-8.10-desktop-i386.iso'
##CDROM_ISO="Ubuntu_6.06.1_i386.iso" 
#CDROM="$CDROM_PATH/$CDROM_ISO"

#SRC_IMG="$IMAGE_PATH/src.qcow2"

##TAP_GATWAY="10.7.2.48"
INCLUDE_PATH=/usr/src/qemu/ubuntu
export SDL_VIDEO_X11_DGAMOUSE=1
source $INCLUDE_PATH/ubuntu-start.cfg


CONNECTED_IFS=`netsh interface ipv4 show interface | \
    egrep -iv '(disconnected|loopback|------|idx|^$)' | \
    grep -v $TAP_IF |sed 's/^.* //g' | sort | tail -n 1`

IS_BUSY_TAP=`netsh interface ipv4 show interface | \
    grep -v disconnect  | grep -i connect.*$TAP_IF | \
    sed -e 's/.* //g'`

TAP_IF_ISEXIST=`netsh interface ipv4 show interface | grep $TAP_IF`
if [ "$TAP_IF_ISEXIST". == "". ] ; then
    echo device: "$TAP_IF" is not exist, this device must be created.
    exit 1
fi

if [ $TAP_IF. == $IS_BUSY_TAP. ]; then
    echo Device busy: $TAP_IF is connected, can\'t setup $TAP_IF.

else
    case $1 in
    TAP*)
        MASTER_IF=$CONNECTED_IFS
	echo MASTER_IF: $MASTER_IF
	MASTER_IF_IP=`netsh interface ipv4 show address $MASTER_IF | \
			    grep -i 'IP' | sed -e 's/^.*://g' -e 's/ //g'`
        MASTER_IF_MASK=`netsh interface ipv4 show address $MASTER_IF | \
			    grep -i '/'  | sed -e 's/^.* //g' -e 's/)//g'`
        TAP_GATWAY=$MASTER_IF_IP

        netsh interface ipv4 \
	    set address name=$TAP_IF source=static \
	    addr=$TAP_ADDR mask=$TAP_MASK \
            gateway=$TAP_GATWAY gwmetric=1

	# netsh interface ipv4 set address ovpn static 192.168.200.10 255.255.255.0 10.7.2.34
	# netsh interface ipv4 set address $TAP_IF static $TAP_ADDR $TAP_MASK $TAP_GATWAY

	echo TAP device: $TAP_IF, addr: $TAP_ADDR, gatway: $TAP_GATWAY
	# eth0: TAP2
        qemu -m $MEMORY \
            -net nic -net tap,ifname=$TAP_IF \
            -hda "`cygpath -w $IMAGE_PATH/$IMAGE`" \
	    -hdb "`cygpath -w $SRC_IMG`" 
            #-cdrom "`cygpath -w $CDROM`" 
            #-cdrom "`cygpath -w $IMAGE_PATH/Ubuntu_6.06.1_i386.iso`" 
	;;
    VLAN*)
	# eth0: vlan
	#   -net socket,vlan=1,mcast=230.0.0.1:1234 \
        qemu -m $MEMORY \
	    -net nic,vlan=1,macaddr=$MAC1 \
	        -net socket,vlan=1,connect=localhost:1234 \
		-net socket,vlan=1,mcast=230.0.0.1:1234 \
            -cdrom "`cygpath -w $IMAGE_PATH/Ubuntu_6.06.1_i386.iso`" \
	    -hda "`cygpath -w $IMAGE_PATH/$IMAGE`"
	;;
    BOTH*)
	#eth0: TAP2, eth1: vlan
	qemu -m 64 \
            -net nic,vlan=1,macaddr=$MAC1 \
    		-net socket,vlan=1,listen=localhost:1234 \
            -net nic -net tap,ifname=$TAP_IF \
            -hda "`cygpath -w $IMAGE_PATH/$IMAGE`"
	;;
    *)
	echo Usage: $0 '[ TAP | VLAN | BOTH ]'
	;;
    esac
    #    -soundhw pcspk \
fi
