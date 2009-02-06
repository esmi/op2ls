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

    _logging "Function -> $FUNCNAME" "_LOGIN_POST_URL: $_LOGIN_POST_URL"

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

    _logging "Function -> $FUNCNAME"  "_LOGOUT_URL: $_LOGOUT_URL , _LOGOUT_RESULT: $_LOGOUT_RESULT"
    curl $VERBOSE -b $_COOKIE_JAR \
	    -X GET $_LOGOUT_URL	--output $_LOGOUT_RESULT 
}


# T P G ---
function login_to_TPG() {
    
    inform "LOGIN POSTING."
    login_post_to_TPG
}

function login_content_string_TPG() {

    local _LOGIN_REFERER="$TPG_LOGIN_POST_URL"

    local _LOGIN_RFR=$(uri_escape $_LOGIN_REFERER)
    local _LOGIN_ACT="account=$(uri_escape $TPG_ACT)"
    local _LOGIN_PW="pw=$(uri_escape $TPG_PWD)"
    local _LOGIN_SGB="siginbtn=Login"

    _LOGIN_CONTENT="refLink="$_LOGIN_RFR'&'$_LOGIN_ACT'&'$_LOGIN_PW'&'$_LOGIN_SGB
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
    TPG_LOGIN_POST_URL=$TPG_URL/$TPG_LOCAL_SIGN_URL

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
	
    setting_TPG

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
    _logging "Function -> $FUNCNAME" "DGT_SHOWNEWS_URL: $DGT_SHOWNEWS_URL, DGT_LOCATION: $DGT_LOCATION"

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
	    gawk -F ',' '{print $1". " $4}' | sed 's/<td>//g' | sed 's/<.*>//g' >> $LIST_FILE

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

    #echo RETURN_OK: $RETURN_OK
    #echo -------------------------------------------
    if [ "$RETURN_OK". == "". ] ; then
	RETURN_OK=`cat $DGT_LOGIN_HEADER | grep -i ^HTTP | tail -n 1`

	_logging "function-> $FUNCNAME, DGT LOGIN CHECK SITE response:" \
		 "\tCURL return code: $RET_CODE, \tHTTP return code: $RETURN_OK"
	
	_logging "\tMessage: `grep -i location $DGT_LOGIN_HEADER | piconv -f big5 -t utf-8`" \
		 "\tTry re-logout from $DGT_LOGOUT_URL, $DGT_LOGOUT_OK_URL."
	logout_from_SITE
	echo "" 
	abort "Please try again......" 
    fi
    _logging "$FUNCNAME: leave LOGIN TO CHECK SITE."  "..."
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

    #setting_DGT

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

function tag_parsing_bydate() {
    #echo $1 $2 $3
    local SITE_NAME=$1
    local start_d=$2
    local days=$3
    local i=0

    local PARSE_SEQ_F=`mktemp`
    cat <&0 > $PARSE_SEQ_F

    # disable errexit shelloption $ set +e
    set +e
    #echo SHELLOPTS: $SHELLOPTS

    while true ; do

	local date_str=$start_d" "$i" day"
	local PARSE_DATE=`date  --date="$date_str" +%Y%m%d`
	#echo $PARSE_DATE, $date_str, $i

	case "$SITE_NAME" in 
	    DGT) local PARSED_F=$DGT_NEWS_LOC/$PARSE_DATE.listing ;;
	    TPG) local PARSED_F=$TPG_NEWS_LOC/$PARSE_DATE.listing ;;
	    *) echo Error pasing type: $1. ; return 1 ;
	esac 

	tag_parsing_file $PARSE_SEQ_F $PARSED_F $PARSE_DATE $SITE_NAME

	i=`expr $i + 1 `
	if [ $i == $days ] ; then break ; fi
    done
    
    rm -f $PARSE_SEQ_F
    set -e
}

function tag_parsing() {
#prototype tag_parsing <DGT|TPG> yyyymmdd
    local PARSE_SEQ_F=`mktemp`
    local PARSE_DATE=$2
    local SITE_NAME=$1
    
    case "$1" in 
	DGT) local PARSED_F=$DGT_NEWS_LOC/$PARSE_DATE.listing ;;
	TPG) local PARSED_F=$TPG_NEWS_LOC/$PARSE_DATE.listing ;;
	*) echo Error pasing type: $1. ; return 1 ;
    esac 
    
    cat <&0 > $PARSE_SEQ_F

    tag_parsing_file $PARSE_SEQ_F $PARSED_F $PARSE_DATE $SITE_NAME

    rm -f $PARSE_SEQ_F
}

