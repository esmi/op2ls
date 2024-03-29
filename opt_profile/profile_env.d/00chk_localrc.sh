

# Create symbolic links for $HOME directory:
# .profile, .bashrc, .vimrc, .inputrc

OPT_LOC=$HOME/opt/profile

if [ ! -e $HOME/.profile ] ; then
   ln -s $OPT_LOC/profile.sh $HOME/.profile
fi

echo -n '>>>> check rc files: '
for rc in "bashrc" "vimrc" "inputrc" ; do
   echo -n $rc ","
   if [ ! -e $HOME/.$rc ] ; then
      ln -s $OPT_LOC/$rc $HOME/.$rc
   fi
done
echo "."

