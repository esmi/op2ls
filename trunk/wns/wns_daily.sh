#!/bin/bash

source ./wns_cfg/wns.cfg

TODAY="`date +%Y%m%d`"
REPORT=../REPORT
LOG=../LOG

if [ ! -d $DGT_NEWS_LOC ] ; then mkdir $DGT_NEWS_LOC ; fi
if [ ! -d $TPG_NEWS_LOC ] ; then mkdir $TPG_NEWS_LOC ; fi
if [ ! -d $TCT_NEWS_LOC ] ; then mkdir $TCT_NEWS_LOC ; fi
if [ ! -d $UDN_NEWS_LOC ] ; then mkdir $UDN_NEWS_LOC ; fi
if [ ! -d $EET_NEWS_LOC ] ; then mkdir $EET_NEWS_LOC ; fi
if [ ! -d $EDG_NEWS_LOC ] ; then mkdir $EDG_NEWS_LOC ; fi
if [ ! -d $IEK_NEWS_LOC ] ; then mkdir $IEK_NEWS_LOC ; fi
if [ ! -d $MTR_NEWS_LOC ] ; then mkdir $MTR_NEWS_LOC ; fi
if [ ! -d $PCB_NEWS_LOC ] ; then mkdir $PCB_NEWS_LOC ; fi
if [ ! -d $LOG ] ; then mkdir $LOG ; fi
if [ ! -d $REPORT ] ; then mkdir $REPORT ; fi
#
#PS: KH-NAS every morning, reboot time: am7:40 - am8:10
#
#NAS_HOST=
NAS_SHARE="\\\\kh-nas\\Project"
NAS_BASE='//kh-nas/Project/新產品開發專案管理/新產品開發專案管理/BI_經企/以程式處理BI資訊'
#NAS_PWD=_
#NAS_USR=

__abort=false
_name=`basename $0`

function fetch_news() {
    local i=1
    #local sleep_t=30m
    local sleep_t=10s
    local times=3
    local abort=false
    echo DGT procedure starting.....
    
    while true ; do

	if [ $i -gt $times ] ; then 
	    echo DGT login $i times fail, program will abort ;
	    abort=true  
	    break;
	else
	    set +e 
	    wns.sh --debug 300 --DGT 
	    set -e
	    abort=false
	fi 

        if [ -e DGTERR ] ; then
	    echo DGT SITE LOGIN ERROR, SLEEP $sleep_t minutes , please waiting.
	    sleep $sleep_t 
        else
	    break
	fi

        let i++

    done
    if [ $abort == true ] ; then 
	echo abort: $abort , will abort, please try again manual.
	if [ $__abort == true ] ; then
	    exit 1
	fi
    fi
    echo TPG procedure starting.....
    wns.sh --debug 300 --TPG --TCT --UDN --EET --EDG --MTR --PCB
    #wns.sh --debug 300 --TCT
    #wns.sh --debug 300 --UDN
    #wns.sh --debug 300 --EET
    #wns.sh --debug 300 --EDG
}

function __fetch() {

    fetch_news 2>&1  
    #| tee $LOG/$TODAY-fetch.log
    ret=$?
    echo return value $ret
}
function __parse() {
    wns.sh --tag-seq -- | wns.sh --tag-parsing-bydate "DGT $TODAY 1" |tee $REPORT/$TODAY-parse.DGT 
    wns.sh --tag-seq -- | wns.sh --tag-parsing-bydate "TPG $TODAY 1" |tee $REPORT/$TODAY-parse.TPG
    wns.sh --tag-seq -- | wns.sh --tag-parsing-bydate "TCT $TODAY 1" |tee $REPORT/$TODAY-parse.TCT
    wns.sh --tag-seq -- | wns.sh --tag-parsing-bydate "UDN $TODAY 1" |tee $REPORT/$TODAY-parse.UDN
    wns.sh --tag-seq -- | wns.sh --tag-parsing-bydate "EET $TODAY 1" |tee $REPORT/$TODAY-parse.EET
    wns.sh --tag-seq -- | wns.sh --tag-parsing-bydate "EDG $TODAY 1" |tee $REPORT/$TODAY-parse.EDG
    wns.sh --tag-seq -- | wns.sh --tag-parsing-bydate "MTR $TODAY 1" |tee $REPORT/$TODAY-parse.MTR
    wns.sh --tag-seq -- | wns.sh --tag-parsing-bydate "PCB $TODAY 1" |tee $REPORT/$TODAY-parse.PCB
}
function __tagging() {
    cat $REPORT/$TODAY-parse.DGT \
	$REPORT/$TODAY-parse.TPG \
	$REPORT/$TODAY-parse.TCT \
	$REPORT/$TODAY-parse.UDN \
	$REPORT/$TODAY-parse.EET \
	$REPORT/$TODAY-parse.EDG \
	$REPORT/$TODAY-parse.MTR \
	$REPORT/$TODAY-parse.PCB \
	    | \
	 wns.sh --tag-one-line | tee $REPORT/$TODAY.tag-report 
}
function __rtf() {
    cat $REPORT/$TODAY.tag-report | ./wns.sh --tag-txt2rtf | tee $REPORT/$TODAY.txt2rtf
}
function __tag_folder() {
    cat $REPORT/$TODAY.tag-report | wns.sh --add-folder-tag | tee $REPORT/$TODAY.folder
}
function __move() {
    cat $REPORT/$TODAY.folder | wns.sh --move-folder |tee $LOG/$TODAY-move.log
}
function __copy_report {
    local base='../WNS_RTF/產業新聞'

    local year=`expr substr $TODAY 1 4`
    local month=$(expr `expr substr $TODAY 5 2` + 0 )
    local day=$(expr `expr substr $TODAY 7 2` + 0 )
    local day_d="$month""月""$day""日"

    local target="$base"/"$year""年產業新聞報"/"$year""年"$month"月"/$day_d

    echo copy $REPORT/$TODAY.tag-report to  $target
    echo copy $REPORT/$TODAY.folder to  $target

    cp $REPORT/$TODAY.tag-report $target
    cp $REPORT/$TODAY.folder $target
}

