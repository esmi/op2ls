#!/bin/bash

function login_to_DGT() {
    
    # STEP_1 : LOGIN
    echo -e '\tStep1: LOGIN TO "CHECK SITE".'
    LOGIN_STRING="ID=$GDT_USR_ID&Password=$GDT_USR_PWD&MyID=$GDT_MY_ID&MyPwd=$GDT_MY_PWD"

    if [ $DEBUG -gt 200 ] ; then
	echo LOGIN_STRING: $LOGIN_STRING
    fi

    curl $VERBOSE -c $DGT_COOKIE_JAR -D $DGT_LOGIN_HEADER \
	-X POST --data-ascii "$LOGIN_STRING" $DGT_LOGIN_URL >  $DGT_LOGIN_RESULT

    RET_CODE=$?
    RETURN_OK=`cat $DGT_LOGIN_HEADER | grep -i ^HTTP.*200`

    # STEP 1.1: CHECK STEP_1 's return status, if error show message.
    if [ "$RETURN_OK". == "". ] ; then
	echo -e '\tStep1.1: CHECK "CHECK SITE" response code.'
	if [ $DEBUG -gt 200 ] ; then
	    echo -e "\t\tlogin return code: $RET_CODE"
	    echo -e "\t\tLOGIN RETURN CODE: $RETURN_OK"
	fi
	logout_from_DGT

	echo -e "\t\tError Message: "`grep -i location $DGT_LOGIN_HEADER | piconv -f big5 -t utf-8`
	echo -e "\t\tTry re-logout from $DGT_LOGOUT_URL, $DGT_LOGOUT_OK_URL."
	echo -e "\t\tPlease try again...."
	exit 1
    fi
    
    echo -e "\tStep2: LOGIN POST STEP 2."
    login_post_to_DGT
}

