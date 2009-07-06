#!/bin/bash

#FIELDS="Description/text Abbrevation/text StockID/text Enter_four/text ERP_StockId/text"

TEMPLATE=Whrs
TABLE=Whrs
PKEY=WhrsId
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

if [ "$_link". == "". ] ; then
    INCLUDE=./
else
    INCLUDE="`dirname $_link`"
fi
PATTERN=./pattern

_template() {
cat "$PATTERN"/Template.asp | \
    sed -e "s/##Template_#/$(echo $TEMPLATE)/g" \
	-e "s/##PKEY_#/$(echo $PKEY)/g" \
	-e "s/##Location_#/$(echo $LOCATION)/g" \
        > $_output/"$TEMPLATE".asp
}
_template_modify() {
cat "$PATTERN"/Template_Modify.asp | \
    sed -e "s/##PKEY_#/$(echo $PKEY)/g" \
	-e "s/##Template_#/$(echo $TEMPLATE)/g" \
	-e "s/##Location_#/$(echo $LOCATION)/g" \
	>  $_output/"$TEMPLATE"_Modify.asp
}
_template_modify_layout() {
source "$INCLUDE"/Template_Modify_Layout.sh
template_modify_layout >  $_output/"$TEMPLATE"_Modify_Layout.asp
}
_template_new() {
cat "$PATTERN"/Template_New.asp | \
    sed -e "s/##Template_#/$(echo $TEMPLATE)/g" \
	-e "s/##PKEY_#/$(echo $PKEY)/g" \
	-e "s/##Location_#/$(echo $LOCATION)/g" \
        >  $_output/"$TEMPLATE"_New.asp
}
_template_new_layout() {
source "$INCLUDE"/Template_New_Layout.sh
template_new_layout >  $_output/"$TEMPLATE"_New_Layout.asp
}
_template_printdata() {
cp "$PATTERN"/Template_PrintData.asp  $_output/"$TEMPLATE"_PrintData.asp
}
_template_report() {
cp "$PATTERN"/Template_Report.asp  $_output/"$TEMPLATE"_Report.asp
}
_template_script_savemodify() {
source "$INCLUDE"/Template_Script_SaveModify.sh
template_script_savemodify >  $_output/Script_SaveModify.asp
}
_template_toolbar_list() {
cp  "$PATTERN"/Template_Toolbar_List.asp  $_output/Toolbar_List.asp
}
_template_toolbar_modify() {
cp  "$PATTERN"/Template_Toolbar_Modify.asp  $_output/Toolbar_Modify.asp
}
_template_toolbar_new() {
cp  "$PATTERN"/Template_Toolbar_New.asp  $_output/Toolbar_New.asp
}
_template_script_savenew() {
source "$INCLUDE"/Template_Script_SaveNew.sh
template_script_savenew >  $_output/Script_SaveNew.asp
}
_ws_template_data() {
cat "$PATTERN"/ws_Template_Data.asp | \
    sed -e "s/##PKEY_#/$(echo $PKEY)/g" \
	-e "s/##Template_#/$(echo $TEMPLATE)/g" \
	>  $_output/ws_"$TEMPLATE"_Data.asp
}
_ws_template_delete() {
cat "$PATTERN"/ws_Template_Delete.asp | \
    sed -e "s/##PKEY_#/$(echo $PKEY)/g" \
	-e "s/##Template_#/$(echo $TEMPLATE)/g" \
	>  $_output/ws_"$TEMPLATE"_Delete.asp
}
_ws_template_modifydata() {
cat "$PATTERN"/ws_Template_ModifyData.asp | \
    sed -e "s/##PKEY_#/$(echo $PKEY)/g" \
	-e "s/##Template_#/$(echo $TEMPLATE)/g" \
	>  $_output/ws_"$TEMPLATE"_ModifyData.asp
}
_ws_template_savemodify() {
source "$INCLUDE"/ws_Template_SaveModify.sh
ws_template_savemodify | \
    sed -e "s/##PKEY_#/$(echo $PKEY)/g" \
	-e "s/##Template_#/$(echo $TEMPLATE)/g" \
	>  $_output/ws_"$TEMPLATE"_SaveModify.asp
}
_ws_template_savenew() {
source "$INCLUDE"/ws_Template_SaveNew.sh
ws_template_savenew | \
    sed -e "s/##PKEY_#/$(echo $PKEY)/g" \
	-e "s/##Template_#/$(echo $TEMPLATE)/g" \
	>  $_output/ws_"$TEMPLATE"_SaveNew.asp
}
_template_ws_getreportdata() {
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
_template_toolbar_list
_template_toolbar_modify
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

if [ ! -d $__TEMPLATE_DEST_PATH ] ; then
	echo Create template scripts path: $__TEMPLATE_DEST_PATH.
	mkdir -p $__TEMPLATE_DEST_PATH
fi

echo cp $_output/*.asp $__TEMPLATE_DEST_PATH
cp $_output/*.asp $__TEMPLATE_DEST_PATH

}

_exec_sql() {
echo Execute "$_output/$TEMPLATE.sql" to server: $GD_DB_HOST, database: $GD_DATABASE
echo to create "$TEMPLATE" table, "fn_DATA_$TEMPLATE" function
echo add data to "Program" and "ProgramField" tables.
echo todo..., this action not implement.

}

__show_help() {
#        ex: --fields "Description/text Abbrevation/text StockID/text Enter_four/text ERP_StockId/text"
cat <<-EOF
${_name} is a template pattern generater program.

Usage: ${_name} [--cfg <file>|[--table <tablename>][--pkey <keyname>][--fields <fieldstring>]]
    [--pattern <path>][--output <path>][--all | ["TEMPLATE-ACTIONS"...]]
 
    --cfg <filename>: specify cfg filename.
    --table <name>: specify table name			--pkey <key>: specify pkey name.
    --fields <string>: specify fieldstring, blank char is fields separator.
    --pattern <path>: specify template patterns path.	--output <path>: templates output directory.
    --all : create all template files.			--deploy-script: deploy template script to prduct path.

TEMPLATE-ACTIONS:
    --template: create Table script.
    --template-modify: create Table_Modify script.
    --template-modify-layout: create Table_Modify_Layout script.
    --template-new: create Table_New script.
    --template-new-layout: create Talbe_New_Layout script.
    --template-printdata: create Talbe-PrintData script.
    --template-report: create Table_Report script.
    --template-toolbar-list: create ToolBar_List script.
    --template-toolbar-modify: create Toolbar_Modify script.
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
EOF
}

#__main
TABLE_OP="table:,pkey:,fields"
COMMON_OP="help,output:,cfg:,all,pattern:,deploy-script,exec-sql"
GEN_OP="template,template-modify,template-modify-layout,template-new,template-new-layout,\
template-printdata,template-report,template-script-savemodify,template-toolbar-list,\
template-toolbar-modify,template-toolbar-new,template-script-savenew,template-ws-getreportdata,\
template-sql,ws-template-modifydata"

#echo $GEN_OP
ALL_OP="$GEN_OP,$COMMON_OP,$ABORT_OP"
OPT=`getopt -o "" --longoptions=$ALL_OP -- "$@"`

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
			if [ ! "$OUTPUT". == "". ] ; then
			    _output=$OUTPUT
			fi 
		    else
			echo cfg file not exist.
		    fi
		    shift ;;
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
	--template-toolbar-list)  _template_toolbar_list; shift;;
	--template-toolbar-modify)  _template_toolbar_modify; shift;;
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

