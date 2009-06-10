#!/bin/bash
source wns_include.sh

# COMMON Functions.

cookie_string() {

    cat $1 | \
	grep -i Set-Cookie | \
	sed -e 's/^Set-Cookie: //g' -e 's/;.*$/;/g' | \
	tr '\n' ' ' | \
	sed 's/; $//g'
}

function site_root_path() {

    case "$1" in
    DGT)
        ret=$DGT_NEWS_LOC ;;
    TPG)
	ret=$TPG_NEWS_LOC ;;
    TCT)
	ret=$TCT_NEWS_LOC ;;
    UDN)
	ret=$UDN_NEWS_LOC ;;
    EET)
	ret=$EET_NEWS_LOC ;;
    EDG)
	ret=$EDG_NEWS_LOC ;;
    IEK)
	ret=$IEK_NEWS_LOC ;;
    MTR)
	ret=$MTR_NEWS_LOC ;;
    PCB)
	ret=$PCB_NEWS_LOC ;;
    *)
	ret="" ;;
    esac
    echo $ret
}

function site_rtf_header() {
    case "$1" in
    DGT)
        ret=$DGT_NAME ;;
    TPG)
	ret=$TPG_NAME ;;
    TCT)
	ret=$TCT_NAME ;;
    UDN)
	ret=$UDN_NAME ;;
    EET)
	ret=$EET_NAME ;;
    EDG)
	ret=$EDG_NAME ;;
    IEK)
	ret=$IEK_NAME ;;
    MTR)
	ret=$MTR_NAME ;;
    PCB)
	ret=$PCB_NAME ;;
    *)
	ret="" ;;
    esac
    echo "Create date: `date +%Y/%m/%d-%r` $ret"
}

