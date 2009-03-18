#!/bin/bash
fetch_news_list_report_IEK() {
 
    _logging "Function name: $FUNCNAME()" \
		"_NEWS_LIST_URL: $_NEWS_LIST_URL , _NEWS_LIST_RESULT: $_NEWS_LIST_RESULT" \
		"_COOKIE_JAR: $COOKIE_JAR"
    if [ "$_COOKIE_JAR". == "". ] ; then
	_logging "fetching... " "curl $VERBOSE -X get $_NEWS_LIST_URL --output $_NEWS_LIST_RESULT"
	curl $VERBOSE -X GET $_NEWS_LIST_URL --output $_NEWS_LIST_RESULT
    else    
        curl $VERBOSE -b $_COOKIE_JAR \
	   -X GET $_NEWS_LIST_URL  --output  $_NEWS_LIST_RESULT
    fi
}
__reformat_IEK() {

    local LCNT=1
    while true ; do

	read FLR <&0
        EOF_FLR=$?
	if [ $EOF_FLR == 1 ] ; then break; fi
	date="$(echo $FLR | gawk -F '|' '{print $1}'| date --date=- +%Y%m%d)"
	url_title="$(echo $FLR | gawk -F '|' '{print $2}')"
	src="$(echo $FLR | gawk -F '|' '{print $3}')"
	url="$(echo $url_title  | gawk -F '"' '{print $2}')"	
	title="$(echo $url_title  | gawk -F '>' '{print $2}'|sed -e 's/<.*$//g' -e 's/^ //g')"	
		
	echo -n "." >&2
        echo $(expr substr `expr 1000 + $LCNT` 2 3 )"|"$title"|"$url"|"$date"|"$src
	LCNT=`expr $LCNT + 1`
    done
}
list_report_reformat_IEK() {
    #F_HTML=a.orig.html
    F_HTML=$_NEWS_LIST_RESULT
    TODAY="20090306"
    OFFSET=3

    DATE_STRING="^("
    while true ; do
	THE_DATE="$(date --date="$TODAY $OFFSET days ago"  +%Y/%-m/%-d)"
        DATE_STRING=$DATE_STRING$THE_DATE
	if [ $OFFSET == 0 ] ; then break; fi
        DATE_STRING=$DATE_STRING'|'
	OFFSET=$(expr $OFFSET - 1 )
    done
    DATE_STRING=$DATE_STRING')'

    _logging "Article filter string: $DATE_STRING "
    cat $F_HTML | \
    sed 's/<table>/<table><tr><td >NO<\/td><td >DATE<\/td><td>TITLE<\/td><td >SOURCE<\/td><td >AUTHOR<\/td><\/tr>/g'\
        | auto-utf8.pl | ./tb-iek.pl | \
    	sed -e 's/\t//g' -e 's/\n//g'  | tr '\n' ' ' | tr '##' ' \n' | egrep "$DATE_STRING" | \
    	 __reformat_IEK
    #cat d | __reformat_IEK > e
}

__fetch_detail_IEK() {

    local _CKI_ACT="IekUserAccount=$(uri_escape $IEK_ACT)"
    local _CKI_PW="IekUserPasswd=$(uri_escape $IEK_PWD)"
    local _CKI_EMAIL="IekUserEmail=$(uri_escape $IEK_MAIL)"
    local _CKI_STRING1="$_CKI_ACT; $_CKI_EMAIL; $_CKI_PW;"

    #cat $_COOKIE_JAR | grep  -Ev '^(#|$)' | gawk '{print $6"="$7";"}'
    local _CKI_STRING2=`cat $_COOKIE_JAR | grep  -Ev '^(#|$)' | \
		    gawk '{print $6"="$7";"}' | tr '\n' ' ' | sed 's/\; $//g'`
    local __COOKIE_STRING="$_CKI_STRING1 $_CKI_STRING2"
    local LCNT=1
    mkdir -p $IEK_LOCATION > /dev/null
    rm -f f
    while true ; do

	read FLR <&0
        EOF_FLR=$?
	if [ $EOF_FLR == 1 ] ; then break; fi
	num="$(echo $FLR | gawk -F '|' '{print $1}'| date --date=- +%Y%m%d)"
	title="$(echo $FLR | gawk -F '|' '{print $2}')"
	#url="$( uri_escape $(echo $FLR | gawk -F '|' '{print $3}'))"
	url="$(echo $FLR | gawk -F '|' '{print $3}' | sed "s|\.\.|$IEK_URL|g" )"

#	echo curl $VERBOSE -b "$__IEK_CKI" -b $IEK_COOKIE_JAR \
#	    -X GET $url --output $IEK_LOCATION/$LCNT
	#curl $VERBOSE -b $IEK_COOKIE_JAR \
	#    -X GET $url --output $IEK_LOCATION/$LCNT
	#curl $VERBOSE -b "$__COOKIE_STRING"  -D $IEK_LOCATION/$LCNT.header \
	echo   -X GET "$url" --output $IEK_LOCATION/$LCNT.1 | tee -a f
	echo -n "." >&2
        echo $(expr substr `expr 1000 + $LCNT` 2 3 )"|"$title"|"$url
	LCNT=`expr $LCNT + 1`
    done
    echo __COOKIE_STRING: $__COOKIE_STRING
}

