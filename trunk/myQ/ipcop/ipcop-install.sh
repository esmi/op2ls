QEMU_D=./qemu-20080810-windows
ISO_FILE=ipcop-1.4.15-install-cd.i386.iso
IPCOP_INST_IMG=ipcop.dsk
TAP_IF=OVPN

$QEMU_D/qemu -L $QEMU_D -boot d \
        -net nic,vlan=1 -net user,vlan=1 \
        -net nic -net tap,ifname=$TAP_IF \
	-hda $IPCOP_INST_IMG -cdrom $ISO_FILE
