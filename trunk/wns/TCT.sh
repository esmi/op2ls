#--TCT
function _fetch_bytxt_TCT() {

    local LCNT=1
    rm -f $LIST_FILE
    while true ; do
	read FLR <&0
        EOF_FLR=$?
	if [ $EOF_FLR == 1 ] ; then break; fi
	date_str="$(echo $FLR | gawk -F '|' '{print $1}')"
	time_str="$(echo $FLR | gawk -F '|' '{print $2}')"
	title="`echo $FLR | gawk -F "|" '{print $3}'`"
	url=`echo $FLR | gawk -F "|" '{print $4}'`
        echo $date_str, $title, $url
	echo $(expr substr `expr 1000 + $LCNT` 2 3 )"|"$title | tee -a $LIST_FILE
	curl $VERBOSE  $url \
	   --output $TCT_LOCATION/$LCNT 
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
        echo $date_str"|"$title"|"$url
    done
}
function fetch_news_list_TCT() {

    #ORIG_FILE=$TCT_NEWS_LIST_RESULT
   
    LIST_FILE="./$TCT_NEWS_LOC/`date +%Y%m%d`".listing
    mkdir -p $TCT_LOCATION
    local today_str="`date +%Y%m%d`"

    _logging "Function -> $FUNCNAME()" "TCT_LOCATION: $TCT_LOCATION"

    perl ./TCT-list.pl $TCT_NEWS_LIST_RESULT 2>/dev/null | \
	 _rss2txt_formatter_TCT | grep ^$today_str | _fetch_bytxt_TCT

# (perl ./TCT-list.pl ./wns_log/UDN_NEWS_LIST.result1 ; perl ./TCT-list.pl ./wns_log/UDN_NEWS_LIST.result2 ) 2>/dev/null
}

function setting_TCT() {

    # Begin other CFG of "$WNS_CONFIG".............................................................
    TCT_LOCATION="./$TCT_NEWS_LOC/`date +%Y%m%d`"
    #TCT_RSS_F=technology-u.rss
    #TCT_RSS_URL=http://rss.chinatimes.com/rss
    TCT_URL=http://$DGT_SITE

    #TCT_LOCAL_SIGN_URL=lgn/check.asp

    #TCT_LOGIN_POST_URL=$DGT_URL/default.asp

    #TCT_LOGIN_POST_HEADER=$WNS_LOG/DGT_LOGIN_POST.header
    #TCT_LOGIN_POST_RESULT=$WNS_LOG/DGT_LOGIN_POST.result

    #TCT_LOGOUT_URL=$DGT_URL/asp/buttonlogout.asp
    #TCT_LOGOUT_RESULT=$WNS_LOG/DGT_LOGOUT.result

    TCT_NEWS_LIST_URL=http://rss.chinatimes.com/rss/technology-u.rss
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
    _logging 'PHASE I: LOGIN (NO LOGIN)'
    #login_to_DGT
    #login_content_string_DGT
    #login_post_to_SITE 

    _logging 'PHASE II: GET NEWS LISTING'
    fetch_news_list_report

    _logging 'PHASE III: FETCH NEWS'
    fetch_news_list_TCT

    _logging 'PHASE IV: LOGOUT (NO LOGOUT )'
    #logout_from_SITE

    _logging 'PHASE V: Transfer HTML to TEXT'
    transfer_ht2txt
    _logging 'PHASE V: Transfer HTML to RTF'
    transfer_txt2rtf
}