function tag_parsing_file() {
#prototype:    tag_parsing_file $input_SEQ_F $PARSED_FILE $PARSE_DATE $SITE_NAME
    local PARSE_SEQ_F=$1
    local PARSED_F=$2
    local PARSE_DATE=$3
    local SITE_NAME=$4

    exec 3<>$PARSE_SEQ_F

    while true ; do
	read THIS_L <&3
        EOF=$?

	if [ $EOF == 1 ] ; then break ; fi

        SEQ=`echo $THIS_L | gawk -F '|' '{print $1}'`
	KEY=`echo $THIS_L | gawk -F '|' '{print $2}'`
        NOT=`echo $THIS_L | gawk -F '|' '{print $3}'`
	CONTENT=`echo $THIS_L | gawk -F '|' '{print $4}'`
        TAG=`echo $THIS_L | gawk -F '|' '{print $5}' |  sed -e 's/, /,/g' -e 's/, /,/g' -e 's/^ //g'`
	KEY=`echo $KEY | sed -e 's/, /,/g' -e 's/, /,/g'`
        S_KEY='('`echo $KEY | sed 's/,/|/g'`')'
	NOT=`echo $NOT | sed -e 's/, /,/g' -e 's/, /,/g'`
        S_NOT='('`echo $NOT | sed 's/,/|/g'`')'

	if [ "$S_NOT". == '()'. ] ; then S_NOT='(@@%%&&%%@@$$$$)' ; fi

        #echo SEQ: $SEQ, TAG: $TAG, S_KEY: $S_KEY, S_NOT: \"$S_NOT\"

        egrep -i "$S_KEY" "$PARSED_F" | \
	   egrep -v "$S_NOT" | sed -e "s/$/|$TAG|$KEYS|$SEQ|$PARSE_DATE/g" -e "s/^/$SITE_NAME|$PARSE_DATE|/g"
    done

    #shopt -s execfail
    #exec 3>&-
    exec 3<&- 
}

function tag_one_line() {

    SORT_F=`mktemp`
    SEQ_F=`mktemp`

    set +e

    cat <&0 > $SORT_F
    cat $SORT_F | gawk -F '|' '{print $1"|"$2"|"$3}' | gawk -F '[.,]' '{print $1}' | sort |uniq > $SEQ_F
    exec 3<>$SEQ_F

    L_NUM=`cat $SORT_F | tail -n 1 | gawk -F '|' '{print $2}' | gawk -F '.' '{print $1}'`
    while true ; do
	#echo -n '.' >&2
	read L_CNT <&3
	EOF=$?
	if [ $EOF == 1 ] ; then break ; fi

	#grep -i '|'$L_CNT'[.|,]' $SORT_F 
	TITLE=`grep -i $L_CNT $SORT_F | gawk -F '|' '{print $3}' | gawk -F '[.,]' '{print $2}' | head -n 1`
	#echo $TITLE
	TAGS=`grep -i $L_CNT $SORT_F | \
		gawk -F '|' '{print $4}' | tr ',' '\n' | \
		sort |uniq | tr '\n' ',' | sed 's/,$//g'`
	echo  $L_CNT'|'$TITLE'|'$TAGS
    done
    echo "" >&2
    exec 3>&-
    rm -f $SORT_F $SEQ_F
    set -e
}

