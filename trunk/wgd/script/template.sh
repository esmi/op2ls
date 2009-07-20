#!/bin/bash

source cfg/SQL.cfg
#SQLSRV=
#SQLUSR=
#SQLPWD=
#SQLDB=

#FIELDS="Description/text Abbrevation/text StockID/text Enter_four/text ERP_StockId/text"

#PRG_TYPE=MAIN/DBL_RELATE/DBL_ATTACH/DBL_IMPORT
FILE_TYPE=RELATED
PRG_TYPE=MAIN
PRG_TYPE=DBL

IS_ATTACH=FALSE
IS_IMPORT=TRUE
IS_OPENWIN_CODE=TRUE

KEY_TYPE=MULTY_KEY
KEY_MULTY="DeptId,PeriodId,WhrsId"
TEMPLATE=Whrs
#TABLE=Whrs
PKEY=WhrsId
RELATED_TABLE=MsgCustoms
LOCATION=Whrs

PFIELD="$PKEY/text/nvarchar/5/Not/whrsId/信息量倉編碼/信息量倉編碼"
FIELDS="Description/text/nvarchar/20//dscription/說明/說明 \
Abbrevation/text/nvarchar/10//Abbrevation/簡稱/簡稱 \
StockID/text/nvarchar/10//StockID/StockID/StockID \
Enter_four/text/nvarchar/4//four_code/HS前四碼/HS前四碼 \
ERP_StockId/text/nvarchar/10//ERPStockID/ERP倉庫代碼/ERP倉庫代碼"

GD_ModuleID=HSS
GD_DATABASE=GDCRM
GD_PRD_PATH=../src
GD_DB_HOST=10.7.1.10
DOCROOT=/GDCRM

__abort=false
_output=./output
_name=`basename $0`
_path=`dirname $0`
_link=`readlink $0`
_schema_path=./schema

if [ "$_link". == "". ] ; then
    INCLUDE=./
else
    INCLUDE="`dirname $_link`"
fi
PATTERN=./pattern


key_count() {
    local count=0
    #for key_fd in `echo $MULTY_KEY | sed 's/,/ /g'` ; do
    #echo $KEY_MULTY
    for key_fd in `echo $KEY_MULTY | sed 's/,/ /g'` ; do
        count="`expr $count + 1`"
    done
    echo $count
}
key_name() {
    echo $1 | gawk -F , "{ print \$$2}"
}

_template() {
    #cat "$PATTERN"/Template.asp | \
    echo create  $_output/"$TEMPLATE".asp
    source "$INCLUDE"/Template_Entry.sh
    template_entry |
	sed -e "s/##Template_#/$(echo $TEMPLATE)/g" \
	    -e "s/##PKEY_#/$(echo $PKEY)/g" \
	    -e "s/##Location_#/$(echo $LOCATION)/g" \
            > $_output/"$TEMPLATE".asp
}
_template_modify() {
    #cat "$PATTERN"/Template_Modify.asp | \
    #    sed -e "s/##PKEY_#/$(echo $PKEY)/g" \
    #	-e "s/##Template_#/$(echo $TEMPLATE)/g" \
    #	-e "s/##Location_#/$(echo $LOCATION)/g" \
    #	>  $_output/"$TEMPLATE"_Modify.asp
    echo create  $_output/"$TEMPLATE"_Modify.asp
    source "$INCLUDE"/Template_Modify.sh
    template_modify | 
	sed -e "s/##PKEY_#/$(echo $PKEY)/g" \
	    -e "s/##Template_#/$(echo $TEMPLATE)/g" \
	    -e "s/##Location_#/$(echo $LOCATION)/g" \
	> $_output/"$TEMPLATE"_Modify.asp
}

