#!/bin/bash

#
# FILE:  utf8-alias.sh
# USAGE:  ./utf8-alias.sh 
# DESCRIPTION:  
# AUTHOR:   (), 
# CREATED:  12/05/08 16:35:04    
# $Id: $
#


if [ $OSTYPE. == cygwin. ] ; then
    echo $LANG | grep -i "utf" > /dev/null
    ret_value=$?

    if  [ $ret_value -eq 0 ] ; then
	#echo LANG is $LANG
	for cmd in ipconfig ping netstat net nslookup route netsh tracert; do
	    #echo $cmd
	    alias $cmd="u8 $cmd"
	done

    fi
fi
