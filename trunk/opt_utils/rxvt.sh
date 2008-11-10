if [ "$SSH_TTY". = "". ] ; then

	rxvt -fn Gulimche-15 -bg black -fg white -e /bin/bash
else
        echo "SSH_TTY($SSH_TTY) mode is active, can't run this $0 GUI mode program!"
fi


