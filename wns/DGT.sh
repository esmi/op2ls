
fetch_news_report() {
    
    _logging "$FUNCNAME()" \
	    "_NEWS_LIST_URL: $_NEWS_LIST_URL , _NEWS_LIST_RESULT: $_NEWS_LIST_RESULT, _COOKIE_STRING: $_COOKIE_STRING"

    curl $VERBOSE -D ./wns_log/DGT_NEWS_LIST.header  --cookie "$_COOKIE_STRING" \
	   --output  $_NEWS_LIST_RESULT $_NEWS_LIST_URL
}

# D G T 

format_news_report() {
    local orig_report=$DGT_NEWS_LIST_RESULT
    #local __report_formated="./$DGT_NEWS_LOC/`date +%Y%m%d`".fetch
    local __orig_report_backup="./$DGT_NEWS_LOC/`date +%Y%m%d`".NEWSREPORT
    local __report_listing="./$DGT_NEWS_LOC/`date +%Y%m%d`".listing

    mkdir -p $DGT_LOCATION
    _logging "Function -> $FUNCNAME()" "DGT_SHOWNEWS_URL: $DGT_SHOWNEWS_URL, DGT_LOCATION: $DGT_LOCATION"

    cp $orig_report $__orig_report_backup
    cat $orig_report | \
	piconv -f big5 -t utf8 | \
	grep -i checkbox | \
	sed -e 's/^.*value="//g' -e 's/<BR>.*<BR>//g' -e 's/<BR>//g' \
	    -e 's/>.*$//g' -e 's/"$//g' -e '/checkbox/d' -e 's/^/|/g' | \
	cat -n | sed -e 's/[ \t]//g' > $__report_formated
    cat $__report_formated | sed 's/|\/tw.*$//g' > $__report_listing
}

__fetch_detail_DGT() {

    while true ; do

	read FLR <&0
        EOF_FLR=$?
	if [ $EOF_FLR == 1 ] ; then break; fi
	num="$(echo $FLR | gawk -F '|' '{print $1}')"
	title="$(echo $FLR | gawk -F '|' '{print $2}')"
	url="$DGT_URL$(echo $FLR | gawk -F '|' '{print $3}' )"

	if [ $DEBUG -lt 500 ] ; then    
	    echo -n '.'
	    curl $VERBOSE  --cookie "$_COOKIE_STRING" \
		--output  $DGT_LOCATION/$num  \
		$url
	else
	    _logging "Num: $num, Title: $title" "URL: $url"
	fi
    done
}

function login_to_DGT() {
    #set +e    
    DGT_MYID="`echo -n $DGT_ACT | perl -MURI::Escape -ne 'print uri_escape($_);'`"
    DGT_LOGIN_URL="$DGT_URL/$DGT_LOCAL_SIGN_URL?ToUrl=/tw/default.asp?"

    DGT_LOGIN_HEADER=$WNS_LOG/DGT_LOGIN.header
    DGT_LOGIN_RESULT=$WNS_LOG/DGT_LOGIN.result

    #LOGIN_STRING="fromurl=login&ID=$DGT_USR_ID&Password=$DGT_USR_PWD&MyID=$DGT_MYID&MyPwd=$DGT_PWD"
    LOGIN_STRING="fromurl=login&checkid=$DGT_MYID&checkpwd=$DGT_PWD"

    _logging "$FUNCNAME(): LOGIN TO CHECK SITE,  LOGIN_URL: $DGT_LOGIN_URL." \
	     "Post string: $LOGIN_STRING, _LOGIN_HEADER: $DGT_LOGIN_HEADER, _LOGIN_RESULT: $DGT_LOGIN_RESULT"

    curl $VERBOSE -c $DGT_COOKIE_JAR -D $DGT_LOGIN_HEADER \
	-X POST --data-ascii "$LOGIN_STRING" $DGT_LOGIN_URL >  $DGT_LOGIN_RESULT

    RET_CODE=$?

    echo RET_CODE: $RET_CODE
    _logging "$FUNCNAME(): leave LOGIN CHECK SITE."  "URL return code: $RET_CODE"
    #set -e
}