function __tar2nas {
    local base="../WNS_RTF/產業新聞"
    TODAY='20090307'
    local year=`expr substr $TODAY 1 4`
    local month=$(expr `expr substr $TODAY 5 2` + 0 )
    local day=$(expr `expr substr $TODAY 7 2` + 0 )
    local day_d="$month""月""$day""日"
    local today_d="$year""年產業新聞報"/"$year""年"$month"月"/$day_d
    local source="$base"/"$year""年產業新聞報"/"$year""年"$month"月"/$day_d
    local target="//kh-nas/公共分享區/產業分析資料/產業新聞/$today_d"
    src_d="`cygpath -w $source`"
    dst_d=`cygpath -w "$target" `
    echo $source
    echo $src_d
    echo $dst_d
    rm -rf "$dst_d"
    mkdir -p "$target"
    echo cmd /c "xcopy $src_d $dst_d /A /E /H"
    cmd /c "xcopy $src_d $dst_d /A /E /H"
}

#function __tar2bi {

#    local base="../WNS_RTF/產業新聞"
#    #TODAY='20090307'
#    local year=`expr substr $TODAY 1 4`
#    local month=$(expr `expr substr $TODAY 5 2` + 0 )
#    local day=$(expr `expr substr $TODAY 7 2` + 0 )
#    local day_d="$month""月""$day""日"
#    local today_d="$year""年產業新聞報"/"$year""年"$month"月"/$day_d
#    local source="$base"/"$year""年產業新聞報"/"$year""年"$month"月"/$day_d
#    set +e
#    src_d="`cygpath -w $source`"
#    dst_d=`cygpath -w "$NAS_BASE/WNS_RTF-200902/產業新聞/$today_d" `
#    echo $source
#    echo $src_d
#    echo $dst_d
#    rm -rf "$dst_d"
#    mkdir -p "$dst_d"
#    echo cmd /c "xcopy $src_d $dst_d /A /E /H"
#    cmd /c "xcopy $src_d $dst_d /A /E /H"
#    set -e
#}

function __tar2bi {

    #TODAY='20090307'
    local year=`expr substr $TODAY 1 4`
    local month=$(expr `expr substr $TODAY 5 2` + 0 )
    local emonth=$(expr substr $TODAY 5 2 )
    local day=$(expr `expr substr $TODAY 7 2` + 0 )
    local eday="$(expr substr $TODAY 7 2)"
    echo eday: $eday \$1: $1

    if [ "$1". == "ENG". ] ; then
	news_type="Digitimes-英文報"
	root_d="$year"
	month_d="`date "+%Y %B"`"
	day_d="$emonth$eday"
	echo day_d: "$day_d" eday: $eday
    else
	news_type="產業新聞"
	root_d="$year""年產業新聞報"
	month_d="$year""年"$month"月" 
	day_d="$month""月""$day""日"
    fi
    echo day_d: $day_d

    local base="../WNS_RTF/$news_type"
    local today_d="$root_d/$month_d/$day_d"
    local source="$base/$root_d/$month_d/$day_d"
    local WNS_RTF='WNS_RTF-200902'
    #local WNS_RTF='WNS_RTF-test'
    
    set +e
    src_d="$(cygpath -w "$source")"
    dst_d="$(cygpath -w "$NAS_BASE/$WNS_RTF/$news_type/$today_d")"
    echo  "source=$source"; echo  src_d="$src_d"; echo "dst_d=$dst_d"
    echo  "rm directory: $dst_d" 1>&2
    #rm -rf "$dst_d"
    echo  "mkdir directory: $dst_d" 1>&2  
    mkdir -p "$dst_d"
    echo xcopy "$src_d" "$dst_d" /A /E /H /Y /I /C
    xcopy "$src_d" "$dst_d" /A /E /H /Y /I /C
    set -e
}