__show_help() {
	cat <<-_EOF
		${_name} is a fetch news program.

		Usage: ${_name} [ [ -d <value> | --debug <value> ] [ --DGT | --TPG ] | [ --help | --version ]
		Tags usage; ${_name}  --create-tag-tab | --tag-seq [seq] | [parsing-parametrs] 
		             [ --tag-parsing < SITE > | --tag-parsing-bydate < SITE > <date> <datenum> ] |
		               --tag-one-line

		    -d, --debug <value> : setup debug value
		    --DGT: news site DGT;  --TPG: news site TPG.

		    --create-tag-tab: create tags table from clipboard.
		    --tag-seq [seq]: parse specific seq no from tags table. seq(ref)
		    --tag-parsing:
		    --tag-parsing-bydate: 
		    --tag-one-line: after --tag-paring* you can format duplicated title to one line.

		    --help: show this message.;	    --version: show version.
		    parsing-parameters:

		    REF:
		    seq exampe: 134, 1-5, 12345, 1-9, 0-9
		    Tags example:
		        ${_name} --tag-seq 1-3 | ${_name} --tag-parsing < DGT | TPG >
		        ${_name} --tag-seq 135 | ${_name} --tag-parsing < DGT | TPG >
		    Tags parsing:
		            parsing DGT from 20090204, parse 2 days (20090204, 20090205)
		            ${_name} --tag-parsing-bydate "DGT 20090204 2"
		    STEP:
		        ${_name} --debug 300 DGT ; ${_name} --debug 300 TPG
		        ${_name} --tag-seq -- | ${_name} --tag-parsing-bydate "DGT 20090206 1" > result.1
		        ${_name} --tag-seq -- | ${_name} --tag-parsing-bydate "TPG 20090206 1" > result.2
		        cat result.1 result.2 | ${_name} --tag-one-line > 20090206.tag-report
		_EOF
}

readonly -f __show_help 
#__show_version error warning inform verbose __stage __step
#  END OF FUNCTIONs..............................................................................

# MAIN()
DEBUG=0
# DATA CONFIGURATION.
#   Private data locate in "wns.cfg":
#   1. DGT: $DGT_USR_ID, $DGT_USR_PWD, 
#	    $DGT_ACT, $DGT_PWD, $DGT_SITE, $DGT_NEWS_LOC
#   2. TPG: $TPG_ACT, $TPG_PWD, $TPG_SITE, $TPG_NEWS_LOC
DATA_PATH=./wns_cfg
WNS_CONFIG="$DATA_PATH/wns.cfg"
WNS_LOG=./wns_log

if ! [  -a $WNS_CONFIG ] ; then
    echo WNS_CONFIG FILE: $WNS_CONFIG , is not exist...
    echo please check WNS_CONFIG FILE.
    exit 1
fi

source $WNS_CONFIG

# check options...

L_OP="create-tag-tab,tag-seq:,tag-parsing:,tag-parsing-bydate:,tag-one-line,DGT,dgt,TPG,tpg,help,version,debug:"
OPT=`getopt -o Dd:,hHvV --long $L_OP -- "$@"`
#OPT=`getopt -o Dd:,hHvV \
#	--long create-tag-tab,tag-seq:,tag-parsing:,tag-parsing-bydate:,tag-one-line,DGT,dgt,TPG,tpg,help,version,debug: -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

#echo OPT: $OPT
eval set -- "$OPT"
if [  $# -eq 1 ] ; then __show_help; fi
#echo $#, $1, $2, $3, $4
while true ; do
    case "$1" in
        --DGT|--dgt)	setting_DGT;    DGT ;    shift 	;    ;;
        --TPG|--tpg)    setting_TPG;    TPG ;    shift 	;    ;;
	--create-tag-tab) 
	    getclip | b5utf8 | d2u |egrep -v '(^seq|^\(0|^\"seq|title全為英文|^.*OR.*NOT)'; shift ;;
	--tag-seq)
	    case "$2" in
		'[:blank:]'*) cat types.tab2 | grep ^[$2]; shift 2;;
		[0-9]*)	    cat types.tab2 | grep ^[$2] ; shift 2 ;;
		""|[a-z]*|--*) shift ; cat types.tab2 | grep -v ^0 ;  ;;
	    esac 
	    #echo $1 $2
	    ;;
	--tag-one-line)	    tag_one_line ;    shift ;;
	--tag-parsing-bydate) tag_parsing_bydate $2 $3 $4; shift 3 ;;

	--tag-parsing)
		PARSE_D="`date  +%Y%m%d`"

		case "$2" in
		DGT)   tag_parsing "DGT" $PARSE_D ; shift 2 ;;
		TPG)   tag_parsing "TPG" $PARSE_D ; shift 2 ;;
		*) echo "error tag-parsing site ";  exit 1  ;;
		esac
		;;
        -d|--debug)
	    case "$2" in
		""|[a-z]*) 
		    #echo "Option debug, no argument"; 
		    DEBUG=0 ;	shift  ;;
                *)
		    #echo debug number: $DEBUG
		    DEBUG=$2 ;	shift 2    ;;
            esac 
	    if [ $DEBUG -eq 0 ] ; then      VERBOSE="--silent --show-error" ;	    fi
	    if [ "$DEBUG" -ge 200 ] ; then  VERBOSE="--silent --show-error" ; 	    fi
	    echo DEBUG: $DEBUG, VERBOSE: $VERBOSE
	    ;;
	--version|-v)	__show_version; shift	    ;;
	-h|--help) 	__show_help;    shift 	    ;;
        --)		shift   ;	break 	    ;;
	*)		shift 	;;
    esac
done