function transfer_ht2txt0() {
		    #piconv -f big5 -t utf-8 | \

    if [ -d $_LOCATION ]; then
        rm -f $_LOCATION/*.txt 

	for i in `find $_LOCATION -type f| egrep -v '(txt$|rtf$)'` ; do
	    ./ht2html.pl  $i  2> /dev/nul | \
		    auto-utf8.pl | \
		    sed -e 's/&lt;.*&gt;//g' -e 's/&nbsp;//g' > $i.txt
            echo -n '.'
	done
    else
	echo -e "\tDirectory: $_LOCATION, is not exist."
	echo -e "\n\tI can't transfer data to TEXT format, Please check it."
    fi
    echo ""
}
function transfer_ht2txt() {
		    #piconv -f big5 -t utf-8 | \

    if [ -d $_LOCATION ]; then
        rm -f $_LOCATION/*.txt 

	for i in `find $_LOCATION -type f| egrep -v '(txt$|rtf$)'` ; do
	 cat  $i  2> /dev/nul | \
		    auto-utf8.pl | ht2html2.pl 2> /dev/null | \
		    sed -e 's/&lt;.*&gt;//g' -e 's/&nbsp;//g' > $i.txt
	    #./ht2html.pl  $i  2> /dev/nul | \
	#	    auto-utf8.pl | \
	#	    sed -e 's/&lt;.*&gt;//g' -e 's/&nbsp;//g' > $i.txt
            echo -n '.'
	done
    else
	echo -e "\tDirectory: $_LOCATION, is not exist."
	echo -e "\n\tI can't transfer data to TEXT format, Please check it."
    fi
    echo ""
}

function transfer_ht2txt2() {

    RAW_CODE="big5"
    if [ "$1". == "gb2312". ] ; then
	RAW_CODE="gb2312"
    fi

    if [ -d $_LOCATION ]; then
        rm -f $_LOCATION/*.txt 

	for i in `find $_LOCATION -type f| egrep -v '(txt$|rtf$|html$)'` ; do
	    cat $i | piconv -f "$RAW_CODE" -t utf-8 | perl ./ht2html2.pl   2> /dev/null | \
		    sed -e 's/&lt;.*&gt;//g' -e 's/&nbsp;//g' > $i.html
	    perl ./ht2html.pl $i.html 2> /dev/null | \
		    sed -e 's/&lt;.*&gt;//g' -e 's/&nbsp;//g' > $i.txt
            echo -n '.'
	done
    else
	echo -e "\tDirectory: $_LOCATION, is not exist."
	echo -e "\n\tI can't transfer data to TEXT format, Please check it."
    fi
    echo ""
}

function transfer_ht2txt3() {

    if [ -d $_LOCATION ]; then
        rm -f $_LOCATION/*.txt 

	for i in `find $_LOCATION -type f| egrep -v '(txt$|rtf$|html$)'` ; do
	    cat $i | auto-utf8.pl | perl ./ht2html2.pl   2> /dev/null | \
		    sed -e 's/&lt;.*&gt;//g' -e 's/&nbsp;//g' > $i.html
	    perl ./ht2html.pl $i.html 2> /dev/null | \
		    sed -e 's/&lt;.*&gt;//g' -e 's/&nbsp;//g' > $i.txt
            echo -n '.'
	done
    else
	echo -e "\tDirectory: $_LOCATION, is not exist."
	echo -e "\n\tI can't transfer data to TEXT format, Please check it."
    fi
    echo ""
}

transfer_ht2txt4() {

    RAW_CODE="big5"
    if [ "$1". == "gb2312". ] ; then
	RAW_CODE="gb2312"
    fi

    if [ -d $_LOCATION ]; then
        rm -f $_LOCATION/*.txt 

	for i in `find $_LOCATION -type f| egrep -v '(txt$|rtf$|html$)'` ; do
	    cat $i | piconv -f "$RAW_CODE" -t utf-8 | perl ./ht2html2.pl   2> /dev/null | \
		    sed -e 's/&lt;.*&gt;//g' -e 's/&nbsp;//g' > $i.html
	    cat $i.html | perl ht2html2.pl 2> /dev/null | \
		    sed -e 's/&lt;.*&gt;//g' -e 's/&nbsp;//g' > $i.txt
            echo -n '.'
	done
    else
	echo -e "\tDirectory: $_LOCATION, is not exist."
	echo -e "\n\tI can't transfer data to TEXT format, Please check it."
    fi
    echo ""
}

function transfer_txt2rtf() {

    if [ -d $_LOCATION ]; then
        rm -f $_LOCATION/*.rtf 

	for i in `find $_LOCATION/*.txt -type f` ; do
	    ln=`echo $i | sed -e 's/^.*\///g' -e 's/.txt//g'`
	    TITLE=`head -n $ln $_NEWS_REPORT | tail -n 1 | gawk -F '[.|,]' '{print $2}'`
	    #echo $i, $ln, $TITLE, $_NEWS_REPORT
	    (echo '<H1>'$TITLE'</H1>'; cat $i) | sed 's/。$/。<BR><BR>/g' | sed 's/; /<BR><BR>/g'  | \
		 ./ht2rtf.pl  2> /dev/nul > `echo $i|sed 's/.txt//g'`.rtf
            echo -n '.'
	done
    else
	echo -e "\tDirectory: $_LOCATION, is not exist."
	echo -e "\n\tI can't transfer data to TEXT format, Please check it."
    fi
    echo ""
}

function transfer_ht2rtf() {

    if [ -d $_LOCATION ]; then
        rm -f $_LOCATION/*.rtf 

	for i in `find $_LOCATION -type f | egrep -v '(txt$|rtf$)'` ; do
	    cat $i | piconv -f big5 -t utf-8 | ./ht2rtf.pl  2> /dev/nul > $i.rtf
            echo -n '.'
	done
    else
	echo -e "\tDirectory: $_LOCATION, is not exist."
	echo -e "\n\tI can't transfer data to TEXT format, Please check it."
    fi
    echo ""
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
    
    _logging "$FUNCNAME()" \
		"_NEWS_LIST_URL: $_NEWS_LIST_URL , _NEWS_LIST_RESULT: $_NEWS_LIST_RESULT"

    if [ "$_COOKIE_JAR". == "". ] ; then
	_logging "fetching... " "curl $VERBOSE -X get $_NEWS_LIST_URL --output $_NEWS_LIST_RESULT"
	curl $VERBOSE -X GET $_NEWS_LIST_URL --output $_NEWS_LIST_RESULT
    else    
	_logging "$FUNCNAME()" \
		"_COOKIE_JAR: $_COOKIE_JAR"
        curl $VERBOSE -b $_COOKIE_JAR \
	   -X get $_NEWS_LIST_URL  --output  $_NEWS_LIST_RESULT
    fi
}

# LOGIN / LOGOUT functions.
function login_post_to_SITE() {

    _logging "Function -> $FUNCNAME()" "_LOGIN_POST_URL: $_LOGIN_POST_URL"

#POST /$TPG_LOCAL_SIGN_URL HTTP/1.1
    curl $VERBOSE  -c $_COOKIE_JAR -D $_LOGIN_POST_HEADER\
	    -X POST --data-ascii "`
	    cat <<-EOF
		POST /$_LOCAL_SIGN_URL HTTP/1.1
		Content-type: application/x-www-form-urlencoded

		$_LOGIN_CONTENT
		EOF
		`" $_LOGIN_POST_URL \
	   --output $_LOGIN_POST_RESULT
}

function logout_from_SITE() {

    local __the_cookie_string
    if [ "$1". == "". ] ; then
	__the_cookie_string=$_COOKIE_JAR
    else
	__the_cookie_string="$1"
    fi

    _logging "Function -> $FUNCNAME()"  \
	"_LOGOUT_URL: $_LOGOUT_URL , _LOGOUT_RESULT: $_LOGOUT_RESULT, __the_cookie_string: $__the_cookie_string"

    #curl $VERBOSE -b $_COOKIE_JAR \
    #	    -X GET $_LOGOUT_URL	--output $_LOGOUT_RESULT 

    curl $VERBOSE -cookie "$__the_cookie_string" \
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
        echo $(expr substr `expr 1000 + $LCNT` 2 3 )"|"$this_line  >> $LIST_FILE
        echo $(expr substr `expr 1000 + $LCNT` 2 3 )"|"$article_url  >> $LIST_URL
	
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
    _LOCAL_SIGN_URL=$TPG_LOCAL_SIGN_URL

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

    _NEWS_REPORT=$TPG_LOCATION.listing
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
    _logging 'PHASE V: Transfer HTML to RTF'
    transfer_txt2rtf
}

source DGT.sh
source TCT.sh
source UDN.sh
source EET.sh
source EDG.sh
source IEK.sh
source MTR.sh
source PCB.sh

function ht2txt() {
    if [ "$__SITE". == "". ] ; then
        setting_DGT ;    transfer_ht2txt
	setting_TPG ;    transfer_ht2txt
        setting_TCT ;    transfer_ht2txt3
	setting_UDN ;    transfer_ht2txt3
        setting_EET ;    transfer_ht2txt2
	setting_EDG ;    transfer_ht2txt
        setting_MTR ;    transfer_ht2txt
	setting_PCB ;    transfer_ht2txt4
    else
	case "$__SITE" in
	    DGT) setting_DGT ;        transfer_ht2txt ;;
	    TPG) setting_TPG ;        transfer_ht2txt ;;
	    TCT) setting_TCT ;        transfer_ht2txt3 ;;
	    UDN) setting_UDN ;        transfer_ht2txt3 ;;
	    EET) setting_EET ;        transfer_ht2txt2 ;;
	    EDG) setting_EDG ;        transfer_ht2txt ;;
	    IEK) echo "IEK no ht2txt" ;;
	    MTR) setting_MTR ;        transfer_ht2txt ;;
	    PCB) setting_PCB ;        transfer_ht2txt4 ;;
	    xxx) echo "__SITE: $_SITE" ;;
	    *) echo Error pasing type: $1. ; return 1 ;
	esac
    fi
}
function txt2rtf() {
    if [ "$__SITE". == "". ] ; then
	setting_DGT ;        transfer_txt2rtf
	setting_TPG ;        transfer_txt2rtf
	setting_TCT ;        transfer_txt2rtf
	setting_UDN ;        transfer_txt2rtf
	setting_EET ;        transfer_txt2rtf
	setting_EDG ;        transfer_txt2rtf
	setting_MTR ;        transfer_txt2rtf
	setting_PCB ;        transfer_txt2rtf
    else
	case "$__SITE" in
	    DGT) setting_DGT ;        transfer_txt2rtf ;;
	    TPG) setting_TPG ;        transfer_txt2rtf ;;
	    TCT) setting_TCT ;        transfer_txt2rtf ;;
	    UDN) setting_UDN ;        transfer_txt2rtf ;;
	    EET) setting_EET ;        transfer_txt2rtf ;;
	    EDG) setting_EDG ;        transfer_txt2rtf ;;
	    IEK) echo "IEK no txt2rtf" ;;
	    MTR) setting_MTR ;        transfer_txt2rtf ;;
	    PCB) setting_PCB ;        transfer_txt2rtf ;;
	    xxx) echo "__SITE: $_SITE" ;;
	    *) echo Error pasing type: $1. ; return 1 ;
	esac
    fi
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
#    set +e
    #echo SHELLOPTS: $SHELLOPTS

    while true ; do

	local date_str=$start_d" "$i" day"
	local PARSE_DATE=`date  --date="$date_str" +%Y%m%d`
	#echo $PARSE_DATE, $date_str, $i

	case "$SITE_NAME" in 
	    DGT) local PARSED_F=$DGT_NEWS_LOC/$PARSE_DATE.listing ;;
	    TPG) local PARSED_F=$TPG_NEWS_LOC/$PARSE_DATE.listing ;;
	    TCT) local PARSED_F=$TCT_NEWS_LOC/$PARSE_DATE.listing ;;
	    UDN) local PARSED_F=$UDN_NEWS_LOC/$PARSE_DATE.listing ;;
	    EET) local PARSED_F=$EET_NEWS_LOC/$PARSE_DATE.listing ;;
	    EDG) local PARSED_F=$EDG_NEWS_LOC/$PARSE_DATE.listing ;;
	    IEK) local PARSED_F=$IEK_NEWS_LOC/$PARSE_DATE.listing ;;
	    MTR) local PARSED_F=$MTR_NEWS_LOC/$PARSE_DATE.listing ;;
	    PCB) local PARSED_F=$PCB_NEWS_LOC/$PARSE_DATE.listing ;;
	    xxx) local PARSED_F=$xxx_NEWS_LOC/$PARSE_DATE.listing ;;
	    *) echo Error pasing type: $1. ; return 1 ;
	esac 

	tag_parsing_file $PARSE_SEQ_F $PARSED_F $PARSE_DATE $SITE_NAME
	i=`expr $i + 1 `
	if [ $i == $days ] ; then break ; fi
	#echo $i, $days
    done
    
    rm -f $PARSE_SEQ_F
    #set -e
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
# (cat ../REPORT/*-parse.EDG)|  gawk -F '|' '{print $4}' | egrep  '^[[:alnum:]].*[[:blank:]][[:alnum:]].*[[:blank:]][[:alnum:]].*[[:blank:]][[:alnum:]].*[[:graph:]]$'

    local PARSE_SEQ_F=$1
    local PARSED_F=$2
    local PARSE_DATE=$3
    local SITE_NAME=$4

    exec 3<>$PARSE_SEQ_F

    while true ; do
	read -r THIS_L <&3
        EOF=$?

	if [ $EOF == 1 ] ; then break ; fi
	#echo SEQ_L: $THIS_L >&2
        SEQ=`echo $THIS_L | gawk -F '|' '{print $1}'`
	KEY=`echo $THIS_L | gawk -F '|' '{print $2}'`
        NOT=`echo $THIS_L | gawk -F '|' '{print $3}'`
	CONTENT=`echo $THIS_L | gawk -F '|' '{print $4}'`
        TAG=`echo $THIS_L | gawk -F '|' '{print $5}' |  sed -e 's/, /,/g' -e 's/, /,/g' -e 's/^ //g'`
	KEY=`echo $KEY | sed -e 's/, /,/g' -e 's/, /,/g'`
        #S_KEY='('`echo -n $KEY | sed -e 's/,/|/g' -e 's/\//\\\//g' -e 's/^,//g' -e 's/,$//g'`')'
        #S_KEY='('$(echo -n $KEY | sed -e 's/,/|/g' -e 's/\\/\\\\/g' -e 's/\//\\\//g' )')'
        S_KEY='('$(echo -n $KEY | sed -e 's/,/|/g' -e 's/\//\\\//g' )')'
	NOT=`echo $NOT | sed -e 's/, /,/g' -e 's/, /,/g'`
        S_NOT='('`echo -n $NOT | sed -e 's/,/|/g'`')'

	if [ "$S_NOT". == '()'. ] ; then S_NOT='(@@%%&&%%@@$$$$)' ; fi

        _logging "TAG: $TAG" "S_KEY: $S_KEY" "NOT: $NOT"
        _logging "SEQ: $SEQ, PARSE_DATE: $PARSE_DATE, S_NOT: \"$S_NOT\"" \
	         "s/$/|$TAG||$SEQ|$PARSE_DATE|$NOT/g"  \
	         "s/^/$SITE_NAME|$PARSE_DATE|/g" 

	#RE_TYPE="-E"
	RE_TYPE="-P"
        #cat "$PARSED_F" | egrep -i "$S_KEY" | \
	#    egrep -v "$S_NOT" | \
        cat "$PARSED_F" | grep "$RE_TYPE" -i "$S_KEY" | \
	    grep "$RE_TYPE" "$RE_TYPE" -iv "$S_NOT" | \
	    sed -e "s/$/|$TAG|$(echo -n $KEY| \
				    sed -e 's/\\/\\\\/g' -e 's/\//\\\//g')|$SEQ|$PARSE_DATE|$( \
				echo $NOT| sed -e 's/\\/\\\\/g' -e 's/\//\\\//g')/g" \
		-e "s/^/$SITE_NAME|$PARSE_DATE|/g"
	#1. $SITE_NAME
	#2. $PARSE_DATE
	#3. $SEQ
	#4. $TITLE
	#5. $TAG
	#6. $KEY
	#7. $SEQ
	#8. $PARSE_DATE
	#9. $NOT
    done

    #shopt -s execfail
    #exec 3>&-
    exec 3<&- 
}

function tag_one_line() {

    SORT_F=`mktemp`
    SEQ_F=`mktemp`
#   set +e
    cat <&0 > $SORT_F
    #cat $SORT_F | gawk -F '|' '{print $1"|"$2"|"$3}' | gawk -F '[.,]' '{print $1}' | sort |uniq > $SEQ_F
    cat $SORT_F | gawk -F '|' '{print $1"|"$2"|"$3}' | sort |uniq > $SEQ_F
    #cat $SEQ_F
    exec 3<>$SEQ_F

    L_NUM=`cat $SORT_F | tail -n 1 | gawk -F '|' '{print $2}' | gawk -F '.' '{print $1}'`
    while true ; do
	#echo -n '.' >&2
	read L_CNT <&3
	EOF=$?
	if [ $EOF == 1 ] ; then break ; fi

	#grep -i '|'$L_CNT'[.|,]' $SORT_F 
	#TITLE=`grep -i $L_CNT $SORT_F | gawk -F '|' '{print $3}' | gawk -F '[.,]' '{print $2 $3 $4}' | head -n 1`
	TITLE=`grep -i $L_CNT $SORT_F | gawk -F '|' '{print $4}' | head -n 1`
	#echo $TITLE
	#TAGS=`grep -i $L_CNT $SORT_F | \
	#	gawk -F '|' '{print $4}' | tr ',' '\n' | \
	#	sort |uniq | tr '\n' ',' | sed 's/,$//g'`
	TAGS=`grep -i $L_CNT $SORT_F | \
		gawk -F '|' '{print $5}' | tr ',' '\n' | \
		sort |uniq | tr '\n' ',' | sed 's/,$//g'`
	echo  $L_CNT'|'$TITLE'|'$TAGS
    done
    echo "" >&2
    exec 3>&-
    rm -f $SORT_F $SEQ_F
    #set -e
}

function add_folder_tag () {

    FOLDER_TAG_TABLE=folder.tab

    #set +e
    if [ $1. == "". ] ; then
	ARTICLE_TAG_REPORT=`mktemp`
        cat <&0 > $ARTICLE_TAG_REPORT
    else
	ARTICLE_TAG_REPORT=$1
    fi

    FOLDER_TAG=`mktemp`

    cat $FOLDER_TAG_TABLE | egrep -v ^0 |  sort > $FOLDER_TAG
    #cat folder.tab | egrep  ^7 |  sort > $FOLDER_TAG

    exec 4<>$ARTICLE_TAG_REPORT
    while true; do

	read article <&4
        ART_EOF=$?
	if [ $ART_EOF == 1 ] ; then break ; fi
    
        SITE=`echo $article | gawk -F '|' '{print $1}'`
        DATE=`echo $article | gawk -F '|' '{print $2}'`
	SEQ=`echo $article | gawk -F '|' '{print $3}'`
	TITLE=`echo $article | gawk -F '|' '{print $4}'`
        TAGS=`echo $article | gawk -F '|' '{print $5}'`

	location=""
        #echo SITE: $SITE, TAGS: $TAGS
	# "folder.tab" 
        exec 3<>$FOLDER_TAG
	while true; do
	    read line <&3
	    EOF=$?

	    if [ $EOF == 1 ] ; then break ; fi

	    TAR_SEQ=`echo $line | gawk -F '|' '{print $1}'`
	    TAR_TAG='('`echo $line | gawk -F '|' '{print $7}'| \
		    sed -e 's/ or /|/g' -e 's/"//g' -e 's/, /,/g' -e 's/ and /.*/g' |\
		    sed 's/^ //g' | sed 's/,/|/g'`')'
	    NOT_FIELD="`echo $line | gawk -F '|' '{print $8}'`"
	    NOT_TAG="(`echo $NOT_FIELD | \
		    sed -e 's/,/|/g' -e 's/ and /.*/g' -e 's/ /[|,]/g' -e 's/^/[|,]/g'`)"

	    if [ "$TAR_TAG". == "". ] ; then TAR_TAG='@@@###' ; fi
	    #echo $TAGS | grep "$TAR_TAG"
	    #_logging "TITLE: $TITLE" "TAG: $TAGS" "TAR_TAG: $TAR_TAG, NOT_TAG: $NOT_TAG"
	    if [ "$NOT_FIELD". == "". ] ; then
	        STR="`echo $TAGS | egrep "$TAR_TAG"`"
	    else
	        STR="`echo $TAGS | egrep "$TAR_TAG" | egrep -v "$NOT_TAG"`"
	    fi
	
	    #echo TAGS: $TAGS, TAR_TAG: \"$TAR_TAG\", STR: $STR

	    if [ "$STR". != "". ] ; then
	        dir_1=`echo $line | gawk -F '|' '{print $2}'| sed -e 's/ //g'`
		if [ "$dir_1". == "Digitimes-英文報". ] ; then
		    dir_2="`date +%Y`"
		    dir_3="`date '+%Y %B'`"
		    dir_4="`date '+%m%d'`"
		else
		    dir_2=`expr substr $DATE 1 4``echo $line | gawk -F '|' '{print $3}'| \
			sed -e 's/ //g' -e 's/[0-9]//g'`
		    dir_3="$(expr substr $DATE 1 4)"年"$(expr `expr substr $DATE 5 2` + 0)"月
		    dir_4="$(expr `expr substr $DATE 5 2` + 0)"月"$(expr `expr substr $DATE 7 8` + 0 )"日
		fi
	        dir_5=`echo $line | gawk -F '|' '{print $6}' | sed -e 's/ //g'`
	        location="$dir_1/$dir_2/$dir_3/$dir_4/$dir_5"

	        #echo ---- TAGS: $TAGS, TAR_TAG: \"$TAR_TAG\", STR: $STR
	        #echo artical title: $TITLE
	        #echo artical tags: $TAGS
	        #echo location tag: \"$TAR_TAG\"
	        #echo directory: $dir_1/$dir_2/$dir_3/$dir_4/$dir_5
	        echo $article'|'$(echo $TAR_TAG|sed -e  's/|/,/g' -e 's/^(//g' -e 's/)$//g')'|'$location
	        _logging "TARGETED TITLE: $TITLE, Location: $location" \
			    "TAG: $TAGS" "TAR_TAG: $TAR_TAG, NOT_TAG: $NOT_TAG"
	        break
	    fi
	done
	exec 3>&-

    done

    exec 4>&-

    rm -f $FOLDER_TAG
    if [ $1. == "". ] ; then
	rm -f $ARTICLE_TAG_REPORT
    fi
    #set -e
}