fetch_news_list_IEK() {
#    list_report_reformat_IEK | tee e
    cat e  | grep -v "圖表資料庫" | __fetch_detail_IEK
}

function logout_from_SITE_IEK() {

   _logging "Function -> $FUNCNAME()"  "_LOGOUT_URL: $_LOGOUT_URL , _LOGOUT_RESULT: $_LOGOUT_RESULT" \
	    "_LOGOUT_POST_HEADER: $_LOGOUT_POST_HEADER"  
    curl $VERBOSE -b $_COOKIE_JAR  -D $_LOGOUT_POST_HEADER \
	    -X POST --data-ascii "`
	    cat <<-EOF
		POST /index.jsp HTTP/1.1
		Content-type: application/x-www-form-urlencoded

		opt=logout
		EOF
		`" $_LOGOUT_URL \
	   --output $_LOGOUT_RESULT
}

iek_cookie() {
    local LCNT=1
    local key=""
    local value=""
    local esc_value=""
    while true ; do

	read FLR <&0
        EOF_FLR=$?
	if [ $EOF_FLR == 1 ] ; then break; fi
	key="$(echo $FLR | gawk -F '=' '{print $1}')"
	value="$(echo $FLR | gawk -F '=' '{print $2}')"
	esc_value="$(uri_escape "$value")"
	echo $key=$esc_value
	LCNT=`expr $LCNT + 1`
    done

}

function login_content_string_IEK() {

    local _LOGIN_REFERER="$IEK_LOGIN_POST_URL"
    local _REDIRECT_URL="http://ieknet.itri.org.tw:80/index.jsp"

    local _LOGIN_RFR=$(uri_escape $_LOGIN_REFERER)

    local _L_ACT="account=$(uri_escape $IEK_ACT)"
    local _L_PW="password=$(uri_escape $IEK_PWD)"
    local _L_OPT="opt=login"
    local _L_MAIL="email=$(uri_escape $IEK_MAIL)"
    local _L_REDIRECT_URL="RedirectURL=$(uri_escape $_REDIRECT_URL)"
    local _L_SAVE_LOGIN="savelogin=Y"
#    _LOGIN_CONTENT=$_L_ACT'&'$_L_PW'&'$_L_OPT'&'$_L_MAIL'&'$_L_SAVE_LOGIN
#    _LOGIN_CONTENT=$_L_ACT'&'$_L_PW'&'$_L_OPT'&'$_L_MAIL'&'$_L_REDIRECT_URL
    _LOGIN_CONTENT=$_L_ACT'&'$_L_PW'&'$_L_OPT'&'$_L_MAIL'&'$_L_REDIRECT_URL
    #'&'$_L_SAVE_LOGIN

    local _CKI_ACT="IekUserAccount=$(uri_escape $IEK_ACT)"
    local _CKI_MAIL="IekUserEmail=$(uri_escape $IEK_MAIL)"
    local _CKI_PWD="IekUserPasswd=$(uri_escape $IEK_PWD)"

    #local _CKI_STRING2=`cat $_COOKIE_JAR | grep  -Ev '^(#|$)' | \
    #		    gawk '{print $6"="$7";"}' | tr '\n' ' ' | sed 's/\; $//g'`
    #echo $_COOKIE_JAR
    #cat $_COOKIE_JAR | grep  -Ev '^(#|$)' | gawk '{print $6"="$7}' 
    local _CKI_STRING2="$(cat $_COOKIE_JAR | grep  -Ev '^(#|$)' | \
		    gawk '{print $6"="$7}' | iek_cookie | sed 's/$/;/g' |  tr '\n' ' ' | sed 's/\; $//g')"

    _LOGIN_SET_COOKIE="$_CKI_ACT; $_CKI_MAIL; $_CKI_PWD; $_CKI_STRING2"

    _logging "$FUNCNAME()" "_LOGIN_CONTENT: $_LOGIN_CONTENT" "_LOGIN_SET_COOKIE: $_LOGIN_SET_COOKIE"
}
function setting_IEK() {

    # Begin other CFG of "$WNS_CONFIG"
    IEK_LOCATION="./$IEK_NEWS_LOC/`date +%Y%m%d`"
    IEK_URL=http://$IEK_SITE

    IEK_LOCAL_SIGN_URL=service/login.jsp
    IEK_LOGIN_POST_URL=$IEK_URL/$IEK_LOCAL_SIGN_URL
    _LOCAL_SIGN_URL=$IEK_LOCAL_SIGN_URL

    IEK_LOGIN_POST_HEADER=$WNS_LOG/IEK_LOGIN_POST.header
    IEK_LOGIN_POST_RESULT=$WNS_LOG/IEK_LOGIN_POST.result

    IEK_LOGOUT_URL=$IEK_URL/index.jsp

    IEK_LOGOUT_POST_HEADER=$WNS_LOG/IEK_LOGOUT_POST.header
    IEK_LOGOUT_RESULT=$WNS_LOG/IEK_LOGOUT.result

    IEK_NEWS_LIST_URL=$IEK_URL/news/daily.asp
    IEK_NEWS_LIST_RESULT=$WNS_LOG/IEK_NEWS_LIST.result

    IEK_COOKIE_JAR=$WNS_LOG/IEK_COOKIE.jar

    _LOCATION=$IEK_LOCATION

    _LOGIN_POST_URL=$IEK_LOGIN_POST_URL

    _LOGIN_POST_HEADER=$IEK_LOGIN_POST_HEADER
    _LOGIN_POST_RESULT=$IEK_LOGIN_POST_RESULT

    _LOGOUT_URL=$IEK_LOGOUT_URL
    _LOGOUT_RESULT=$IEK_LOGOUT_RESULT
    _LOGOUT_POST_HEADER=$IEK_LOGOUT_POST_HEADER

    _NEWS_LIST_URL=$IEK_NEWS_LIST_URL
    _NEWS_LIST_RESULT=$IEK_NEWS_LIST_RESULT

    _COOKIE_JAR=$IEK_COOKIE_JAR

    _NEWS_REPORT=$IEK_LOCATION.listing
    _LOGIN_SET_COOKIE=""
    _AGENT="User-Agent: Mozilla/5.0 (Windows; U; Windows NT 6.0; zh-TW; rv:1.9.0.7) Gecko/2009021910 Firefox/3.0.7 (.NET CLR 3.5.30729)"
}

