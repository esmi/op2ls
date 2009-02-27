#--TCT
function _fetch_bytxt_TCT() {

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
	curl  $VERBOSE --connect-timeout 30  $url  --output $TCT_LOCATION/$LCNT 
	echo return code: $?
	#wget --quiet $url \
	#   --output-document $TCT_LOCATION/$LCNT 
	LCNT=$(expr $LCNT + 1)
    done
}

function _rss2txt_formatter_TCT() {

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


function fetch_news_list_TCT() {

    #ORIG_FILE=$TCT_NEWS_LIST_RESULT
   
    LIST_FILE="./$TCT_NEWS_LOC/`date +%Y%m%d`".listing
    mkdir -p $TCT_LOCATION
    local today_str="`date +%Y%m%d`"
    echo today_str: $today_str
    _logging "Function -> $FUNCNAME()" "TCT_LOCATION: $TCT_LOCATION"
    _logging "$FUNCNAME()-\$TCT_NEWS_LIST_RESULT: $TCT_NEWS_LIST_RESULT"

    # process preleading mis code on $TCT_NEW_LIST_RESULT
    ( head $TCT_NEWS_LIST_RESULT1 -n 1 | sed 's/^.*</</g' ; \
	 tail -n `wc -l $TCT_NEWS_LIST_RESULT1 | gawk '{print $1}'` $TCT_NEWS_LIST_RESULT1 ) \
	     > $TCT_NEWS_LIST_RESULT1.1
    ( head $TCT_NEWS_LIST_RESULT2 -n 1 | sed 's/^.*</</g' ; \
	 tail -n `wc -l $TCT_NEWS_LIST_RESULT2 | gawk '{print $1}'` $TCT_NEWS_LIST_RESULT2 ) \
	     > $TCT_NEWS_LIST_RESULT2.1
    ( head $TCT_NEWS_LIST_RESULT3 -n 1 | sed 's/^.*</</g' ; \
	 tail -n `wc -l $TCT_NEWS_LIST_RESULT3 | gawk '{print $1}'` $TCT_NEWS_LIST_RESULT3 ) \
	     > $TCT_NEWS_LIST_RESULT3.1
    ( head $TCT_NEWS_LIST_RESULT4 -n 1 | sed 's/^.*</</g' ; \
	 tail -n `wc -l $TCT_NEWS_LIST_RESULT4 | gawk '{print $1}'` $TCT_NEWS_LIST_RESULT4 ) \
	     > $TCT_NEWS_LIST_RESULT4.1

    (./rss2list.pl $TCT_NEWS_LIST_RESULT1.1; \
	./rss2list.pl $TCT_NEWS_LIST_RESULT2.1; \
	./rss2list.pl $TCT_NEWS_LIST_RESULT3.1; \
	./rss2list.pl $TCT_NEWS_LIST_RESULT4.1 ; ) 2>/dev/null | \
	 _rss2txt_formatter_TCT | grep ^$today_str | _fetch_bytxt_TCT
    #./rss2list.pl wns_log/TCT_NEWS_LIST_RESULT.2     
}

function setting_TCT() {

    # Begin other CFG of "$WNS_CONFIG".............................................................
    TCT_LOCATION="./$TCT_NEWS_LOC/`date +%Y%m%d`"
    #TCT_RSS_F=technology-u.rss
    TCT_URL=http://$DGT_SITE

    #TCT_LOCAL_SIGN_URL=lgn/check.asp

    #TCT_LOGIN_POST_URL=$DGT_URL/default.asp

    #TCT_LOGIN_POST_HEADER=$WNS_LOG/DGT_LOGIN_POST.header
    #TCT_LOGIN_POST_RESULT=$WNS_LOG/DGT_LOGIN_POST.result

    #TCT_LOGOUT_URL=$DGT_URL/asp/buttonlogout.asp
    #TCT_LOGOUT_RESULT=$WNS_LOG/DGT_LOGOUT.result

    TCT_NEWS_LIST_URL=$TCT_RSS1
    TCT_NEWS_LIST_RESULT=$WNS_LOG/TCT_NEWS_LIST.result

    TCT_COOKIE_JAR=
    
    _LOCATION=$TCT_LOCATION

    #_LOGIN_POST_URL=$TCT_LOGIN_POST_URL

    #_LOGIN_POST_HEADER=$TCT_LOGIN_POST_HEADER
    #_LOGIN_POST_RESULT=$TCT_LOGIN_POST_RESULT

    #_LOGOUT_URL=$TCT_LOGOUT_URL
    #_LOGOUT_RESULT=$TCT_LOGOUT_RESULT

    _NEWS_LIST_URL=$TCT_NEWS_LIST_URL
    _NEWS_LIST_RESULT=$TCT_NEWS_LIST_RESULT

    _COOKIE_JAR=$TCT_COOKIE_JAR

    _NEWS_REPORT=$TCT_LOCATION.listing
}

function TCT() {

    #setting_DGT
    #_logging 'PHASE I: LOGIN (NO LOGIN)'
    #login_to_DGT
    #login_content_string_DGT
    #login_post_to_SITE 

    _logging 'PHASE II: GET NEWS LISTING'
    TCT_NEWS_LIST_URL1=$TCT_RSS1
    TCT_NEWS_LIST_URL2=$TCT_RSS2
    TCT_NEWS_LIST_URL3=$TCT_RSS3
    TCT_NEWS_LIST_URL4=$TCT_RSS4
    TCT_NEWS_LIST_RESULT1=$WNS_LOG/TCT_NEWS_LIST.result1
    TCT_NEWS_LIST_RESULT2=$WNS_LOG/TCT_NEWS_LIST.result2
    TCT_NEWS_LIST_RESULT3=$WNS_LOG/TCT_NEWS_LIST.result3
    TCT_NEWS_LIST_RESULT4=$WNS_LOG/TCT_NEWS_LIST.result4

    _NEWS_LIST_URL=$TCT_RSS1
    _NEWS_LIST_RESULT=$TCT_NEWS_LIST_RESULT1
    echo _NEWS_LIST_URL: $_NEWS_LIST_URL
    fetch_news_list_report

    _NEWS_LIST_URL=$TCT_RSS2
    _NEWS_LIST_RESULT=$TCT_NEWS_LIST_RESULT2
    echo _NEWS_LIST_URL: $_NEWS_LIST_URL
    fetch_news_list_report

    _NEWS_LIST_URL=$TCT_RSS3
    _NEWS_LIST_RESULT=$TCT_NEWS_LIST_RESULT3
    echo _NEWS_LIST_URL: $_NEWS_LIST_URL
    fetch_news_list_report

    _NEWS_LIST_URL=$TCT_RSS4
    _NEWS_LIST_RESULT=$TCT_NEWS_LIST_RESULT4
    echo _NEWS_LIST_URL: $_NEWS_LIST_URL
    fetch_news_list_report

    #_logging 'PHASE III: FETCH NEWS'
    fetch_news_list_TCT

    #_logging 'PHASE IV: LOGOUT (NO LOGOUT )'
    #logout_from_SITE

    _logging 'PHASE V: Transfer HTML to TEXT'
    transfer_ht2txt
    _logging 'PHASE V: Transfer HTML to RTF'
    transfer_txt2rtf
}

