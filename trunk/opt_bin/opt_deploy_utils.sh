#!/bin/bash

pushd `pwd`

if [[ ! -e ../opt_utils ]]; then

	svn co http://op2ls.googlecode.com/svn/trunk/opt_utils ../opt_utils --username $goocode_usr --password $goocode_pwd
	
fi

mkdir -p ~/opt/utils
cd ../opt_utils
tar c ./ | tar xv --directory $OPT_D/utils

popd
