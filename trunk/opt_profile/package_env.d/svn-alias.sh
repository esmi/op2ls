#!/bin/bash

#
# FILE:  svn-alias.sh
# USAGE:  ./svn-alias.sh 
# DESCRIPTION:  修正 svn 訊息亂碼, 將執行svn 前轉為LANG=c
# AUTHOR:   (), 
# CREATED:  11/18/08 14:09:07    
# $Id: $
#

alias svn='env LANG=c svn'
