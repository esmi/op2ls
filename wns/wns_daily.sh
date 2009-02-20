#!/bin/bash

source ./wns_cfg/wns.cfg

TODAY="`date +%Y%m%d`"
REPORT=../REPORT
LOG=../LOG

if [ ! -d $DGT_NEWS_LOC ] ; then mkdir $DGT_NEWS_LOC ; fi
if [ ! -d $TPG_NEWS_LOC ] ; then mkdir $TPG_NEWS_LOC ; fi
if [ ! -d $LOG ] ; then mkdir $LOG ; fi
if [ ! -d $REPORT ] ; then mkdir $REPORT ; fi

NAS_BASE='\\kh-nas\社群資料區\新產品開發專案管理\新產品開發專案管理\BI_經企\以程式處理BI資訊'

function fetch_news() {
    local i=1
    local sleep_t=10s
    local times=2
    local abort=false
    echo DGT procedure starting.....

    while true ; do

	if [ $i -gt $times ] ; then 
	    echo DGT login $i times fail, program will abort ;
	    abort=true  
	    break;
	else
	    wns.sh --debug 300 --DGT 
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
	set -e
	echo abort: $abort , will abort, please try again manual.
	#return 100
	#exec fales
	exit 1
    fi
    echo TPG procedure starting.....
    wns.sh --debug 300 --TPG
    wns.sh --debug 300 --TCT
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
}
function __tagging() {
    cat $REPORT/$TODAY-parse.DGT $REPORT/$TODAY-parse.TPG $REPORT/$TODAY-parse.TCT | \
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
    local base='/usr/src/opt/wns/WNS_RTF/產業新聞'

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

    echo Fetch XLS table to text table.
    __xls2tab

    if [ "$1". == "". ] ; then
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

    path='\\kh-nas\社群資料區\新產品開發專案管理\新產品開發專案管理\BI_經企\以程式處理BI資訊'
    table='BI新聞分類機制.xls'
    XLSTBL="$path/$table"

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

    if [ -e $XLSTBL ] ; then
	cp "$XLSTBL" $TODAY_TAB
        cp $TODAY_TAB $DEFAULT_TAB

	echo "RULES TABLE has been copy to $DEFAULT_TAB."
        echo "Use $DEFAULT_TAB: \"tagging\" sheet to create $RULES_TAB"
	perl ./xls2rules.pl $DEFAULT_TAB 2>/dev/null | \
	    egrep -v '(^seq|^\(0|^\"seq|title全為英文|^.*OR.*NOT|^Name.*tagging$)' | \
	    sed -e 's/, /,/g' -e 's/|$//g' -e 's/,,/,/g' > $RULES_TAB
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

_name=`basename $0`

__show_help() {
	cat <<-_EOF
		${_name} is a fetch web news program.

		Usage: ${_name} --today | --nofetch | --xls2tab | --deploy-data | --help | 
		          [--fetch] [--parse] --tagging --rtf --tag-folder --move --copy-report

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

			--xls2tab: transfer xls tables to text format
		        --deploy-data: deploy wns data to NAS storage.
		_EOF
}


#__man

COMMON_OP="today,nofetch,help,xls2tab,deploy-data"
GEN_OP="fetch,parse,tagging,rtf,tag-folder,move,copy-report"
ALL_OP="$GEN_OP,$COMMON_OP"
OPT=`getopt -o "" --longoptions=$ALL_OP -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

#echo OPT: $OPT
eval set -- "$OPT"
if [  $# -eq 1 ] ; then __show_help; fi
#echo $#, $1, $2, $3, $4
set -e
while true ; do
    case "$1" in
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
        --)		shift ;	       break ;;
	*)		__show_help;   break ;;
    esac
done 

