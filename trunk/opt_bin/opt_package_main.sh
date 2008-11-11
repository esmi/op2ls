
function package_main()
{
   if [ "$caller". == "$iam". ]; then

	#echo You can\'t run $iam itself.
	#echo Please run \"build $iam\"

	if [ -e build.sh ]; then
		./build.sh $iam
	fi
   else

	if [ "$OPT_DEV". == "". ]; then
		echo '<<< $OPT_DEV not defined'
	        . ./opt.cfg.sh
		set | grep _D
	fi

	pushd `pwd`

	if [ ! -d  $WORK_D ] ; then
		mkdir -p $WORK_D
	fi

	if [ ! -d  $SHARE_D ] ; then
		mkdir -p $SHARE_D
	fi

	echo RUN $run_function
	$run_function

	popd

	#echo $DELETE_WORK_D
	if [ -e $WORK_D ] && [ "$OPT_CLEAR_WORK_D". == "CLEAR". ] && [ ! "$DELETE_WORK_D". == "no". ]; then
		
		echo CLEAR $WORK_D DIRECTORY $DELETE_WORK_D
		rm -rf $WORK_D
		
	fi
   fi
}

