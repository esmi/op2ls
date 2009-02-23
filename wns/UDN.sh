#!/bin/bash

function _fetch_bytxt_UDN() {

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
	#echo curl  $VERBOSE  $url  --output $UDN_LOCATION/$LCNT 
	wget --quiet $url \
	   --output-document $UDN_LOCATION/$LCNT 
	LCNT=$(expr $LCNT + 1)
    done
}

function _rss2txt_formatter_UDN() {
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

function fetch_news_list_UDN() {

    #ORIG_FILE=$UDN_NEWS_LIST_RESULT
   
    LIST_FILE="./$UDN_NEWS_LOC/`date +%Y%m%d`".listing
    mkdir -p $UDN_LOCATION
    local today_str="`date +%Y%m%d`"

    _logging "Function -> $FUNCNAME()" "UDN_LOCATION: $UDN_LOCATION"

    (perl ./rss2list.pl ./wns_log/UDN_NEWS_LIST.result1 ;\
	 perl ./rss2list.pl ./wns_log/UDN_NEWS_LIST.result2 ;\
	 perl ./rss2list.pl ./wns_log/UDN_NEWS_LIST.result3 ;\
	 perl ./rss2list.pl ./wns_log/UDN_NEWS_LIST.result4 ;\
	 ) 2>/dev/null |\
	 _rss2txt_formatter_UDN | grep ^$today_str | _fetch_bytxt_UDN
   # perl ./UDN-list.pl $UDN_NEWS_LIST_RESULT 2>/dev/null | \
	# _rss2txt_formatter_UDN | grep ^$today_str | _fetch_bytxt_UDN
}

function setting_UDN() {

    # Begin other CFG of "$WNS_CONFIG".............................................................
    UDN_LOCATION="./$UDN_NEWS_LOC/`date +%Y%m%d`"
    UDN_URL=http://$UDN_SITE

 #?   UDN_NEWS_LIST_URL=http://rss.chinatimes.com/rss/technology-u.rss
 #?   UDN_NEWS_LIST_RESULT=$WNS_LOG/UDN_NEWS_LIST.result

    UDN_COOKIE_JAR=
    
    _LOCATION=$UDN_LOCATION

    _NEWS_LIST_URL=$UDN_NEWS_LIST_URL
    _NEWS_LIST_RESULT=$UDN_NEWS_LIST_RESULT

    _COOKIE_JAR=$UDN_COOKIE_JAR

    _NEWS_REPORT=$UDN_LOCATION.listing
}

function UDN() {

    _logging 'PHASE II: GET NEWS LISTING'
    UDN_NEWS_LIST_URL1=$UDN_RSS1
    UDN_NEWS_LIST_URL2=$UDN_RSS2
    UDN_NEWS_LIST_URL3=$UDN_RSS3
    UDN_NEWS_LIST_URL4=$UDN_RSS4
    UDN_NEWS_LIST_RESULT1=$WNS_LOG/UDN_NEWS_LIST.result1
    UDN_NEWS_LIST_RESULT2=$WNS_LOG/UDN_NEWS_LIST.result2
    UDN_NEWS_LIST_RESULT3=$WNS_LOG/UDN_NEWS_LIST.result3
    UDN_NEWS_LIST_RESULT4=$WNS_LOG/UDN_NEWS_LIST.result4

    _NEWS_LIST_URL=$UDN_RSS1
    _NEWS_LIST_RESULT=$UDN_NEWS_LIST_RESULT1
    echo _NEWS_LIST_URL: $_NEWS_LIST_URL
#    fetch_news_list_report

    _NEWS_LIST_URL=$UDN_RSS2
    _NEWS_LIST_RESULT=$UDN_NEWS_LIST_RESULT2
    echo _NEWS_LIST_URL: $_NEWS_LIST_URL
#    fetch_news_list_report

    _NEWS_LIST_URL=$UDN_RSS3
    _NEWS_LIST_RESULT=$UDN_NEWS_LIST_RESULT3
    echo _NEWS_LIST_URL: $_NEWS_LIST_URL
#    fetch_news_list_report

    _NEWS_LIST_URL=$UDN_RSS4
    _NEWS_LIST_RESULT=$UDN_NEWS_LIST_RESULT4
    echo _NEWS_LIST_URL: $_NEWS_LIST_URL
#    fetch_news_list_report

    _logging 'PHASE III: FETCH NEWS'
    fetch_news_list_UDN

#    _logging 'PHASE IV: LOGOUT (NO LOGOUT )'
#    #logout_from_SITE

#    _logging 'PHASE V: Transfer HTML to TEXT'
    transfer_ht2txt
#    _logging 'PHASE V: Transfer HTML to RTF'
    transfer_txt2rtf
}