function move_folder() {

    #NEWS_ROOT_PATH=./WNS_RTF # define in wns.cfg.
    local TAG_TODAY="(`date +%Y%m%d`)"
    NEWS_EXTEN=".rtf"
    current_dir=`pwd`
    while true ; do

	read FLR <&0
        EOF_FLR=$?
	if [ $EOF_FLR == 1 ] ; then break; fi
	SITE_CODE="$(echo $FLR | gawk -F "|" '{print $1}')"
	SITE=$(site_root_path "`echo $FLR | gawk -F "|" '{print $1}'`")
	DATE=`echo $FLR | gawk -F "|" '{print $2}'`
        SEQ="$(expr $(echo $FLR | gawk -F "|" '{print $3}') + 0 )""$NEWS_EXTEN"
	TARGET="`echo $FLR | gawk -F "|" '{print $4}' | \
		sed -e 's/^ //g' -e 's/ $//g' -e 's/?/？/g' -e 's/\//／/g'`"
	TAGS="`echo $FLR | gawk -F "|" '{print $5}'`"

        LOCATION="$NEWS_ROOT_PATH/`echo $FLR | gawk -F "|" '{print $7}'`"
	
        SRC="$SITE/$DATE/$SEQ"
	DEST="$LOCATION/$SITE_CODE-$TARGET$TAG_TODAY"
    
        #echo move $SRC to $DEST
	RTF_FILE="$DEST$NEWS_EXTEN"
	TOUCH_FILE="$DEST""　""KEY：$TAGS"
	#TOUCH_FILE="`echo $TOUCH_FILE | sed 's/ //g'`"
	mkdir -p "$LOCATION"
	_logging "\$SRC: $SRC" "\$RTF_FILE: $RTF_FILE" "\$SITE: $SITE, \$SITE_CODE: $SITE_CODE"
        cp "$SRC" "$RTF_FILE"

	dir_d=`dirname "$RTF_FILE"`
	target=`basename "$RTF_FILE"`
	shortcut=`basename "$TOUCH_FILE"`
	_logging "shortcut: $shortcut" "target: $target" "dir_d: $dir_d"

	pushd "$current_dir"
	cd "$dir_d"
	ln -sf "$target" "$shortcut"
	_logging "SRC: $SRC, RTF_FILE: $RTF_FILE" "LOCATION: $LOCATION" "target: $target, shortcut: $shortcut"
	#mkshortcut -n "`echo -n $shortcut|piconv -f utf-8 -t big5`" \
	#	-w ./ \
	#	"./`echo $target| piconv -f utf-8 -t big5`" 2> /dev/null
	ret_touch=$?
	attrib +h +A "$shortcut".lnk
	popd
	echo -n "."

    done
}

