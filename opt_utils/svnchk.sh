

for d in `find -maxdepth 1 -type d`; do

	if [ -e $d/.svn ]; then
		svn status $d
	fi
done
