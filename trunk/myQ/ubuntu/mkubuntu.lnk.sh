
LINK_NAME=UBUNTU
LOCATION="/usr/src/qemu/ubuntu"
QEMU_SCRIPT=ubuntu-x.sh


RUN_SCRIPT="$LOCATION/$QEMU_SCRIPT"
RUNNER=/usr/bin/bash
LAUNCHER_ARGS="--hide $RUNNER --rcfile $RUN_SCRIPT"
LAUNCHER=/usr/bin/cygstart


ICON_F=/usr/bin/run.exe

mkshortcut  -n "$LINK_NAME" \
	    -a "$LAUNCHER_ARGS" \
	    -i "$ICON_F" -j 0 \
	    "$LAUNCHER"