function tag_txt2rtf() {
    header="`perl rtf-header.pl| sed 's/\\\\chpgn//g' | tr '\n' ' ' | sed -e 's/^ //g' -e 's|\\\\|\\\\\\\\|g'`"
    orig_header='^{\\header\\pard\\qr\\plain\\f2\\fs17$'
    remove_string='.*\\chpgn\\par}$'

    while true ; do
	read FLR <&0
	FLR_EOF=$?
	if [ $FLR_EOF == 1 ] ; then break ; fi
	SCODE="`echo $FLR | gawk -F "|" '{print $1}'`"
	SITE=$(site_root_path "$SCODE")
	DATE=`echo $FLR | gawk -F "|" '{print $2}'`
        SEQ="$(expr $(echo $FLR | gawk -F "|" '{print $3}') + 0 )"
	TITLE="`echo $FLR | gawk -F "|" '{print $4}' | \
		sed -e 's/^ //g' -e 's/ $//g' -e 's/?/？/g'`"
	TAGS="`echo $FLR | gawk -F "|" '{print $5}'`"
	TXT_F=$SITE/$DATE/$SEQ.txt
	RTF_F=$SITE/$DATE/$SEQ.rtf
	#echo $SITE, $DATE, $SEQ, $TARGET, $TAGS	
	header="`perl rtf-header.pl "$(site_rtf_header $SCODE)" | sed 's/\\\\chpgn//g' | tr '\n' ' ' | \
		 sed -e 's/^ //g' -e 's|\\\\|\\\\\\\\|g'`"
	echo $TXT_F, $TAGS
	#(echo '<H1>'$TITLE'</H1><BR>'; cat $TXT_F; echo '<BR><BR><BR>' Keyword: $TAGS '<BR>') | \
	#    sed 's/。$/。<BR><BR>/g' | \
	#    sed 's/。 /。<BR><BR>/g' | \
	#    sed 's/; /<BR><BR>/g'  | \
#		 ./ht2rtf.pl  2> /dev/nul | \
#		 sed -e "s/$remove_string//g" -e "s|$orig_header|$header|g" > $RTF_F
	(echo '<H1>'$TITLE'</H1><BR>'; cat $TXT_F; echo '<BR><BR><BR>' Keyword: $TAGS '<BR>') | \
		 ./ht2rtf.pl  2> /dev/nul | \
		 sed -e "s/$remove_string//g" -e "s|$orig_header|$header|g" > $RTF_F
    done
}