function login_post_to_SITE_IEK() {

    _logging "Function -> $FUNCNAME()" "_LOGIN_POST_URL: $_LOGIN_POST_URL"

    _logging "_LOGIN_CONTENT: $_LOGIN_CONTENT" "_LOGIN_SET_COOKIE: $_LOGIN_SET_COOKIE"
    #curl $VERBOSE --trace-ascii trace.1 -b "$_LOGIN_SET_COOKIE" -A "$_AGENT" -D $_LOGIN_POST_HEADER -c $_COOKIE_JAR.0\
    URL_TRACE="--trace-ascii trace.1"
    URL_TRACE=""
    #curl $VERBOSE -b "$_LOGIN_SET_COOKIE" -D "$_LOGIN_POST_HEADER" -c "$_COOKIE_JAR" --location \
cat iek.config | curl $VERBOSE  -b "$_LOGIN_SET_COOKIE" -D "$_LOGIN_POST_HEADER" -c "$_COOKIE_JAR" --location \
	    --referer "http://ieknet.itri.org/index.jap;auto" \
	    http://ieknet.itri.org/index.jsp --output wns_log/IEK.index \
	    -X POST --data-ascii "`
	    cat <<-EOF
		POST /$_LOCAL_SIGN_URL HTTP/1.1
		Content-type: application/x-www-form-urlencoded

		$_LOGIN_CONTENT
		EOF
		`" $_LOGIN_POST_URL \
	   --output $_LOGIN_POST_RESULT --config -

    URL_TRACE="--trace-ascii trace.2"
    URL_TRACE=""


#    curl $VERBOSE  -c $_COOKIE_JAR.1 -b $_COOKIE_JAR -D $_LOGIN_POST_HEADER.1\
#	   -X GET  http://ieknet.itri.org.tw:80/index.jsp \
#	   --output $_LOGIN_POST_RESULT.1
}
function IEK() {

    inform 'PHASE I: LOGIN'
    VERBOSE=-v
    login_content_string_IEK
    login_post_to_SITE_IEK 

    #inform 'PHASE II: GET NEWS LISTING'
    IEK_NEWS_LIST_URL=$IEK_URL/'commentary/search-result.jsp?showkd=&search=&domain=&fcsdata=1&rptdata=1&imgdata=1&syear=2009&smonth=02&sdate=01&eyear=2009&emonth=03&edate=10&searchmode=0'
    IEK_NEWS_LIST_URL=$IEK_URL/'commentary/search-result.jsp?showkd=&search=&domain=&fcsdata=1&syear=2009&smonth=03&sdate=01&eyear=2009&emonth=03&edate=20&searchmode=1'


    _NEWS_LIST_URL=$IEK_NEWS_LIST_URL
#    fetch_news_list_report_IEK


    #fetch_news_list_report

#    _logging 'PHASE III: FETCH NEWS'

#    fetch_news_list_IEK
    VERBOSE=""

    _logging 'PHASE IV: LOGOUT'
    logout_from_SITE_IEK

#    _logging 'PHASE V: Transfer HTML to TEXT'
#    transfer_ht2txt3
#    _logging 'PHASE V: Transfer HTML to RTF'
#    transfer_txt2rtf
}

