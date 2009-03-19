#!/bin/bash

function _fetch_bytxt_PCB() {

#Format by __PCB_Listing: 
#  echo $(expr substr `expr 1000 + $LCNT` 2 3 )"|"$title"|"$url"|"$date"|"$download
    local LCNT=1
    rm -f $LIST_FILE $LIST_FILE.raw
    while true ; do
	read FLR <&0
        EOF_FLR=$?
	if [ $EOF_FLR == 1 ] ; then break; fi
	title="`echo $FLR | gawk -F "|" '{print $1}'`"
	url=`echo $FLR | gawk -F "|" '{print $2}'`
	#echo $LIST_FILE 
	echo $(expr substr `expr 1000 + $LCNT` 2 3 )"|"$title | tee -a $LIST_FILE
	#echo $FLR | tee -a $LIST_FILE
	curl  $VERBOSE --connect-timeout 30 --location  $url  --output $PCB_LOCATION/$LCNT 
	#echo return code: $?
	#curl --quiet $url \
	#   --output $PCB_LOCATION/$LCNT 
	LCNT=$(expr $LCNT + 1)
    done
}


__PCB_report_raw() {

    #local CHS_UTF8_HTML=g.html
    #local CHS_HTML=h.html
    #local CHT_HTML=i.html
    #local RAW_REPORT1=j.html

    local CHS_UTF8_HTML="`mktemp`"
    local CHS_HTML="`mktemp`"
    local CHT_HTML="`mktemp`"
    local RAW_REPORT1="`mktemp`"

    cat $_NEWS_LIST_RESULT | piconv -f gb2312 -t utf-8 > $CHS_UTF8_HTML

    #raw2listing
    egrep '(DIV.*09-| ・\[)' $CHS_UTF8_HTML | \
	sed -e 's/ # \[//g'  -e 's/<DIV.*t>//g' -e 's/<\/DIV>//g' > $CHS_HTML

    cat $CHS_HTML | piconv -f utf-8 -t gb2312 | \
	autob5 | piconv -f big5 -t utf-8 | sed 's/>$/><BR>#/g'  > $CHT_HTML
    cat $CHT_HTML | tr '\n' '$' | tr '#' '\n' | \
	sed -e 's/$//g' -e 's/^[ \t]*//g' -e 's/\$[ \t]*//g' > $RAW_REPORT1

    #cygstart j.html
    local today_str="`date --date="1 day ago" +%y-%m-%d`"

    cat $RAW_REPORT1 | grep -i $today_str | gawk -F 'nbsp;' '{print $2}' | sort | \
	sed -e '/./,/^$/!d' -e 's/<\/a.*$//g' -e "s|<a href='|$PCB_SITE|g" -e "s/html'/html/g" | \
        gawk -F '>' '{print $2"|"$1}'

    rm -f "$CHS_UTF8_HTML" "$CHS_HTML" "$CHT_HTML" "$RAW_REPORT1"

}

function fetch_news_list_PCB() {

    #ORIG_FILE=$PCB_NEWS_LIST_RESULT
   
    LIST_FILE="./$PCB_NEWS_LOC/`date +%Y%m%d`".listing
    mkdir -p $PCB_LOCATION
    local today_str="`date +%Y%m%d`"

    _logging "Function -> $FUNCNAME()" "PCB_LOCATION: $PCB_LOCATION"

    __PCB_report_raw | tee $today_str.listing.raw

    cat $today_str.listing.raw | _fetch_bytxt_PCB

    mv $today_str.listing.raw "$PCB_NEWS_LOC"

}

function setting_PCB() {

    # Begin other CFG of "$WNS_CONFIG".............................................................
    PCB_LOCATION="./$PCB_NEWS_LOC/`date +%Y%m%d`"
    PCB_URL=http://$PCB_SITE

    PCB_COOKIE_JAR=
    PCB_NEWS_LIST_URL=$PCB_URL/
    PCB_NEWS_LIST_RESULT=$WNS_LOG/PCB_NEWS_LIST.result
 
    _LOCATION=$PCB_LOCATION

    _NEWS_LIST_URL=$PCB_NEWS_LIST_URL
    _NEWS_LIST_RESULT=$PCB_NEWS_LIST_RESULT

    _COOKIE_JAR=$PCB_COOKIE_JAR

    _NEWS_REPORT=$PCB_LOCATION.listing
}

function PCB() {

    _logging 'PHASE II: GET NEWS LISTING'
    fetch_news_list_report

    _logging 'PHASE III: FETCH NEWS'
    fetch_news_list_PCB

    _logging 'PHASE V: Transfer HTML to TEXT'
    transfer_ht2txt4 "gb2312"
    _logging 'PHASE V: Transfer HTML to RTF'
    transfer_txt2rtf
}


