#!/bin/bash

function _fetch_bytxt_MTR() {

#Format by __MTR_Listing: 
#  echo $(expr substr `expr 1000 + $LCNT` 2 3 )"|"$title"|"$url"|"$date"|"$download
    local LCNT=1
    rm -f $LIST_FILE $LIST_FILE.raw
    while true ; do
	read FLR <&0
        EOF_FLR=$?
	if [ $EOF_FLR == 1 ] ; then break; fi
	sno="$(echo $FLR | gawk -F '|' '{print $1}')"
	title="`echo $FLR | gawk -F "|" '{print $2}'`"
	url=`echo $FLR | gawk -F "|" '{print $3}'`
	date_str="$(echo $FLR | gawk -F '|' '{print $4}')"
	echo $FLR >> $LIST_FILE.raw
        echo $date_str, $title, $url
	#echo $LIST_FILE 
	echo $(expr substr `expr 1000 + $LCNT` 2 3 )"|"$title | tee -a $LIST_FILE
	#echo $FLR | tee -a $LIST_FILE
	#curl  $VERBOSE --connect-timeout 30  $url  --output $TCT_LOCATION/$LCNT 
	#echo return code: $?
	wget --quiet $url \
	   --output-document $MTR_LOCATION/$LCNT 
	LCNT=$(expr $LCNT + 1)
    done
}

__MTR_Listing() {

    local LCNT=1
    local FLR=""
    while true ; do

	read FLR <&0
        EOF_FLR=$?
	if [ $EOF_FLR == 1 ] ; then break; fi
	date="$(echo $FLR | gawk -F '|' '{print $1}')"
	title="$(echo $FLR | gawk -F '|' '{print $2}')"
	url="$(echo $FLR | gawk -F '|' '{print $3}')"
	down="$(echo $FLR | gawk -F '|' '{print $4}')"
		
	echo -n "." >&2
        echo $(expr substr `expr 1000 + $LCNT` 2 3 )"|"$title"|"$url"|"$date"|"$download
	LCNT=`expr $LCNT + 1`
    done
    echo "" >&2
}

__MTR_ht2PreFormat() {
    local LCNT=1
    local FLR=""
    while true ; do

	read FLR <&0
        EOF_FLR=$?
	if [ $EOF_FLR == 1 ] ; then break; fi
	date="$(date --date="$(echo $FLR | gawk -F '|' '{print $1}')" +%Y%m%d)"
	url_title="$(echo $FLR | gawk -F '|' '{print $2}')"
	url="$(echo $url_title  | gawk -F '"' '{print $2}')"	
	title="$(echo $url_title  | gawk -F '>' '{print $2}'|sed -e 's/<.*$//g' -e 's/^ //g')"	
	download="$(echo $FLR | gawk -F '|' '{print $3}' | gawk -F '"' '{print $2}')"
		
	echo -n "." >&2
        #echo $date"|"$(expr substr `expr 1000 + $LCNT` 2 3 )"|"$title"|"$url"|"$date"|"$download
        echo $date"|"$title"|"$url"|"$download
	LCNT=`expr $LCNT + 1`
    done
    echo "" >&2
}

__MTR_ht2PreListing() {
    local SOURCE_F=$1
    local TABLE_PROG=$2

    cat $SOURCE_F | sed -e 's/標題/title/g' -e 's/作者單位/authunit/g' -e 's/作者/author/g' \
	-e 's/刊登日期/pubdate/g'  -e 's/出版年月/pubdate/g' -e 's/下載/download/g' > temp-mtr.html
    cat temp-mtr.html | perl $TABLE_PROG | \
	 tr '#' '\n' | sed -e "s|DocView|$MTR_URL\/DocView|g" -e "s|DocDnld\.aspx|$MTR_URL\/Docdnld.aspx|g"
}

function fetch_news_list_MTR() {

    #ORIG_FILE=$MTR_NEWS_LIST_RESULT
   
    LIST_FILE="./$MTR_NEWS_LOC/`date +%Y%m%d`".listing
    mkdir -p $MTR_LOCATION
    local today_str="`date +%Y%m%d`"

    _logging "Function -> $FUNCNAME()" "MTR_LOCATION: $MTR_LOCATION"

    (__MTR_ht2PreListing $MTR_NEWS_LIST_RESULT1 tb-mtr.pl | sed 's/$/|/g' ; \
		__MTR_ht2PreListing $MTR_NEWS_LIST_RESULT2 tb-mtr2.pl ; \
		__MTR_ht2PreListing $MTR_NEWS_LIST_RESULT3 tb-mtr2.pl ) | \
         __MTR_ht2PreFormat | egrep -i "^$today_str" | \
	 __MTR_Listing | tee $MTR_NEWS_LISTING

	 cat $MTR_NEWS_LISTING | _fetch_bytxt_MTR
}

function setting_MTR() {

    # Begin other CFG of "$WNS_CONFIG".............................................................
    MTR_LOCATION="./$MTR_NEWS_LOC/`date +%Y%m%d`"
    MTR_URL=http://$MTR_SITE

    MTR_COOKIE_JAR=
    
    _LOCATION=$MTR_LOCATION

    _NEWS_LIST_URL=$MTR_NEWS_LIST_URL
    _NEWS_LIST_RESULT=$MTR_NEWS_LIST_RESULT

    _COOKIE_JAR=$MTR_COOKIE_JAR

    _NEWS_REPORT=$MTR_LOCATION.listing
}

function MTR() {

    _logging 'PHASE II: GET NEWS LISTING'
    MTR_NEWS_LIST_URL1=$MTR_PAG1
    MTR_NEWS_LIST_URL2=$MTR_PAG2
    MTR_NEWS_LIST_URL3=$MTR_PAG3
    MTR_NEWS_LIST_RESULT1=$WNS_LOG/MTR_NEWS_LIST.result1
    MTR_NEWS_LIST_RESULT2=$WNS_LOG/MTR_NEWS_LIST.result2
    MTR_NEWS_LIST_RESULT3=$WNS_LOG/MTR_NEWS_LIST.result3
    MTR_NEWS_LISTING=$WNS_LOG/MTR_NEWS_LISTING

    _NEWS_LIST_URL=$MTR_NEWS_LIST_URL1
    _NEWS_LIST_RESULT=$MTR_NEWS_LIST_RESULT1
    echo _NEWS_LIST_URL: $_NEWS_LIST_URL
    fetch_news_list_report

    _NEWS_LIST_URL=$MTR_NEWS_LIST_URL2
    _NEWS_LIST_RESULT=$MTR_NEWS_LIST_RESULT2
    echo _NEWS_LIST_URL: $_NEWS_LIST_URL
    fetch_news_list_report

    _NEWS_LIST_URL=$MTR_NEWS_LIST_URL3
    _NEWS_LIST_RESULT=$MTR_NEWS_LIST_RESULT3
    echo _NEWS_LIST_URL: $_NEWS_LIST_URL
    fetch_news_list_report

    _logging 'PHASE III: FETCH NEWS'
    fetch_news_list_MTR

    _logging 'PHASE V: Transfer HTML to TEXT'
    transfer_ht2txt
    _logging 'PHASE V: Transfer HTML to RTF'
    transfer_txt2rtf
}