function login_post_to_DGT() {

    curl $VERBOSE -b $DGT_COOKIE_JAR -D $DGT_LOGIN_POST_HEADER \
	-X POST --data-ascii "`
	    cat $DGT_LOGIN_RESULT | sed 's/>/>;/g' | tr ';' '\n' | \
		    egrep -i '(input)' | \
		    sed -e 's/^.*name=//g' -e 's/ value//g' -e 's/>//g' \
		    -e "s/'//g" -e "s/yUID$/yUID=$GDT_MY_UID/g" | \
		    tr '\n' '&' | sed 's/&$//g' 
	    `"	$DGT_LOGIN_POST_URL --output $DGT_LOGIN_POST_RESULT
}


function logout_from_DGT() {

    curl $VERBOSE -b $DGT_COOKIE_JAR \
	    -X GET $DGT_LOGOUT_URL	--output $DGT_LOGOUT_RESULT \
	    -X GET $DGT_LOGOUT_OK_URL   --output $DGT_LOGOUT_OK_RESULT
}

function fetch_news_list_DGT() {

    #ORIG_FILE=$NEWS_LIST
    ORIG_FILE=$DGT_NEWS_LIST_RESULT
    WORK_FILE=`mktemp`
    TEMP_FILE=`mktemp`

    #DGT_NEWS_LOC=DIGITIMES
    #GDT_LOCATION="./$DGT_NEWS_LOC/`date +%Y%m%d`"
    LIST_FILE="./$DGT_NEWS_LOC/`date +%Y%m%d`".listing
    mkdir -p $GDT_LOCATION

    cat $ORIG_FILE | \
	sed  -e 's|<img src.*><td|<td|g' | \
        egrep -i '(shownew|href)'  | egrep -v '(img|var|function|location\.|link.*css|history.)' | \
	sed -e 's|<td class=.*hc.*ShowNews(||g' -e 's|)>|,|g' -e 's/^.*<a href.*addcols.asp"//g' -e 's/).*>//g' \
	    | egrep -v '(<tr>|<a href)' > $WORK_FILE


    LINES="$(echo  `wc -l $WORK_FILE | awk '{print $1}' ` / 2 | bc)"

    cat $WORK_FILE | piconv -f big5 -t utf-8 | \
	tr -t '>\n' '>  ' | \
	sed 's/,""/,""\&/g' |\
	tr '&' '\n' | \
	sed -e "s/'//g" -e 's/"//g' |\
	head -n $LINES  > $TEMP_FILE

    LCNT=1
    #debug set $LINE=1
    #LINES=1

    #echo $WORK_FILE LINES: $LINES
    while [ $LCNT -le $LINES ] ; do

	header="$GDT_URL"'&s=1&news_filter=all&s=11&s=13&s=15&s=19&s=23'

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

	#echo $this_line >> $GDT_LOCATION/$LIST_FILE
        echo $(expr substr `expr 1000 + $LCNT` 2 3 ), $this_line | \
	    gawk -F ',' '{print $1". " $4}' | sed 's/<td>//g' >> $LIST_FILE

	tailer='f=A&PgSize=5&yS=31&yAddMulitColsFrom=news'
        jumpout_made="JumpOut="$header'&'$from'&'$to'&'$p'&'$date_publish'&'$pages'&'$all_seq'&'$tailer
	#echo MADMAT: $jumpout_made
        jumpout="`echo $jumpout_made | perl -MURI::Escape -ne 'print uri_escape($_);' | \
		sed -e 's/%0A$//g' -e 's/%3D/=/g' -e 's/%26/\&/g'`"
	#echo ---
	#	    cat <<-EOF
	#		POST /n/ShwNws.asp HTTP/1.1
	#		Content-type: application/x-www-form-urlencoded
	#
	#		$jumpout		
	#		EOF
	#echo 		 $DGT_SHOWNEWS_URL 

	curl $VERBOSE -b $DGT_COOKIE_JAR \
	    -X POST --data-ascii "`
	    cat <<-EOF
		POST /n/ShwNws.asp HTTP/1.1
		Content-type: application/x-www-form-urlencoded

		$jumpout		
		EOF
		`" $DGT_SHOWNEWS_URL \
	   --output $GDT_LOCATION/$LCNT 

        if [ $DEBUG -gt 200 ] ; then
	   echo FORMAT: $jumpout
	fi
        echo -n '.'
	LCNT=`expr $LCNT + 1`
    done

    if [ $DEBUG -gt 200 ] ; then
	echo ORIMAT: 'JumpOut=http%3A%2F%2F'"$SITE_NAME"'&s=1&news_filter=all&s=11&s=13&s=15&s=19&s=23&from_year=2008&from_month=10&from_day=15&to_year=2009&to_month=01&to_day=14&p=%B7j%B4M%C3%F6%C1%E4%A6r&DatePublish=2009%2F01%2F14&Pages=X1&All_Seq=1&f=A&PgSize=5&yS=31&yAddMulitColsFrom=news'
    fi

    rm -f $WORK_FILE
    rm -f $TEMP_FILE
}

function transfer_ht2txt_DGT() {
    transfer_ht2txt
}

function transfer_ht2txt() {


    if [ -d $GDT_LOCATION ]; then
        rm -f $GDT_LOCATION/*.txt 

	for i in `find $GDT_LOCATION -type f` ; do
	    ./dgt_ht2txt.pl  $i  2> /dev/nul | piconv -f big5 -t utf-8 > $i.txt
            echo -n '.'
	done
    else
	echo -e "\tDirectory: $GDT_LOCATION, is not exist."
	echo -e "\n\tI can't transfer data to TEXT format, Please check it."
    fi
}
#  END OF FUNCTIONs..............................................................................

# MAIN()
#
# BEGIN OF DATA CONFIGURATION...................................................................
#   Private data locate in "WNS.CFG", it contain :
#   $GDT_USR_ID, $GDT_USR_PWD, $GDT_MY_UID, $GDT_MY_PWD, $SITE_NAME and $DGT_NEWS_LOC
#

DATA_PATH=../wns_cfg
WNS_CONFIG="$DATA_PATH/wns.cfg"
WNS_LOG=../wns_log

if ! [  -a $WNS_CONFIG ] ; then
    echo WNS_CONFIG FILE: $WNS_CONFIG , is not exist...
    echo please check WNS_CONFIG FILE.
    exit 1
fi

source $WNS_CONFIG
# Begin of DGT CFG of "$WNS_CONFIG".............................................................
#GDT_USR_ID=
#GDT_USR_PWD=
#GDT_MY_UID=
#GDT_MY_PWD=
#GDT_SITE=
#DGT_NEWS_LOC=DIGITIMES

# other data setup.......
GDT_MY_ID="`echo -n $GDT_MY_UID | perl -MURI::Escape -ne 'print uri_escape($_);'`"
GDT_LOCATION="./$DGT_NEWS_LOC/`date +%Y%m%d`"
GDT_URL=http://$GDT_SITE

DGT_LOGIN_URL=$GDT_URL/lgn/check.asp
DGT_LOGIN_HEADER=$WNS_LOG/DGT_LOGIN.header
DGT_LOGIN_RESULT=$WNS_LOG/DGT_LOGIN.result

DGT_LOGIN_POST_URL=$GDT_URL/default.asp
DGT_LOGIN_POST_HEADER=$WNS_LOG/DGT_LOGIN_POST.header
DGT_LOGIN_POST_RESULT=$WNS_LOG/DGT_LOGIN_POST.result

DGT_LOGOUT_URL=$GDT_URL/asp/buttonlogout.asp
DGT_LOGOUT_RESULT=$WNS_LOG/DGT_LOGOUT.result
DGT_LOGOUT_OK_URL=$GDT_URL/asp/logout_ok.asp?user_id=$GDT_USR_ID
DGT_LOGOUT_OK_RESULT=$WNS_LOG/DGT_LOGOUT_OK.result

DGT_NEWS_LIST_URL=$GDT_URL/n/nwslst.asp
DGT_NEWS_LIST_RESULT=$WNS_LOG/DGT_NEWS_LIST.result
DGT_SHOWNEWS_URL="$GDT_URL/n/ShwNws.asp"

DGT_COOKIE_JAR=$WNS_LOG/DGT_COOKIE.jar

# DEBUG CONFIGURATION............................................................................
DEBUG=300
DEBUG=0

if [ $DEBUG -eq 0 ] ; then
    VERBOSE="--silent --show-error"
fi

if [ "$DEBUG" -gt 200 ] ; then
    cat <<-EOF
	ID=$GDT_USR_ID&Password=$GDT_USR_PWD&MyID=$GDT_MY_ID&MyPwd=$GDT_MY_PWD
	EOF
fi

# Begin MAIN Procedure...........................................................................
echo 'PHASE I: LOGIN'
login_to_DGT

echo 'PHASE II: GET NEWS LISTING'
curl $VERBOSE -b $DGT_COOKIE_JAR \
	-X get $DGT_NEWS_LIST_URL  --output  $DGT_NEWS_LIST_RESULT

echo 'PHASE III: FETCH NEWS'
#NEWS_LIST=$DGT_NEWS_LIST_RESULT
#fetch_news_list_DGT

echo 'PHASE IV: LOGOUT'
logout_from_DGT

echo 'PHASE V: Transfer HTML to TEXT'
transfer_ht2txt_DGT

# End of MAIN()..................................................................................