__show_help() {
	cat <<-_EOF
		${_name} is a fetch web news program.

		Usage: ${_name} [[ -d <value> | --debug <value>] < --SITE > | [--help|--version]
		Tags usage: ${_name} --tag-seq [seq] | --tag-parsing-bydate < SITE > <date> <daynum> ] |
		             [ [...parsing-parametrs] --tag-parsing < SITE >] | --tag-one-line 
		Tab usage: ${_name}  --create-tag-tab | --create-folder-tab
		folder tag: ${_name} --add-folder-tag | --move-folder [ fldr-tag-report ]
		transfer : ${_name} --site <SITE> [ --ht2txt ] [ --txt2rtf ]

		    -d, --debug <value> : setup debug value;  --site <SITE> : define \$__SITE value
		    --tag-seq [seq]: parse specific seq no from tags table(types.tab). seq(ref)
		    --tag-parsing:	    ;	--tag-parsing-bydate: 
		    --tag-one-line: after --tag-paring* you can format duplicated title to one line.
		    ...parsing-parameters: no implement.
		    --add-folder-tag: read from "tag-report" and add "folder tag and location| fldr tag report"
		    --move-folder: according fldr-report move article to tag folder.
		    --create-tag-tab: output tags table to STDOUT from clipboard.
		    --create-folder-tab: output folder table to STDOUT from clipboard.

		    --help: show this message.;	    --version: show version.
		    SITE: --TPG | --DGT | --TCT | --UDN | --EET | --EDG | --IEK | --MTR | --PCB
		    REF:    seq exampe: 135, 1-5, 12345, 1-9, 0-9, -- ; '--' is all seq.
		            Tags example: ${_name} --tag-seq 1-3 | ${_name} --tag-parsing < DGT | TPG >
		                          ${_name} --tag-seq 135 | ${_name} --tag-parsing < DGT | TPG >
		            Tags parsing: parsing DGT from 20090204, parse 2 days (20090204, 20090205)
		                          ${_name} --tag-parsing-bydate "DGT 20090204 2"
		    STEP:
		        ${_name} --debug 300 --DGT ; ${_name} --debug 300 --TPG	#fetch article, result listing.
		        ${_name} --tag-seq -- | ${_name} --tag-parsing-bydate "DGT 20090206 1" > res.1 #parse-res
		        ${_name} --tag-seq -- | ${_name} --tag-parsing-bydate "TPG 20090206 1" > res.2
		        cat res.1 res.2 | ${_name} --tag-one-line > 20090206.tag-report ;# tag-report
		        cat 20090206.tag-report | ${_name} --add-folder-tag > 20090206.fldr-report #fldr-report
		        cat 20090206.fldr-report | ${_name} --move-folder 
		        ${_name} --txt2rtf | --ht2txt ; or:\$  ${_name} --site DGT --txt2rt --ht2txt
		        cat 20090206.tag-report | ${_name} --tag-txt2rtf
		_EOF
}

