
mkdir -p ~/opt/bin

tar -c ./bin | tar xv -C $OPT_D

mkdir -p ~/opt/profile

tar -c ./profile | tar -xv -C $OPT_D

$OPT_D/profile/profile_env.d/00chk_localrc.sh


mkdir -p ~/opt/share
tar -c ./share | tar -x -C $OPT_D
