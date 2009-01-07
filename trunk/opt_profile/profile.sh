pushd `pwd`

PATH=$HOME/bin:/bin:"$PATH"

ETC_D=$HOME/opt/etc
PROENV_D=$HOME/opt
DATA_ENV_D=$HOME/opt/profile/data_env.d
PROFILE_ENV_D=$HOME/opt/profile/profile_env.d
PACKAGE_ENV_D=$HOME/opt/profile/package_env.d
JAVA_ENV_D=$HOME/opt/profile/java_env.d

if [ -e ~/.bashrc ] ; then
   source ~/.bashrc
fi

for  profile  in "$PROFILE_ENV_D"/*.sh ; do
    echo '>>>>> PROFILE: ' $profile ...
    source $profile
done

for  package_file  in "$PACKAGE_ENV_D"/*.sh ; do
    echo '>>>>> PACKAGE: ' $package_file ...
    source $package_file
done

for  javaenv_file  in "$JAVA_ENV_D"/*.sh ; do
    echo '>>>>> JAVA: ' $javaenv_file ...
    source $javaenv_file
done

#.  $PKGENV_D/java-profile.sh

for data_file in "$DATA_ENV_D"/*.sh; do
    echo '>>>>> DATA: ' $data_file ...
    source $data_file
done

PATH=$HOME/opt/bin:$HOME/opt/ln:$HOME/opt/utils:$HOME/opt/wlutils:$PATH
export TMP=$HOME/tmp
export DATA_ENV_D

popd