readonly -f __show_help 

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
COMMON_OP="help,version,debug:,site:"
SITE_OP="DGT,TPG,TCT,UDN,EET,EDG,IEK,MTR,PCB"
FETCH_OP="txt2rtf,ht2txt"
TAG_OP="tag-seq:,tag-parsing:,tag-parsing-bydate:,tag-one-line,tag-txt2rtf"
FLDR_OP="add-folder-tag,move-folder"
TAB_OP="create-tag-tab,create-folder-tab"
ALL_OP="$SITE_OP,$TAB_OP,$TAG_OP,$FETCH_OP,$COMMON_OP,$FLDR_OP"
OPT=`getopt -o Dd:,hHvV --long $ALL_OP -- "$@"`
#OPT=`getopt -o Dd:,hHvV \
#	--long create-tag-tab,tag-seq:,tag-parsing:,tag-parsing-bydate:,tag-one-line,DGT,dgt,TPG,tpg,help,version,debug: -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

__SITE=""

#echo OPT: $OPT
eval set -- "$OPT"
if [  $# -eq 1 ] ; then __show_help; fi
#echo $#, $1, $2, $3, $4
set +e
while true ; do
    case "$1" in
        --DGT)	setting_DGT;    DGT ;    shift 	;    ;;
        --TPG)    setting_TPG;    TPG ;    shift 	;    ;;
        --TCT)    setting_TCT;    TCT ;    shift 	;    ;;
        --UDN)    setting_UDN;    UDN ;    shift 	;    ;;
        --EET)    setting_EET;    EET ;    shift 	;    ;;
        --EDG)    setting_EDG;    EDG ;    shift 	;    ;;
        --IEK)    setting_IEK;    IEK ;    shift 	;    ;;
        --MTR)    setting_MTR;    MTR ;    shift 	;    ;;
        --PCB)    setting_PCB;    PCB ;    shift 	;    ;;
	--txt2rtf)	txt2rtf; shift ;;
	--ht2txt)	ht2txt; shift ;;
	--tag-txt2rtf)  tag_txt2rtf; shift ;; 
	--create-tag-tab) 
	    getclip | b5utf8 | d2u |egrep -v '(^seq|^\(0|^\"seq|title全為英文|^.*OR.*NOT)'; shift ;;
	--create-folder-tab) 
	    getclip | tail -n `expr $(getclip | wc -l) - 3`| \
		 b5utf8 | d2u |egrep -v '(^seq|^\(0|^\"seq|\|$)' ; shift ;;
	--tag-seq)
	    case "$2" in
		'[:blank:]'*) cat types.tab2 | grep ^[$2]; shift 2;;
		[0-9]*)	    cat types.tab2 | grep ^[$2] ; shift 2 ;;
		""|[a-z]*|--*) shift ; cat types.tab2 | grep -v ^0 ;  ;;
	    esac 
	    #echo $1 $2
	    ;;
	--site) __SITE="$2"; shift ;;
	--tag-one-line)	    tag_one_line ;    shift ;;
	--tag-parsing-bydate) tag_parsing_bydate $2 $3 $4; shift 2 ;;

	--tag-parsing)
		PARSE_D="`date  +%Y%m%d`"

		case "$2" in
		DGT)   tag_parsing "DGT" $PARSE_D ; shift 2 ;;
		TPG)   tag_parsing "TPG" $PARSE_D ; shift 2 ;;
		*) echo "error tag-parsing site ";  exit 1  ;;
		esac
		;;
	--add-folder-tag) add_folder_tag ; shift ;;
	--move-folder) move_folder; shift ;;
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
    #echo OPT: $OPT
      
done

