#!/bin/bash
#VERBOSE=-v

# read $WLURL_HEAD from wl-query.cfg
source $DATA_ENV_D/wl-query.conf

WLPLE_POST=$WL_URL'/intranet/index.php?link=6&page=2'

COOKIE=cookie.jar
DATA_POST=data.post
HEADER=header.txt
QUERY_RESULT=result.html

DUMPER="w3m -T text/html -dump"
eg_s1='(員工編號|英文姓名|連絡電話|座位分機|部　　門)' 
eg_s2='中/英姓名' 

# $WLPLE_POST is BIG5 decode, $NAME_ESCAPE is convert $NAME to BIG5's escape seq.
#NAME=E
NAME=$1

if [ `expr $LANG : .*UTF` == 0 ]; then
    #NONE UTF8
    CVRT_NAME=$NAME
    eg_str1="`echo $eg_s1 | piconv -f utf-8 -t big5`"
    eg_str2="`echo $eg_s2 | piconv -f utf-8 -t big5`"
else
    CVRT_NAME="`echo $NAME | piconv -f utf-8 -t big5`"
    eg_str1=$eg_s1
    eg_str2=$eg_s2
fi
FILTER1="egrep $eg_str1" 
FILTER2="grep -v $eg_str2"
NAME_ESCAPE="`echo $CVRT_NAME | perl -MURI::Escape -ne 'print uri_escape($_);' | sed 's/%0A$//g' `"
#echo $NAME_ESCAPE

#curl $VERBOSE -s -c $COOKIE -D $HEADER -X POST --data-binary "`
curl $VERBOSE -s -c $COOKIE  -X POST --data-binary "`
    cat <<-EOF  
	POST /intranet/index.php?link=6&page=2 HTTP/1.0
	Content-type: application/x-www-form-urlencoded

	select_company=&xx=&select_unit=&search_name=$NAME_ESCAPE&Image4411.x=0&Image4411.y=0
	EOF 
	`"	$WLPLE_POST  | \
		$DUMPER	    | \
		$FILTER1 | \
		$FILTER2 | \
		sed -e 's/\[.*\]//g' -e 's/︰//g' -e 's/       //g' | \
		gawk '{print $1,$2; print $3,$4; }'

#FILTER1	#egrep   '(員工編號|英文姓名|連絡電話|座位分機|部　　門)' 
#FILTER2	#\| grep -v '中/英姓名' | \

#RET_CODE=$?
#RETURN_OK=`cat $HEADER | grep -i ^HTTP.*200 | tr '\n' ';'`
#echo RETURN_OK CODE: $RET_CODE, MESSAGE: $RETURN_OK

#rm -f $COOKIE $HEADER

# TEMPLATE( curl --data-binary)
#cat <<-EOF > test.post
#	POST /intranet/index.php?link=6&page=2 HTTP/1.0
#	Content-type: application/x-www-form-urlencoded
#
#	select_company=&xx=&select_unit=&search_name=$NAME_ESCAPE&Image4411.x=0&Image4411.y=0
#	EOF

#DATA_POST=test.post
#curl $VERBOSE -s -c cookie-jar.file -D $HEADER -X POST --data-ascii "`cat $DATA_POST`" \
#	$WLPLE_POST
