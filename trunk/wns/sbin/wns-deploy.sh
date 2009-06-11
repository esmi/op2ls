#!/bin/bash

svn checkout http://op2ls.googlecode.com/svn/trunk/wns $HOME/wns/script

cd $HOME/wns
mkdir FETCH  LOG  REPORT  TABLES  WNS_RTF

cd $HOME/wns/script
mkdir wns_log

#install perl module...
source  cpan-wns-install.sh

# install wns.cfg
