#!/bin/bash
source wns_include.sh

# COMMON Functions.

function transfer_ht2txt() {

    if [ -d $_LOCATION ]; then
        rm -f $_LOCATION/*.txt 

	for i in `find $_LOCATION -type f` ; do
	    ./ht2txt.pl  $i  2> /dev/nul | piconv -f big5 -t utf-8 > $i.txt
            echo -n '.'
	done
    else
	echo -e "\tDirectory: $_LOCATION, is not exist."
	echo -e "\n\tI can't transfer data to TEXT format, Please check it."
    fi
}

function uri_escape() {
    echo -n $@ | perl -MURI::Escape -ne 'print uri_escape($_);'
    #$retval
}

_logging() {
    if [ $DEBUG -ge 100 ] ; then
	inform "$1"
    fi
    if [ ! "$2". == "". ] ; then
        if [ $DEBUG -ge 200 ] ; then
	   debug "$2"
	fi
    fi
    if [ ! "$3". == "". ] ; then
        if [ $DEBUG -ge 300 ] ; then
	   debug "$3"
	fi
    fi
}

# NEWS functions.
fetch_news_list_report() {
    
    _logging "$FUNCNAME" \
		"_NEWS_LIST_URL: $_NEWS_LIST_URL , _NEWS_LIST_RESULT: $_NEWS_LIST_RESULT"
    
    curl $VERBOSE -b $_COOKIE_JAR \
	-X get $_NEWS_LIST_URL  --output  $_NEWS_LIST_RESULT

}

# LOGIN / LOGOUT functions.
function login_post_to_SITE() {

    _logging "$FUNCNAME" "_LOGIN_POST_URL: $_LOGIN_POST_URL"

    curl $VERBOSE  -c $_COOKIE_JAR -D $_LOGIN_POST_HEADER\
	    -X POST --data-ascii "`
	    cat <<-EOF
		POST /$TPG_LOCAL_SIGN_URL HTTP/1.1
		Content-type: application/x-www-form-urlencoded

		$_LOGIN_CONTENT
		EOF
		`" $_LOGIN_POST_URL \
	   --output $_LOGIN_POST_RESULT
}

function logout_from_SITE() {

    _logging "$FUNCNAME"  "_LOGOUT_URL: $_LOGOUT_URL , _LOGOUT_RESULT: $_LOGOUT_RESULT"
    curl $VERBOSE -b $_COOKIE_JAR \
	    -X GET $_LOGOUT_URL	--output $_LOGOUT_RESULT 
}


# T P G ---
function login_to_TPG() {
    
    inform "LOGIN POSTING."
    login_post_to_TPG
}

function login_content_string_TPG() {

    TPG_LOGIN_REFERER="$TPG_LOGIN_POST_URL"

    TPG_LOGIN_CTT_RFR=$(uri_escape $TPG_LOGIN_REFERER)
    TPG_LOGIN_CTT_ACT="account=$(uri_escape $TPG_ACT)"
    TPG_LOGIN_CTT_PW="pw=$(uri_escape $TPG_PWD)"
    TPG_LOGIN_CTT_SGB="siginbtn=Login"

    _LOGIN_CONTENT="refLink="$TPG_LOGIN_CTT_RFR'&'$TPG_LOGIN_CTT_ACT'&'$TPG_LOGIN_CTT_PW'&'$TPG_LOGIN_CTT_SGB
}
function fetch_news_list_TPG() {

    ORIG_FILE=$TPG_NEWS_LIST_RESULT
    WORK_FILE=`mktemp`
    TEMP_FILE=`mktemp`

    LIST_FILE="./$TPG_NEWS_LOC/`date +%Y%m%d`".listing
    LIST_URL="./$TPG_NEWS_LOC/`date +%Y%m%d`".urls

    rm -f $LIST_FILE $LIST_URL

    mkdir -p $TPG_LOCATION

    ./TPG_daily.pl $ORIG_FILE | grep -i "http.*newscontent" | gawk '{print $3}' > $WORK_FILE

    LINES=$(wc -l $WORK_FILE | gawk '{print $1}')

    cp $WORK_FILE $TEMP_FILE

    #cat $TEMP_FILE

    LCNT=1
    #debug set $LINE=1
    #LINES=1

    while [ $LCNT -le $LINES ] ; do

        article_url="`head -n $LCNT $TEMP_FILE | tail -n 1`"

	curl $VERBOSE -b $TPG_COOKIE_JAR \
	    -X GET $article_url --output $TPG_LOCATION/$LCNT
        this_line=`cat $TPG_LOCATION/$LCNT | grep -i csub | \
			sed -e 's/^.*csub=//g' -e 's/\".*$//g' | \
			piconv -f big5 -t utf-8`
        echo $(expr substr `expr 1000 + $LCNT` 2 3 ), $this_line  >> $LIST_FILE
        echo $(expr substr `expr 1000 + $LCNT` 2 3 ), $article_url  >> $LIST_URL
	
        echo -n '.'
	LCNT=`expr $LCNT + 1`
    done

    rm -f $WORK_FILE
    rm -f $TEMP_FILE
}

function setting_TPG() {

    # Begin other CFG of "$WNS_CONFIG"
    TPG_LOCATION="./$TPG_NEWS_LOC/`date +%Y%m%d`"
    TPG_URL=http://$TPG_SITE

    TPG_LOCAL_SIGN_URL=tri/sign.asp
    TPG_LOGIN_POST_URL=$TPG_URL/$TPG_LOCL_SIGN_URL

    TPG_LOGIN_POST_HEADER=$WNS_LOG/TPG_LOGIN_POST.header
    TPG_LOGIN_POST_RESULT=$WNS_LOG/TPG_LOGIN_POST.result

    TPG_LOGOUT_URL=$TPG_URL/tri/signout.asp
    TPG_LOGOUT_RESULT=$WNS_LOG/TPG_LOGOUT.result

    TPG_NEWS_LIST_URL=$TPG_URL/news/daily.asp
    TPG_NEWS_LIST_RESULT=$WNS_LOG/TPG_NEWS_LIST.result

    TPG_COOKIE_JAR=$WNS_LOG/TPG_COOKIE.jar

    _LOCATION=$TPG_LOCATION

    _LOGIN_POST_URL=$TPG_LOGIN_POST_URL

    _LOGIN_POST_HEADER=$TPG_LOGIN_POST_HEADER
    _LOGIN_POST_RESULT=$TPG_LOGIN_POST_RESULT

    _LOGOUT_URL=$TPG_LOGOUT_URL
    _LOGOUT_RESULT=$TPG_LOGOUT_RESULT

    _NEWS_LIST_URL=$TPG_NEWS_LIST_URL
    _NEWS_LIST_RESULT=$TPG_NEWS_LIST_RESULT

    _COOKIE_JAR=$TPG_COOKIE_JAR

}

function TPG() {
    inform 'PHASE I: LOGIN'
    login_content_string_TPG
    login_post_to_SITE 

    inform 'PHASE II: GET NEWS LISTING'
    fetch_news_list_report

    inform 'PHASE III: FETCH NEWS'
    fetch_news_list_TPG

    inform 'PHASE IV: LOGOUT'
    logout_from_SITE

    inform 'PHASE V: Transfer HTML to TEXT'
    transfer_ht2txt
}

# D G T 

function fetch_news_list_DGT() {

    DGT_SHOWNEWS_URL="$DGT_URL/n/ShwNws.asp"
    ORIG_FILE=$DGT_NEWS_LIST_RESULT
    WORK_FILE=`mktemp`
    TEMP_FILE=`mktemp`

    #DGT_LOCATION="./$DGT_NEWS_LOC/`date +%Y%m%d`"
    LIST_FILE="./$DGT_NEWS_LOC/`date +%Y%m%d`".listing
    mkdir -p $DGT_LOCATION
    _logging "$FUNCNAME" "DGT_SHOWNEWS_URL: $DGT_SHOWNEWS_URL, DGT_LOCATION: $DGT_LOCATION"

    cat $ORIG_FILE | \
	sed  -e 's|<img src.*><td|<td|g' | \
        egrep -i '(shownew|href)'  | egrep -v '(img|var|function|location\.|link.*css|history.)' | \
	sed -e 's|<td class=.*hc.*ShowNews(||g' -e 's|)>|,|g' -e 's/^.*<a href.*addcols.asp"//g' -e 's/).*>//g' \
	    | egrep -v '(<tr>|<a href)' > $WORK_FILE


    LINES="$(echo  $(wc -l $WORK_FILE | awk '{print $1}' ) / 2 | bc)"

    cat $WORK_FILE | piconv -f big5 -t utf-8 | \
	tr -t '>\n' '>  ' | \
	sed 's/,""/,""\&/g' |\
	tr '&' '\n' | \
	sed -e "s/'//g" -e 's/"//g' |\
	head -n $LINES  > $TEMP_FILE

    LCNT=1
    #debug set $LINE=1
    #LINES=1

    while [ $LCNT -le $LINES ] ; do

	header="$DGT_URL"'&s=1&news_filter=all&s=11&s=13&s=15&s=19&s=23'

        from_date=`date --date="3 months ago" +%Y/%m/%d`
	from_year="from_year=""`echo $from_date | gawk -F '/' '{print $1}'`"
        from_month="from_month=""`echo $from_date | gawk -F '/' '{print $2}'`"
	from_day="from_day=""`echo $from_date | gawk -F '/' '{print $3}'`"
        from=$from_year'&'$from_month'&'$from_day

	to_date=`date +%Y/%m/%d`
        to_year="to_year=""`echo $to_date | gawk -F '/' '{print $1}'`"
	to_month="to_month=""`echo $to_date | gawk -F '/' '{print $2}'`"
        to_day="to_day=""`echo $to_date | gawk -F '/' '{print $3}'`"
	to=$to_year'&'$to_month'&'$to_day
    
        p="`echo 'p=搜尋關鍵字' | piconv -f utf-8 -t big5`"
	date_publish="DatePublish="$to_date

        this_line="`head -n $LCNT $TEMP_FILE | tail -n 1`"
	pages="Pages=""`echo $this_line | gawk -F ',' '{print $1}'`"
        all_seq="All_Seq=""`echo $this_line | gawk -F ',' '{print $2}'`"

	#echo $this_line >> $DGT_LOCATION/$LIST_FILE
        echo $(expr substr `expr 1000 + $LCNT` 2 3 ), $this_line | \
	    gawk -F ',' '{print $1". " $4}' | sed 's/<td>//g' >> $LIST_FILE

	tailer='f=A&PgSize=5&yS=31&yAddMulitColsFrom=news'
        jumpout_made="JumpOut="$header'&'$from'&'$to'&'$p'&'$date_publish'&'$pages'&'$all_seq'&'$tailer
	#echo MADMAT: $jumpout_made
        jumpout="`echo $jumpout_made | perl -MURI::Escape -ne 'print uri_escape($_);' | \
		sed -e 's/%0A$//g' -e 's/%3D/=/g' -e 's/%26/\&/g'`"

	curl $VERBOSE -b $DGT_COOKIE_JAR \
	    -X POST --data-ascii "`
	    cat <<-EOF
		POST /n/ShwNws.asp HTTP/1.1
		Content-type: application/x-www-form-urlencoded

		$jumpout		
		EOF
		`" $DGT_SHOWNEWS_URL \
	   --output $DGT_LOCATION/$LCNT 

        if [ $DEBUG -gt 200 ] ; then
	   debug "$jumpout"
	fi
	if [ $DEBUG -eq 0 ] ; then
	    echo -n '.'
	fi
	LCNT=$(expr $LCNT + 1)
    done
#   if [ $DEBUG -gt 200 ] ; then
#	echo ORIMAT: 'JumpOut=http%3A%2F%2F'"$SITE_NAME"'&s=1&news_filter=all&s=11&s=13&s=15&s=19&s=23&from_year=2008&from_month=10&from_day=15&to_year=2009&to_month=01&to_day=14&p=%B7j%B4M%C3%F6%C1%E4%A6r&DatePublish=2009%2F01%2F14&Pages=X1&All_Seq=1&f=A&PgSize=5&yS=31&yAddMulitColsFrom=news'
#   fi
    rm -f $WORK_FILE
    rm -f $TEMP_FILE
}

function login_to_DGT() {
    
    DGT_MYID="`echo -n $DGT_ACT | perl -MURI::Escape -ne 'print uri_escape($_);'`"
    DGT_LOGIN_URL=$DGT_URL/$DGT_LOCAL_SIGN_URL
    DGT_LOGIN_HEADER=$WNS_LOG/DGT_LOGIN.header
    DGT_LOGIN_RESULT=$WNS_LOG/DGT_LOGIN.result

    LOGIN_STRING="ID=$DGT_USR_ID&Password=$DGT_USR_PWD&MyID=$DGT_MYID&MyPwd=$DGT_PWD"

    _logging "$FUNCNAME: LOGIN TO CHECK SITE." \
	     "LOGIN_STRING: $LOGIN_STRING, DGT_LOGIN_URL: $DGT_LOGIN_URL"

    curl $VERBOSE -c $DGT_COOKIE_JAR -D $DGT_LOGIN_HEADER \
	-X POST --data-ascii "$LOGIN_STRING" $DGT_LOGIN_URL >  $DGT_LOGIN_RESULT

    RET_CODE=$?
    RETURN_OK=`cat $DGT_LOGIN_HEADER | grep -i ^HTTP.*200`

    if [ "$RETURN_OK". == "". ] ; then
	_logging "$FUNCNAME: CHECK SITE response code." \
		 "\t\tlogin return code: $RET_CODE, \t\tLOGIN RETURN CODE: $RETURN_OK"
	logout_from_SITE
	
	_logging "\t\tError Message: `grep -i location $DGT_LOGIN_HEADER | piconv -f big5 -t utf-8`" \
		 "\t\tTry re-logout from $DGT_LOGOUT_URL, $DGT_LOGOUT_OK_URL." 
	abort "Please try again......" 
    fi
}

login_content_string_DGT() {
    _LOGIN_CONTENT="`
    	    cat $DGT_LOGIN_RESULT | sed 's/>/>;/g' | tr ';' '\n' | \
		    egrep -i '(input)' | \
		    sed -e 's/^.*name=//g' -e 's/ value//g' -e 's/>//g' \
		    -e "s/'//g" -e "s/yUID$/yUID=$DGT_ACT/g" | \
		    tr '\n' '&' | sed 's/&$//g' 
	    `"
    _logging "$FUNCNAME" "_LOGIN_CONTENT: $_LOGIN_CONTENT"
}

function setting_DGT() {

    # Begin other CFG of "$WNS_CONFIG".............................................................
    DGT_LOCATION="./$DGT_NEWS_LOC/`date +%Y%m%d`"
    DGT_URL=http://$DGT_SITE

    DGT_LOCAL_SIGN_URL=lgn/check.asp

    DGT_LOGIN_POST_URL=$DGT_URL/default.asp

    DGT_LOGIN_POST_HEADER=$WNS_LOG/DGT_LOGIN_POST.header
    DGT_LOGIN_POST_RESULT=$WNS_LOG/DGT_LOGIN_POST.result

    DGT_LOGOUT_URL=$DGT_URL/asp/buttonlogout.asp
    DGT_LOGOUT_RESULT=$WNS_LOG/DGT_LOGOUT.result

    DGT_NEWS_LIST_URL=$DGT_URL/n/nwslst.asp
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
}

function DGT() {

    _logging 'PHASE I: LOGIN'
    login_to_DGT
    login_content_string_DGT
    login_post_to_SITE 

    _logging 'PHASE II: GET NEWS LISTING'
    fetch_news_list_report

    _logging 'PHASE III: FETCH NEWS'
    fetch_news_list_DGT

    _logging 'PHASE IV: LOGOUT'
    logout_from_SITE

    #_logging 'PHASE V: Transfer HTML to TEXT'
    transfer_ht2txt
}

#  END OF FUNCTIONs..............................................................................

# MAIN()
# DEBUG CONFIGURATION............................................................................
DEBUG=200
DEBUG=0
DEBUG=300

# BEGIN OF DATA CONFIGURATION...................................................................
#   Private data locate in "WNS.CFG", it contain :
#   $TPG_ACT, $TPG_PWD, $TPG_SITE, $TPG_NEWS_LOC
DATA_PATH=./wns_cfg
WNS_CONFIG="$DATA_PATH/wns.cfg"
WNS_LOG=./wns_log

if ! [  -a $WNS_CONFIG ] ; then
    echo WNS_CONFIG FILE: $WNS_CONFIG , is not exist...
    echo please check WNS_CONFIG FILE.
    exit 1
fi

source $WNS_CONFIG
# Setting debug..................................................................................
if [ $DEBUG -eq 0 ] ; then
    VERBOSE="--silent --show-error"
fi
if [ "$DEBUG" -ge 200 ] ; then
    VERBOSE="--silent --show-error"
fi

# Begin MAIN Procedure...........................................................................
case $1 in
    TPG)
	setting_TPG
	TPG
	;;
    DGT)
	setting_DGT
	DGT
	;;
    *)
	__show_help
	;;
esac
# End of MAIN()..................................................................................