__naschk_tar2bi() {

    #NAS_HOST="\\\\host-for-not-available-this-host-is-for-debug"
    local fail=0
    local try_times=10
    local sleep_time=6m
    while true; do  
        if [ -e $NAS_HOST ] ; then 
	    __nas_connect
	    if [ $fail -gt 0 ] ; then
		echo `date +%x-%X` Beause NAS_HOST: $NAS_HOST has been not available. 
		echo `date +%x-%X` for available, Program enter sleepping mode, time: $sleep_time
		sleep $sleep_time
	    fi
	    __tar2bi ""
	    __tar2bi "ENG"
	    break 
	else 
	    echo `date +%x-%X` $NAS_HOST is not available.....'('fail times: $fail')'.
	    echo `date +%x-%X` Enter sleep mode, sleep time: $sleep_time 
	    sleep $sleep_time
	    fail=$(expr $fail + 1)

	    if [ $fail -gt $try_times ] ; then
		echo  `date +%x-%X` Fail: $NAS_HOST is not available after check 10 times.
		break
	    fi
	fi
    done
}

function __deploy_data {
    local base='/usr/src/opt/wns/WNS_RTF/產業新聞'
    local dst_base=$NAS_BASE/"WNS_RTF-200902/產業新聞"
    local year=`expr substr $TODAY 1 4`
    local month=$(expr `expr substr $TODAY 5 2` + 0 )
    local day=$(expr `expr substr $TODAY 7 2` + 0 )

    local month_d="$year""年產業新聞報"/"$year""年"$month"月"
    local day_d="$month""月""$day""日"

    local src_d="$base"/"$month_d"/"$day_d"
    local src_tag=$base/$month_d/$TODAY.tag-report
    local src_folder=$base/$month_d/$TODAY.folder

    local dst_d="$dst_base"/$month_d/$day_d
    local dst_tag=$dst_base/$month_d/$TODAY.tag-report
    local dst_folder=$dst_base/$month_d/$TODAY.folder

    #ls -ld --show-control-chars "$src_d" "$src_tag" "$src_folder"
    #ls -ld --show-control-chars "$dst_d" "$dst_tag" "$dst_folder"
    cp -r "$src_d" "$dst_base/$month_d"
    echo cp -r "$src_d" "$dst_base/$month_d"
}

function __nofetch() {
    __today "nofetch"
}

function __today() {
    daily_start=`date "+%x %X"`

    if [ "$1". == "". ] ; then
	echo Fetch XLS table to text table.
        __xls2tab
	echo FETCH WEB DATA .......
        fetch_start=`date "+%x %X"`
	__fetch
        fetch_end=`date "+%x %X"`
	echo "Fetch start:" $fetch_start ",Fetch end:" $fetch_end
    fi
    echo Parse articles to create \"Parse Report: "$TODAY-parse.SITE"\".......
    __parse

    echo Reformat parse tag to create \"Tag Report: "$TODAY.tag-report"\"....
    __tagging

    echo Reproduct RTF file according TAG REPORT
    __rtf

    echo Add folder tag to create \"Folder Tag Report: "$TODAY.folder"\"....
    __tag_folder

    echo Copy article to target folder and create \"Article copy log: "$TODAY-move.log"\"....
    __move

    echo Copy reports to target directory.
    __copy_report

    daily_end=`date "+%x %X"`
    echo `basename $0`: $daily_start - $daily_end , $fetch_start - $fetch_end >> $LOG/`basename $0`.log
}

