#!/bin/bash

function _fetch_bytxt_EET() {

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
	#echo curl  $VERBOSE  $url  --output $EET_LOCATION/$LCNT 
	wget --quiet $url \
	   --output-document $EET_LOCATION/$LCNT 
	LCNT=$(expr $LCNT + 1)
    done
}

function _rss2txt_formatter_EET() {
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

function fetch_news_list_EET() {

    #ORIG_FILE=$EET_NEWS_LIST_RESULT
   
    LIST_FILE="./$EET_NEWS_LOC/`date +%Y%m%d`".listing
    mkdir -p $EET_LOCATION
    local today_str="`date +%Y%m%d`"

    _logging "Function -> $FUNCNAME()" "EET_LOCATION: $EET_LOCATION"

    (perl ./TCT-list.pl ./wns_log/EET_NEWS_LIST.result1 ;\
	 perl ./TCT-list.pl ./wns_log/EET_NEWS_LIST.result2 ;\
	 perl ./TCT-list.pl ./wns_log/EET_NEWS_LIST.result3 ;\
	 perl ./TCT-list.pl ./wns_log/EET_NEWS_LIST.result4 ;\
	 ) 2>/dev/null |\
	 _rss2txt_formatter_EET | grep ^$today_str | _fetch_bytxt_EET
   # perl ./EET-list.pl $EET_NEWS_LIST_RESULT 2>/dev/null | \
	# _rss2txt_formatter_EET | grep ^$today_str | _fetch_bytxt_EET
}

function setting_EET() {

    # Begin other CFG of "$WNS_CONFIG".............................................................
    EET_LOCATION="./$EET_NEWS_LOC/`date +%Y%m%d`"
    EET_URL=http://$EET_SITE

 #?   EET_NEWS_LIST_URL=http://rss.chinatimes.com/rss/technology-u.rss
 #?   EET_NEWS_LIST_RESULT=$WNS_LOG/EET_NEWS_LIST.result

    EET_COOKIE_JAR=
    
    _LOCATION=$EET_LOCATION

    _NEWS_LIST_URL=$EET_NEWS_LIST_URL
    _NEWS_LIST_RESULT=$EET_NEWS_LIST_RESULT

    _COOKIE_JAR=$EET_COOKIE_JAR

    _NEWS_REPORT=$EET_LOCATION.listing
}

function EET() {

    _logging 'PHASE II: GET NEWS LISTING'
    EET_NEWS_LIST_URL1=$EET_RSS1
    EET_NEWS_LIST_RESULT1=$WNS_LOG/EET_NEWS_LIST.result1

    _NEWS_LIST_URL=$EET_RSS1
    _NEWS_LIST_RESULT=$EET_NEWS_LIST_RESULT1
    echo _NEWS_LIST_URL: $_NEWS_LIST_URL
#    fetch_news_list_report

    _logging 'PHASE III: FETCH NEWS'
    fetch_news_list_EET

#    _logging 'PHASE IV: LOGOUT (NO LOGOUT )'
#    #logout_from_SITE

#    _logging 'PHASE V: Transfer HTML to TEXT'
    transfer_ht2txt
#    _logging 'PHASE V: Transfer HTML to RTF'
    transfer_txt2rtf
}


