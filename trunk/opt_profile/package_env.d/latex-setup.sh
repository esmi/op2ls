
TEXMF=/usr/share/texmf
export TEXMF

if [ $OSTYPE = cygwin. ]; then

   # TEXMF, LATEX, TEX Environment

   TEXMF_ROOT="/cygdrive/c/texmf/"

   MIKTEX="/usr/share/texmf/miktex"
   PATH="$PATH":"$MIKTEX/bin"

   CWTEX=`cygpath "c:/texmf/cwtex"`
   PATH="$PATH":"$CWTEX"
fi

   