function __xls2tab() {
# cat types.tab2 | sed -e 's/\[-\\s\]\*/[[:blank:]].*/g' -e 's/\[-\\s\]\/[[:blank:]]/g'

    #path='//kh-nas/社群資料區/新產品開發專案管理/新產品開發專案管理/BI_經企/以程式處理BI資訊'
    path='//kh-nas/Project/新產品開發專案管理/新產品開發專案管理/BI_經企/以程式處理BI資訊'
    table='BI新聞分類機制.xls'
    XLSTBL="$path/$table"
    #XLSTBL="`echo $XLSTBL | piconv -f utf-8 -t big5`"
    echo XLSTAB: $XLSTBL

    TODAY="`date +%Y%m%d`"

    DEFAULT_TAB=../TABLES/DEFAULT.xls
    RULES_TAB=../TABLES/RULES.TAB
    FOLDER_TAB=../TABLES/FOLDER.TAB

    TODAY_TAB=../TABLES/$TODAY.xls
    TYPES_TAB=./types.tab2
    FLDR_TAB=./folder.tab

    echo "Try cp \"RULES TABLE\":" 
    echo "       $XLSTBL"
    echo "    to $TODAY_TAB"

    engtitle='^[[:alnum:]].*[[:blank:]][[:alnum:]].*[[:blank:]][[:alnum:]].*[[:blank:]][[:alnum:]].*[[:graph:]]$'
    if [ -e "$XLSTBL" ] ; then
	cp "$XLSTBL" $TODAY_TAB
        cp $TODAY_TAB $DEFAULT_TAB

	echo "RULES TABLE has been copy to $DEFAULT_TAB."
        echo "Use $DEFAULT_TAB: \"tagging\" sheet to create $RULES_TAB"
	#egrep -v '(^seq|^\(0|^\"seq|title全為英文|^.*OR.*NOT|^Name.*tagging$)' | \
# (cat ../REPORT/*-parse.EDG)|  gawk -F '|' '{print $4}' | egrep  '^[[:alnum:]].*[[:blank:]][[:alnum:]].*[[:blank:]][[:alnum:]].*[[:blank:]][[:alnum:]].*[[:graph:]]$'

english_title='^[[:alnum:]].*[[:blank:]][[:alnum:]].*[[:blank:]][[:alnum:]].*[[:blank:]][[:alnum:]].*[[:graph:]]$'
	perl ./xls2rules.pl $DEFAULT_TAB 2>/dev/null | \
	    egrep -v '(^seq|^\(0|^\"seq|^.*OR.*NOT|^Name.*tagging$)' | \
	    sed -e 's/, /,/g' -e 's/|$//g' -e 's/,,/,/g' -e "s/\[title全為英文\]/$engtitle/g" > $RULES_TAB
        echo "Use $DEFAULT_TAB: \"main\" sheet to create $RULES_TAB"
        perl ./xls2folder.pl $DEFAULT_TAB 2> /dev/null | \
	    egrep -v "(^Name:.*|^sequence|^\(0.*)" | grep -v '^|||||' > $FOLDER_TAB
	echo "Create symbolic link file $RULES_TAB to $TYPES_TAB"
        rm  -f $TYPES_TAB
	ln -s $RULES_TAB $TYPES_TAB

        rm -f $FLDR_TAB
	ln -s $FOLDER_TAB $FLDR_TAB
        ls -l --color $RULES_TAB $TYPES_TAB $FOLDER_TAB $FLDR_TAB
    else
	echo "NOT FOUND KH-NAS RULES TABLE, USE OLD rules !!!!"
    fi
}

__schedule_nofetch() {
    __nofetch 2>../log/$TODAY-today-nof.err.log 1>../log/$TODAY-today-nof.log
    __tar2bi 2>../log/$TODAY-tar2bi-nof.err.log 1>../log/$TODAY-tar2bi-nof.log
}

__schedule_task() {
    echo "`date`" >../log/$TODAY-task.start
    __today 2>../log/$TODAY-today.err.log 1>../log/$TODAY-today.log
    __naschk_tar2bi 2>../log/$TODAY-tar2bi.err.log 1>../log/$TODAY-tar2bi.log
    echo "`date`" >../log/$TODAY-task.stop
}

__schedule_env() {

    TIME="$(date +%H%M%S)" 
    ls -l  $NAS_BASE > ../log/$TODAY-$TIME--schedule-test.log
    net use | piconv -f big5 -t utf-8 >> ../log/$TODAY-$TIME--schedule-env.log
}

__schedule_cmd() {

    echo schedule command:
    echo d:\\wns\\cygwin\\bin\\bash.exe -c \"PATH=./:/usr/bin:'$PATH;$HOME'/wns/script/wns_daily.sh  --nas-connect --schedule-task --nas-disconnect\"
}

__nas_connect() {
    
    echo net use "$NAS_SHARE"  "$NAS_PWD" /USER:"$NAS_USR"
    net use "$NAS_SHARE"  "$NAS_PWD" /USER:"$NAS_USR" | piconv -f big5 -t utf-8

}

