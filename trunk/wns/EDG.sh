#!/bin/bash

function _fetch_bytxt_EDG() {

    local LCNT=1
    rm -f $LIST_FILE $LIST_FILE.raw
    while true ; do
	read FLR <&0
        EOF_FLR=$?
	if [ $EOF_FLR == 1 ] ; then break; fi
	date_str="$(echo $FLR | gawk -F '|' '{print $1}')"
	time_str="$(echo $FLR | gawk -F '|' '{print $2}')"
	title="`echo $FLR | gawk -F "|" '{print $3}'`"
	url=`echo $FLR | gawk -F "|" '{print $4}'`
	echo $FLR >> $LIST_FILE.raw
        echo $date_str, $title, $url
	#echo $LIST_FILE 
	echo $(expr substr `expr 1000 + $LCNT` 2 3 )"|"$title | tee -a $LIST_FILE
	#echo curl  $VERBOSE  $url  --output $EDG_LOCATION/$LCNT 
	wget --quiet $url \
	   --output-document $EDG_LOCATION/$LCNT 
	LCNT=$(expr $LCNT + 1)
    done
}

function _rss2txt_formatter_EDG() {
    while true ; do
	read FLR <&0
        EOF_FLR=$?
	if [ $EOF_FLR == 1 ] ; then break; fi
	date_str="$(date --date="`echo $FLR | gawk -F "|" '{print $1}'`" +%Y%m%d"|"%X)"
	title="`echo $FLR | gawk -F "|" '{print $2}'`"
	url=`echo $FLR | gawk -F "|" '{print $3}'`
	other=`echo $FLR | gawk -F "|" '{print $4}'`
        echo $date_str"|"$title"|"$url"|"$other
    done
}

function fetch_news_list_EDG() {

    #ORIG_FILE=$EDG_NEWS_LIST_RESULT
   
    LIST_FILE="./$EDG_NEWS_LOC/`date +%Y%m%d`".listing
    mkdir -p $EDG_LOCATION
    local today_str="`date --date="1 day ago" +%Y%m%d`"

    _logging "Function -> $FUNCNAME()" "EDG_LOCATION: $EDG_LOCATION"

	 #perl ./rss2list.pl ./wns_log/EDG_NEWS_LIST.result2 ;\
	 #perl ./rss2list.pl ./wns_log/EDG_NEWS_LIST.result3 ;\
	 #perl ./rss2list.pl ./wns_log/EDG_NEWS_LIST.result4 ;\
    (perl ./rss2list.pl ./wns_log/EDG_NEWS_LIST.result ;\
	 ) 2>/dev/null |\
	 _rss2txt_formatter_EDG | grep ^$today_str | _fetch_bytxt_EDG
   # perl ./EDG-list.pl $EDG_NEWS_LIST_RESULT 2>/dev/null | \
	# _rss2txt_formatter_EDG | grep ^$today_str | _fetch_bytxt_EDG
}

function setting_EDG() {

    # Begin other CFG of "$WNS_CONFIG".............................................................
    EDG_LOCATION="./$EDG_NEWS_LOC/`date +%Y%m%d`"
    EDG_URL=http://$EDG_SITE

    EDG_COOKIE_JAR=
    
    _LOCATION=$EDG_LOCATION

    _NEWS_LIST_URL=$EDG_NEWS_LIST_URL
    _NEWS_LIST_RESULT=$EDG_NEWS_LIST_RESULT

    _COOKIE_JAR=$EDG_COOKIE_JAR

    _NEWS_REPORT=$EDG_LOCATION.listing
}

function EDG() {

    _logging 'PHASE II: GET NEWS LISTING'
    EDG_NEWS_LIST_URL1=$EDG_RSS1
    EDG_NEWS_LIST_RESULT1=$WNS_LOG/EDG_NEWS_LIST.result

    _NEWS_LIST_URL=$EDG_RSS1
    _NEWS_LIST_RESULT=$EDG_NEWS_LIST_RESULT1
    echo _NEWS_LIST_URL: $_NEWS_LIST_URL
    fetch_news_list_report

    _logging 'PHASE III: FETCH NEWS'
    fetch_news_list_EDG


    _logging 'PHASE V: Transfer HTML to TEXT'
    transfer_ht2txt
    _logging 'PHASE V: Transfer HTML to RTF'
    transfer_txt2rtf
}


