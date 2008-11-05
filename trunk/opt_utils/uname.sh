

uname -a; \
	echo KERNEL-NAME\(s\): `uname -s`; \
	 echo 'NODE-NAME(n):' "  `uname -n`";\
	 echo 'KERNEL-RELEASE(r):' `uname -r`; \
	 echo 'KERNEL-VERSION(v):' `uname -v`; \
	echo -e 'MACHINE(m):' `uname -m`; \
	echo -e 'OS(o):' \\t `uname -o`; \
	echo 'HARDWARE-PLATFORM(i):' `uname -i`;\
	 echo 'PROCESS(p):' `uname -p`