_template_modify_layout() {
    echo create  $_output/"$TEMPLATE"_Modify_Layout.asp
    source "$INCLUDE"/Template_Modify_Layout.sh
    template_modify_layout >  $_output/"$TEMPLATE"_Modify_Layout.asp
}
_template_new() {
echo create  $_output/"$TEMPLATE"_New.asp
cat "$PATTERN"/Template_New.asp | \
    sed -e "s/##Template_#/$(echo $TEMPLATE)/g" \
	-e "s/##PKEY_#/$(echo $PKEY)/g" \
	-e "s/##Location_#/$(echo $LOCATION)/g" \
        >  $_output/"$TEMPLATE"_New.asp
}
_template_new_layout() {
    echo create  $_output/"$TEMPLATE"_New_Layout.asp
    source "$INCLUDE"/Template_New_Layout.sh
    template_new_layout >  $_output/"$TEMPLATE"_New_Layout.asp
}
_template_printdata() {
echo create $_output/"$TEMPLATE"_PrintData.asp
cp "$PATTERN"/Template_PrintData.asp  $_output/"$TEMPLATE"_PrintData.asp
}
_template_report() {
echo create $_output/"$TEMPLATE"_Report.asp
cp "$PATTERN"/Template_Report.asp  $_output/"$TEMPLATE"_Report.asp
}
_template_script_savemodify() {
echo create $_output/Script_SaveModify.asp
source "$INCLUDE"/Template_Script_SaveModify.sh
template_script_savemodify >  $_output/Script_SaveModify.asp
}
_toolbar_list() {
    #cp  "$PATTERN"/Template_Toolbar_List.asp  $_output/Toolbar_List.asp
    _TBLIST_ADDNEW_STYLE=""
    if [ "$FILE_TYPE". = "RELATED". ] ; then
	_TBLIST_ADDNEW_STYLE="style='display:none'"
    fi
    _TBLIST_SEARCHATTACH_STYLE="style='display:none'"
    if [ "$IS_ATTACH". = "TRUE". ] ; then
	_TBLIST_SEARCHATTACH_STYLE=""
    fi
    #echo '$_TBLIST_SEARCHATTACH_STYLE: '$_TBLIST_SEARCHATTACH_STYLE
    echo create $_output/Toolbar_List.asp
    source "$INCLUDE"/Toolbar_List.sh
    toolbar_list > $_output/Toolbar_List.asp
}
_toolbar_modify() {
#cp  "$PATTERN"/Template_Toolbar_Modify.asp  $_output/Toolbar_Modify.asp
echo create $_output/Toolbar_Modify.asp
source "$INCLUDE"/Toolbar_Modify.sh
toolbar_modify > $_output/Toolbar_Modify.asp
}
_template_toolbar_new() {
echo create $_output/Toolbar_New.asp
cp  "$PATTERN"/Template_Toolbar_New.asp  $_output/Toolbar_New.asp
}
_template_script_savenew() {
echo create  $_output/Script_SaveNew.asp
source "$INCLUDE"/Template_Script_SaveNew.sh
template_script_savenew >  $_output/Script_SaveNew.asp
}
_ws_template_data() {
echo create  $_output/ws_"$TEMPLATE"_Data.asp
cat "$PATTERN"/ws_Template_Data.asp | \
    sed -e "s/##PKEY_#/$(echo $PKEY)/g" \
	-e "s/##Template_#/$(echo $TEMPLATE)/g" \
	>  $_output/ws_"$TEMPLATE"_Data.asp
}
_ws_template_delete() {
echo create $_output/ws_"$TEMPLATE"_Delete.asp
cat "$PATTERN"/ws_Template_Delete.asp | \
    sed -e "s/##PKEY_#/$(echo $PKEY)/g" \
	-e "s/##Template_#/$(echo $TEMPLATE)/g" \
	>  $_output/ws_"$TEMPLATE"_Delete.asp
}
_ws_template_modifydata() {
echo create $_output/ws_"$TEMPLATE"_ModifyData.asp
#cat "$PATTERN"/ws_Template_ModifyData.asp | \
#    sed -e "s/##PKEY_#/$(echo $PKEY)/g" \
#	-e "s/##Template_#/$(echo $TEMPLATE)/g" \
#	>  $_output/ws_"$TEMPLATE"_ModifyData.asp
source "$INCLUDE"/ws_Template_ModifyData.sh
ws_template_modifydata | \
    sed -e "s/##PKEY_#/$(echo $PKEY)/g" \
	-e "s/##Template_#/$(echo $TEMPLATE)/g" \
        >  $_output/ws_"$TEMPLATE"_ModifyData.asp
}
_ws_template_savemodify() {
echo create $_output/ws_"$TEMPLATE"_SaveModify.asp
source "$INCLUDE"/ws_Template_SaveModify.sh
ws_template_savemodify | \
    sed -e "s/##PKEY_#/$(echo $PKEY)/g" \
	-e "s/##Template_#/$(echo $TEMPLATE)/g" \
	>  $_output/ws_"$TEMPLATE"_SaveModify.asp
}
_ws_template_savenew() {
echo create  $_output/ws_"$TEMPLATE"_SaveNew.asp
source "$INCLUDE"/ws_Template_SaveNew.sh
ws_template_savenew | \
    sed -e "s/##PKEY_#/$(echo $PKEY)/g" \
	-e "s/##Template_#/$(echo $TEMPLATE)/g" \
	>  $_output/ws_"$TEMPLATE"_SaveNew.asp
}
_template_ws_getreportdata() {
echo create $_output/ws_GetReportData.asp
cp  "$PATTERN"/Template_ws_GetReportData.asp  $_output/ws_GetReportData.asp
}
_template_sql() {
source "$INCLUDE"/Template_SQL.sh
local script=$_output/"$TEMPLATE".sql
echo create sql script: $script
template_sql > $script
}
_template_all() {

_template
_template_modify
_template_modify_layout
_template_new
_template_new_layout
_template_printdata
_template_report
_template_script_savemodify
_toolbar_list
_toolbar_modify
_template_toolbar_new
_template_script_savenew
_ws_template_data
_ws_template_delete
_ws_template_modifydata
_ws_template_savemodify
_ws_template_savenew
_template_ws_getreportdata
_template_sql
}
_deploy_script() {
local __TEMPLATE_DEST_PATH=$GD_PRD_PATH/"$TEMPLATE"
retval=0

if [ ! -d $__TEMPLATE_DEST_PATH ] ; then
    echo Create template scripts path: $__TEMPLATE_DEST_PATH.
    mkdir -p $__TEMPLATE_DEST_PATH
    retval=$?
fi
if [ -d $__TEMPLATE_DEST_PATH ] ; then
    echo cp $_output/*.asp $__TEMPLATE_DEST_PATH
    cp $_output/*.asp $__TEMPLATE_DEST_PATH
else
    echo "Target path: $__TEMPLATE_DEST_PATH is not found"
    echo "Scripts copy failure...."
fi

}
_create_cfg() {

XLS_schema=$1
WKS=$2
echo '#' $WKS, $XLS_schema

if [ -e $XLS_schema ] ; then

    SEARCH_STR="\*CFG"
    $INCLUDE/xls2folder.pl $XLS_schema $WKS |\
	sed -n "/$SEARCH_STR/p" | gawk -F '|' '{print $1"="$2}' | \
	sed  -e "s/TEMPLATE=$/TEMPLATE=$WKS/g" \
	     -e "s/LOCATION=$/LOCATION=$WKS/g" \
	     -e "s/OUTPUT=$/OUTPUT=$WKS/g" 
    echo ""
    the_pkey=`$INCLUDE/xls2folder.pl $XLS_schema $WKS |\
	sed -n "/$SEARCH_STR/p" | gawk -F '|' '{print $1"="$2}' | \
	sed  -e "s/TEMPLATE=$/TEMPLATE=$WKS/g" \
	     -e "s/LOCATION=$/LOCATION=$WKS/g" \
	     -e "s/OUTPUT=$/OUTPUT=$WKS/g" | grep -i PKEY | sed 's/^.*=//g'`

    #echo $the_pkey

    #echo $FIELDS
    #gawk -F '|' '{print $1"/"$4"/"$2"/"$3"/"$6"NULL/"$15"/"$16"/"$17 " \\"}' |\
    SEARCH_STR="\*FD"
    echo -n "FIELDS=\"" ;  $INCLUDE/xls2folder.pl $XLS_schema $WKS |\
	sed  -n "/$SEARCH_STR/p" | \
	gawk -F '|' '{print \
	    $1"/"$4"/"$2"/"$3"/"$6"NULL/"$15"/"$16"/"$17"/"$9"/"$10"/"$11"/"$12"/"$13"/"$14"/"$5"/"$7"/"$8"/"$18 " \\"}' |\
	sed -e 's/NNULL/NOT/g' -e 's/YNULL//g' ; echo "\""
    echo ""
    PFIELD_STR=$($INCLUDE/xls2folder.pl $XLS_schema $WKS |\
	sed  -n "/$SEARCH_STR/p" | \
	gawk -F '|' '{print \
	    $1"/"$4"/"$2"/"$3"/"$6"NULL/"$15"/"$16"/"$17"/"$9"/"$10"/"$11"/"$12"/"$13"/"$14"/"$5"/"$7"/"$8"/"$18 " \\"}' |\
	sed -e 's/NNULL/NOT/g' -e 's/YNULL//g' | grep -i "$the_pkey" | sed -e 's/\\//g' )
    #-e 's/$/\"/g')
    if [ "$PFIELD_STR". = "". ] ; then
	echo -n PFIELD=\"\"
    else
	echo -n PFIELD=\"$PFIELD_STR\"
    fi
    echo ""

    echo "#1欄位名稱/2欄位型態/3資料型態/4長度/5isNull/6ENGName/7繁體名稱/8简体名称/9新增時顯示/10新增時唯讀/"
    echo "#11修改時顯示/12修改時唯讀/13預設值/14資源名稱/15KEY/16開窗/17開窗資料來源/18欄位說明"

#Script Title:
#1       /2       /3       /4   /5     /6      /7       /8       /9         /10        
#欄位名稱/欄位型態/資料型態/長度/isNull/ENGName/繁體名稱/简体名称/新增時顯示/新增時唯讀
#/11        /12        /13    /14      /15 /16  /17          /18
#/修改時顯示/修改時唯讀/預設值/資源名稱/KEY/開窗/開窗資料來源/欄位說明"

#順序對應
#Script:             1 | 2 | 3 | 4 | 5 |  6 |  7 |  8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18
#Excel轉Script順序:  1 | 4 | 2 | 3 | 6 | 15 | 16 | 17 | 9 | 10 | 11 | 12 | 13 | 14 |  5 |  7 |  8 | 18  

#Excel Title:
#欄位名稱|資料型態|長度|欄位型態|KEY|Null|開窗|開窗資料來源|新增時顯示|新增時唯讀|修改時顯示|修改時唯讀|預設值|資源名稱|ENGName|繁體名稱|简体名称|欄位說明
#1       |2       |3   |4       |5  |6   |7   |8           |9         |10        |11        |12	       |13    |14      |15     |16      |17      |18

else
   echo input file: $XLS_schema not exist..
fi
}
_exec_sql() {

echo Execute "$_output/$TEMPLATE.sql" to server: $SQLSRV, database: $SQLDB
echo to create "$TEMPLATE" table, "fn_DATA_$TEMPLATE" function
echo add data to "Program" and "ProgramField" tables.
echo ""
osql -S $SQLSRV  -U $SQLUSR -P $SQLPWD -d $SQLDB -i "$_output/$TEMPLATE.sql" | piconv -f big5 -t $LANG

}

__show_help() {
cat <<-EOF
${_name} is a template pattern generater program.

Usage: ${_name} [--cfg <file>|[--table <tablename>][--pkey <keyname>][--fields <fieldstring>]]
    [--pattern <path>][--output <path>][--all | ["TEMPLATE-ACTIONS"...]]
 
    --cfg <filename>: specify cfg filename.	  
    --table <name>: specify table name			--pkey <key>: specify pkey name.
    --fields <string>: specify fieldstring, blank char is fields separator.
    --pattern <path>: specify template patterns path.	--output <path>: templates output directory.
    --all : create all template files.			--deploy-script: deploy template script to prduct path.
Create-CFG-ACTIONS:
    --schema-path <path> --schema-file <xlsfile> --wks-name <wks-name>  --create-cfg
TEMPLATE-ACTIONS:
    --template: create Table script.
    --template-modify: create Table_Modify script.
    --template-modify-layout: create Table_Modify_Layout script.
    --template-new: create Table_New script.
    --template-new-layout: create Talbe_New_Layout script.
    --template-printdata: create Talbe-PrintData script.
    --template-report: create Table_Report script.
    --toolbar-list: create ToolBar_List script.
    --toolbar-modify: create Toolbar_Modify script.
    --template-toolbar-new: create Toolbar_New script.
    --template-script-savemodify: create Script_SaveModify script.
    --template-script-savenew: create Script_SaveNew script.
    --ws-template-data: create ws_Table_Data script.
    --ws-template-delete: create ws_Table_Delete script.
    --ws-template-modifydata: create ws_Table_ModifyData script.
    --ws-template-savemodify: create ws_Table_SaveModify script.
    --ws-template-savenew: create ws_Table_SaveNew script.
    --template-ws-getreportdata: create ws_GetReportData script.
    --template-sql: create template sql script.
example:
    template --schema-file STKImport.prj.xls --wks-name STKItems --create-cfg > cfg/STKItems.cfg
    template --cfg cfg/STKItems.cfg --all           ## create asp and sql script to \$OUTPUT path.
    template --cfg cfg/STKItems.cfg --run-sql       ## not implement, run --template-sql output to target DB.
    template --cfg cfg/STKITems.cfg --deploy-script	## deploy scripts to target path.
EOF
}

#__main
TABLE_OP="table:,pkey:,fields"
COMMON_OP="help,output:,cfg:,all,pattern:,deploy-script,exec-sql"
CREATE_CFG="create-cfg,wks-name:,schema-path:,schema-file:"
GEN_OP="template,template-modify,template-modify-layout,template-new,template-new-layout,\
template-printdata,template-report,template-script-savemodify,toolbar-list,\
toolbar-modify,template-toolbar-new,template-script-savenew,template-ws-getreportdata,\
template-sql,ws-template-modifydata"

#echo $GEN_OP
ALL_OP="$GEN_OP,$COMMON_OP,$ABORT_OP,$CREATE_CFG"
orig_command="$@"
OPT=`getopt -o "" --longoptions=$ALL_OP -- "$@"`
#orig_command="$*"

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi


_output=./output

#echo OPT: $OPT
eval set -- "$OPT"
if [  $# -eq 1 ] ; then __show_help; fi

set -e
while true ; do
    case "$1" in
	--table)    shift; TEMPLATE=$1; TABLE=$1; LOCATION=$1; shift;;
	--pkey)	    shift; PKEY=$1; shift;;
	--fields)   shift; FIELDS=$1; shift ;;
	--output)   shift ; _output=$1 ;
		    if [ ! -d  $1 ] ; then
			echo output directory is not exist. create $1 directory.
			mkdir -p $1
		    fi
		    shift;;
	--cfg)	    shift; 
		    if [ -e $1 ] ; then
			source $1
			#echo FILE_TYPE: $FILE_TYPE
			if [ ! "$OUTPUT". == "". ] ; then
			    _output=$OUTPUT
			    mkdir -p $_output
			fi 
		    else
			echo cfg file not exist.
		    fi
		    shift ;;
	--wks-name) shift;
		    #echo ttt:$1
		    if [ ! "$1". = "". ] ;then
			_WKS_NAME="$1"
		    else
			_WKS_NAME="XXX"
		    fi
		    shift ;;
	--schema-path) shift;
		    if [ ! "$1". = "". ] ;then
			if [ -d "$1" ] ; then
			    _schema_path="$1"
			else
			    echo "\`input --schema-path: $1 is not a directory path!'"
			    break
			fi
		    fi
		    shift ;;
	--schema-file) shift;
		    if [ ! "$1". = "". ] ;then
			if [ -e "$_schema_path"/"$1" ] ; then
			    _schema_file="$1"
			else
			    echo "\`input --schema-file: "$_schema_path"/$1 is not exist!'"
			    break
			fi
		    fi
		    shift ;;
	--create-cfg) shift
		    echo '#' "$orig_command"
		    if [ -e "$_schema_path/$_schema_file" ]; then
			if [ ! "$_WKS_NAME". = "". ] ; then
			    _create_cfg "$_schema_path/$_schema_file" $_WKS_NAME ; 
			    shift;
			    break;
			else
			    echo --wks-name ?
			fi
		    else
			echo Must specific a input-file.xls, --schema-path: $_schema_path, --schema-file: $_schema_file.
		    fi
		    ;;
	--pattern)  shift;
		    if [ -d $1 ] ; then
			PATTERN="$1"
		    else
			echo PATTERN PATH: $1 not found. use default pattern path: '"'$PATTERN'"'
		    fi
		    shift ;;
	--deploy-script) _deploy_script; shift;;
	--exec-sql) _exec_sql; shift;;
	--all)  _template_all ; shift ;;
	--template)  _template; shift;;
	--template-modify)  _template_modify; shift;;
	--template-modify-layout)  _template_modify_layout; shift;;
	--template-new)  _template_new; shift;;
	--template-new-layout)  _template_new_layout; shift;;
	--template-printdata)  _template_printdata; shift;;
	--template-report)  _template_report; shift;;
	--toolbar-list)  _toolbar_list; shift;;
	--toolbar-modify)  _toolbar_modify; shift;;
	--template-toolbar-new)  _template_toolbar_new; shift;;
	--template-script-savemodify)  _template_script_savemodify; shift;;
	--template-script-savenew)  _template_script_savenew; shift;;
	--ws-template-data)  _ws_template_data; shift;;
	--ws-template-delete)  _ws_template_delete; shift;;
	--ws-template-modifydata)  _ws_template_modifydata; shift;;
	--ws-template-savemodify)  _ws_template_savemodify; shift;;
	--ws-template-savenew)  _ws_template_savenew; shift;;
	--template-ws-getreportdata)  _template_ws_getreportdata; shift;;
	--template-sql)  _template_sql; shift;;
        --)             break ;;
        *)              __show_help;   break ;;
    esac
done


