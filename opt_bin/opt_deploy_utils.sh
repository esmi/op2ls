#!/bin/bash

pushd `pwd`

if [ "$OPT_DEV". == "". ]; then
	. ./opt.cfg.sh
fi

if [ ! -e ../opt_utils ]; then

	if [[ "$goocode_usr". == "". ]]; then
		echo '!!! Env $goocode_usr not defined!'
		exit 1
	fi

	mkdir ../opt_utils
	svn co http://op2ls.googlecode.com/svn/trunk/opt_utils ../opt_utils \
		--username $goocode_usr --password $goocode_pwd
	
fi

mkdir -p $OPT_D/utils
cd ../opt_utils

tar c ./ --exclude=.svn --exclude=.*swp  | tar xv --directory $OPT_D/utils

popd