__nas_disconnect() {
    echo net use "$NAS_SHARE" /delete
    (net use "$NAS_SHARE" /delete /y; ret=$? )2>&1| piconv -f big5 -t utf-8
    ret=$?
    echo net use /delete'('$ret')'
}

__check() {
    echo $1
    grep "$1" ../FETCH/*/$TODAY.listing
    echo "--------------------------------------------------------------------------------------"
    #grep "$1" ../REPORT/$TODAY-parse.*
    grep "$1" ../REPORT/$TODAY.tag-report
    echo "--------------------------------------------------------------------------------------"
    grep "$1" ../REPORT/$TODAY.folder
}

__show_help() {
	cat <<-_EOF
		${_name} is a fetch web news program.

		Usage: ${_name} [ --disable-abort | --enable-abort ] [ --today | --nofetch | --xls2tab | 
		                  --deploy-data | --tar2bi | --tar2nas | 
				  --schedule-task | --schedule-nofetch | --schedule-env |
				  --nas-connect | --nas-disconnect | --naschk-tar2bi | --help  ]
			        [--fetch] [--parse] [--tagging] [--rtf] [--tag-folder] [--move] [--copy-report]

		        --today: run following step by step:
		                     --fetch, --parse, --tagging, --rtf, --tag-folder, --move, --copy-report
		        --nofetch: same as --today, but no --fetch step.

		        --fetch: fetch web news to target directory.
		        --parse: parse today fetch data
		        --tagging:  normalize tag from parse report
		        --rtf: create rtf and add it tags to the rtf file.
		        --tag-folder: add folder tag to folder report.
		        --move: read from folder report and cp article to folder.
		        --copy-report: copy *.tag-report *.folder to target folder.

		        --schedule-task: run schedule on win32 taskmanager.
		        --schedule-nofetch: same as --schedule-task but nofetch web site news.
			--schedule-cmd: show schedule command.
		        --schedule-env: test schedule environment to ../log/TODAY-TIME-schedlue-test.log
		        --nas-connect, --nas-disconnect: connect/disconnect NAS connect.
		        --naschk-tar2bi: check nas, if it unavailable, sleep, recheck, if available re-connect.
		                       and run --tar2bi.
		        --xls2tab: transfer xls tables to text format from NAS storage.
		        --deploy-data: deploy wns data to NAS storage.
			--check:  check "\$1" exist in ../FETCH/*/*.listing or exist in ../REPORT/\$TODAY.folder
		_EOF
}


#__main
ABORT_OP="disable-abort,enable-abort"
COMMON_OP="today,nofetch,help,xls2tab,deploy-data,tar2bi,tar2nas,check:"
SCHEDULE_OP="schedule-task,schedule-nofetch,schedule-env,schedule-cmd,nas-connect,nas-disconnect,naschk-tar2bi"
GEN_OP="fetch,parse,tagging,rtf,tag-folder,move,copy-report"
ALL_OP="$GEN_OP,$COMMON_OP,$ABORT_OP,$SCHEDULE_OP"
OPT=`getopt -o "" --longoptions=$ALL_OP -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

#echo OPT: $OPT
eval set -- "$OPT"
if [  $# -eq 1 ] ; then __show_help; fi
set -e
while true ; do
    case "$1" in
        --enable-abort)		__abort=true;       shift ;;
        --disable-abort)	__abort=false;       shift ;;
        --today)	__today;       break ;;
	--nofetch)      __nofetch;     break ;;
        --fetch)	__fetch;       shift ;;
	--parse)	__parse;       shift ;;
	--tagging)	__tagging;     shift ;;
	--rtf)		__rtf;	       shift ;; 
	--tag-folder)	__tag_folder;  shift ;; 
	--move)		__move;	       shift ;;
	--xls2tab)	__xls2tab;     shift ;;
	--help)		__show_help;   break ;;
	--copy-report)	__copy_report; shift ;;
	--deploy-data)	__deploy_data; break ;;
	--tar2bi)	__tar2bi; break ;;
	--tar2nas)	__tar2nas; break ;;
	--schedule-task)	__schedule_task; shift ;;
	--schedule-nofetch)	__schedule_nofetch; shift ;;
	--schedule-env)	__schedule_env; shift ;;
	--schedule-cmd)	__schedule_cmd; shift ;;
	--nas-connect)  __nas_connect; shift;;
	--nas-disconnect) __nas_disconnect; shift;;
	--naschk-tar2bi)	__naschk_tar2bi; break ;;
	--check)	__check $2; shift; shift;;
        --)		break ;;
	*)		__show_help;   break ;;
    esac
done 