function setting_DGT() {

    # Begin other CFG of "$WNS_CONFIG".............................................................
    DGT_LOCATION="./$DGT_NEWS_LOC/`date +%Y%m%d`"
    DGT_URL=http://$DGT_SITE

    #DGT_LOCAL_SIGN_URL=lgn/check.asp
    DGT_LOCAL_SIGN_URL=tw/lgn/check.asp
    _LOCAL_SIGN_URL=$DGT_LOCAL_SIGN_URL
    DGT_LOGIN_POST_URL=$DGT_URL/default.asp

    DGT_LOGIN_POST_HEADER=$WNS_LOG/DGT_LOGIN_POST.header
    DGT_LOGIN_POST_RESULT=$WNS_LOG/DGT_LOGIN_POST.result

    #DGT_LOGOUT_URL="$DGT_URL/tw/lgn/logout.asp?tourl=/tw/dt/dtpage_cold.asp?"
    DGT_LOGOUT_URL="$DGT_URL/tw/lgn/logout.asp?tourl=/tw/default.asp?"
#http://www.digitimes.com.tw/tw/lgn/logout.asp?tourl=/tw/dt/dtpage_cold.asp?
#http://www.digitimes.com.tw/tw/lgn/logout.asp?tourl=/tw/default.asp?

    DGT_LOGOUT_RESULT=$WNS_LOG/DGT_LOGOUT.result

    #DGT_NEWS_LIST_URL=$DGT_URL/n/nwslst.asp
    DGT_NEWS_LIST_URL="$DGT_URL/tw/dt/dtpage_cold.asp?"

    DGT_NEWS_LIST_RESULT=$WNS_LOG/DGT_NEWS_LIST.result

    DGT_COOKIE_JAR=$WNS_LOG/DGT_COOKIE.jar
    
    _LOCATION=$DGT_LOCATION

    _LOGIN_POST_URL=$DGT_LOGIN_POST_URL

    _LOGIN_POST_HEADER=$DGT_LOGIN_POST_HEADER
    _LOGIN_POST_RESULT=$DGT_LOGIN_POST_RESULT

    _LOGOUT_URL=$DGT_LOGOUT_URL
    _LOGOUT_RESULT=$DGT_LOGOUT_RESULT

    _NEWS_LIST_URL=$DGT_NEWS_LIST_URL
    _NEWS_LIST_RESULT=$DGT_NEWS_LIST_RESULT

    _COOKIE_JAR=$DGT_COOKIE_JAR

    _NEWS_REPORT=$DGT_LOCATION.listing
}

DGT() {
    #setting_DGT
    if [ $DEBUG -lt 500 ] ; then 
	_logging 'PHASE I: LOGIN'
	login_to_DGT
 
	_COOKIE_STRING="`cookie_string $DGT_LOGIN_HEADER`"
	echo COOKIE_STRING: $_COOKIE_STRING
	echo $_COOKIE_STRING > $WNS_LOG/DGT_COOKIE_STRING
    fi
    #fetch_news_report()
    if [ $DEBUG -lt 500 ] ; then    
	_logging 'PHASE II: GET NEWS LISTING'
	fetch_news_report
    fi

    local __report_formated="./$DGT_NEWS_LOC/`date +%Y%m%d`".fetch
    #format_news_report() 
    if [ $DEBUG -lt 600 ] ; then
	_logging 'PHASE III: Format report listing'
	#backup_orig_new_report
	format_news_report $__report_formated
    fi
    #fetch_detail_by_formated
    if [ $DEBUG -lt 700 ] ; then
	_logging 'PHASE IV: Fetch detail by formated report'
        cat $__report_formated |  __fetch_detail_DGT
    fi
    #logout.
    if [ $DEBUG -lt 500 ] ; then    
	_logging 'PHASE V: LOGOUT'
	#logout_from_SITE "$_COOKIE_STRING"
	logout_from_SITE "$_COOKIE_STRING" "get"
    fi
    #Transfer news data to text
    if [ $DEBUG -lt 800 ] ; then    
	_logging 'PHASE V: Transfer HTML to TEXT'
	transfer_ht2txt
    fi
    #Transfer news data to rtf
    if [ $DEBUG -lt 900 ] ; then    
	_logging 'PHASE V: Transfer HTML to RTF'
	transfer_txt2rtf
    fi
}

