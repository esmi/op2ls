#!/bin/bash

#define target sql parameters for "execsql"
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


__related_table() {
    echo ${RELATED_TABLE}| sed 's|/.*$||g'
}

__wksheet() {
    echo ${WKSHEET} | sed 's|/.*$||g'
}

__is_first_title() {
    echo $IS_FIRST_TITLE | sed 's|/.*$||g'
}
__attach_fields() {
    echo ${ATTACH_FIELDS} | sed 's|/.*$||g'
}

__select_fields() {

    local fdn=""
    local lastfd=$(echo $(__attach_fields) | sed 's/^.*,//g')
    local tailer=", "
    #strSQL = "Select ${KEY_MULTY}, $(__attach_fields) from [$(__wksheet)$]"
    for fd in $(echo $(__attach_fields) | sed 's/,/ /g') ; do
	if [ $fd = $lastfd ] ; then tailer="" ; fi
	if [ $fd = $(echo ${KEY_MULTY} | sed "s/^.*$fd.*$/$fd/g") ] ; then
	    if [ "$ATTACH_CHKKEY". != "". ] ; then

		if [ $fd = $(echo $ATTACH_CHKKEY | sed "s/^.*$fd.*$/$fd/g") ] ; then
		    echo -n $fd$tailer
		else
		    echo -n ""
		fi
	    else
		echo -n $fd$tailer
	    fi
	else
	    echo -n $fd$tailer
	fi
    done
}

key_count() {
    local count=0
    for key_fd in `echo $KEY_MULTY | sed 's/,/ /g'` ; do
        count="`expr $count + 1`"
    done
    echo $count
}
key_name() {
    echo $1 | gawk -F , "{ print \$$2}"
}

modifydata_where_filter() {
#    rst1.Filter = "DeptId = '" & strKeyValue1 & "' AND PeriodId = '" & strKeyValue2 & "'"
#    rst1.Filter = "DeptId = '"   & strKeyValue1 & "'" & " AND " & _
#		  "PeriodId = '" & strKeyValue2 & "'"
echo 1>&2 "KEY_TYPE: " $KEY_TYPE
if [  "$KEY_TYPE". = "MULTY_KEY". ] ; then
    for i in `seq $KEYMULTY_CNT` ; do
	if [ "$i". == "$KEYMULTY_CNT". ] ; then
	    tailer=''
	else
	    tailer=' & " AND " & '
	fi
	echo  -n ' "'`echo $KEY_MULTY | gawk -F ',' "{print $(echo '$'$(echo $i))}"`" = N'\""" & strKeyValue"$i" & \"'\""  \
		$tailer
    done
else
    #' strKeyFieldName & " = N'" & strKey & "'"  
    echo -n strKeyFieldName '&' \" = N\'\" \& strKey \& \"\'\"


fi    
}
strKeyValue_assign() {
    for i in `seq $KEYMULTY_CNT` ; do
	echo -e "\\tstrKeyValue"$i' = split(strKey,",")('$i - 1')' 
    done
}

strKeyValue_list() {
    local string=""
    for i in `seq $1` ; do
	string=$string'strKeyValue'"$i "
    done
    echo $string | sed -e 's/ $//g' -e 's/ /,/g'
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
    #if [ "$FILE_TYPE". = "SINGLE". ] ; then
	#_TBLIST_ADDNEW_STYLE=""
    #fi
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
    source $INCLUDE/ws_Template_Data.sh
    echo create  $_output/ws_"$TEMPLATE"_Data.asp
    #cat "$PATTERN"/ws_Template_Data.asp | \
    ws_template_data | \
	sed -e "s/##PKEY_#/$(echo $PKEY)/g" \
	    -e "s/##Template_#/$(echo $TEMPLATE)/g" \
	    >  $_output/ws_"$TEMPLATE"_Data.asp
}
_ws_template_delete() {
    echo create $_output/ws_"$TEMPLATE"_Delete.asp
    source "$INCLUDE"/ws_Template_Delete.sh
    ws_template_delete |\
	sed -e "s/##PKEY_#/$(echo $PKEY)/g" \
	    -e "s/##Template_#/$(echo $TEMPLATE)/g" \
        > $_output/ws_"$TEMPLATE"_Delete.asp
}
_ws_template_modifydata() {
    echo create $_output/ws_"$TEMPLATE"_ModifyData.asp
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

_ws_template_importdata() {
    if [ "$IS_IMPORT". == "TRUE". ] ; then
	echo create $_output/ws_"$TEMPLATE"_ImportData.asp
        source "$INCLUDE"/ws_Template_ImportData.sh
	ws_template_importdata > $_output/ws_"$TEMPLATE"_ImportData.asp
    fi
}
_template_sql() {
    source "$INCLUDE"/Template_SQL.sh
    local script=$_output/"$TEMPLATE".sql
    echo create sql script: $script
    template_sql > $script
}
_template_menusql() {
    source "$INCLUDE"/Template_SQL.sh
    local script=$_output/"$TEMPLATE".menu.sql
    echo create sql script: $script
    template_menusql > $script
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
_ws_template_importdata
_template_ws_getreportdata
#_template_sql
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

cat <<-EOF
# Execute "$_output/$TEMPLATE.sql" to server: $SQLSRV, database: $SQLDB
# to create "$TEMPLATE" table, "fn_DATA_$TEMPLATE" function
sqlcmd -S $SQLSRV -U $SQLUSR -d $SQLDB \
    -f 65001 -i "$_output/$TEMPLATE.sql" 2>&1 | piconv -f big5 -t utf-8
EOF
sqlcmd -S $SQLSRV -U $SQLUSR -P $SQLPWD -d $SQLDB \
    -f 65001 -i "$_output/$TEMPLATE.sql" 2>&1 | piconv -f big5 -t utf-8
}

_exec_menusql() {

cat <<-EOF
# Execute "$_output/$TEMPLATE.menu.sql" to server: $SQLSRV, database: $SQLDB to create "$TEMPLATE" menu.
# add data to "Program" and "ProgramField" tables.
sqlcmd -S $SQLSRV -U $SQLUSR -P $SQLPWD -d $SQLDB -f 65001 -i "$_output/$TEMPLATE.menu.sql" 2>&1 | piconv -f big5 -t utf-8
EOF
sqlcmd -S $SQLSRV -U $SQLUSR -P $SQLPWD -d $SQLDB \
    -f 65001 -i "$_output/$TEMPLATE.menu.sql" 2>&1 | piconv -f big5 -t utf-8
}


_project_build() {

    local PROJECTS="$1";    local RELATIONS="$2";   local DEPLOY="$3";	local EXECSQL="$4"; local BUILD_SRC="$5";
    local BUILD_CFG="$6";   local BUILD_SQL="$7";   local EXECMENU="$8";	local BUILD_MENU="$9";
    local tablename="";	    local PRJECT="";	    local RELATION="";  local n=1;	    local strReturn=""
    echo "BUILD_SRC: $BUILD_SRC, BUILD_SQL: $BUILD_SQL, BUILD_MENU: $BUILD_MENU, DEPLOY: $DEPLOY, EXECSQL: $EXECSQL, EXECMENU: $EXECMENU"

    for PROJECT in `echo $PROJECTS` ; do

	strReturn="`./template --schema-file $PROJECT.prj.xls`"

	if [ ! "$strReturn". = "". ] ; then
	    echo project: $PROJECT schema file not found.
	else

	    echo build project: $PROJECT
	    RELATION="`echo $RELATIONS | gawk -F ',' "{print $(echo '$'$(echo $n))}"`"

	    if [ "$RELATION". = "". ] ; then
		if [ $n = 1 ] ; then    echo Option --relation is blank, break build process.;	fi
		break
	    fi
	    if [ "$BUILD_CFG". == "enabled". ] ; then
		for tablename in `echo $RELATION` ; do
		    echo "#Create $tablename cfg file and script..."
		    echo "#template --schema-file $PROJECT.prj.xls --wks-name $table_name --create-cfg > cfg/$tablename.cfg"
		    template --schema-file $PROJECT.prj.xls --wks-name $tablename --create-cfg > cfg/$tablename.cfg
		done
	    fi
	    if [ "$BUILD_SQL". == "enabled". ] ; then
		for tablename in `echo $RELATION` ; do
		    if [ -e cfg/$tablename.cfg ] ; then
			echo "#template --cfg cfg/$tablename.cfg --template-sql"
			template --cfg cfg/$tablename.cfg --template-sql
		    else
			echo Warning...cfg/$tablename.cfg not exist, building abort.
		    fi
		done
	    fi
	    if [ "$BUILD_MENU". == "enabled". ] ; then
		for tablename in `echo $RELATION` ; do
		    if [ -e cfg/$tablename.cfg ] ; then
			echo "#template --cfg cfg/$tablename.cfg --template-menusql"
			template --cfg cfg/$tablename.cfg --template-menusql
		    else
			echo Warning...cfg/$tablename.cfg not exist, building abort.
		    fi
		done
	    fi
	    if [ "$BUILD_SRC". == "enabled". ] ; then
		for tablename in `echo $RELATION` ; do
		    if [ -e cfg/$tablename.cfg ] ; then
			echo "#template --cfg cfg/$tablename.cfg --all"
			template --cfg cfg/$tablename.cfg --all
		    else
			echo Warning...cfg/$tablename.cfg not exist, building abort.
		    fi
		done
	    fi
	    if [ "$DEPLOY". == "enabled". ] ; then
		for tablename in `echo $RELATION` ; do
		    if [ -e cfg/$tablename.cfg ] ; then
			echo "# deploy Project:$PROJECT, Table: $tablename source code to target host."
			echo template --cfg cfg/$tablename.cfg --deploy-script 
			template --cfg cfg/$tablename.cfg --deploy-script 
		    else
			echo Warning...cfg/$tablename.cfg not exist, building abort.
		    fi
		done
	    fi
	    if [ "$EXECSQL". == "enabled". ] ; then
		for tablename in `echo $RELATION` ; do
		    if [ -e cfg/$tablename.cfg ] ; then
			echo "# exec Project:$PROJECT, Table: $tablename sql code to target dbhost."
			echo template --cfg cfg/$tablename.cfg --exec-sql
			template --cfg cfg/$tablename.cfg --exec-sql
		    else
			echo Warning...cfg/$tablename.cfg not exist, building abort.
		    fi
		done
	    fi
	    if [ "$EXECMENU". == "enabled". ] ; then
		for tablename in `echo $RELATION` ; do
		    if [ -e cfg/$tablename.cfg ] ; then
			echo "# exec Project:$PROJECT, Table: $tablename menusql code to target dbhost."
			echo template --cfg cfg/$tablename.cfg --exec-menusql
			template --cfg cfg/$tablename.cfg --exec-menusql
		    else
			echo Warning...cfg/$tablename.cfg not exist, building abort.
		    fi
		done
	    fi
	fi
	echo "" ; n=$(expr $n + 1)
    done
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
    --template: create Table entry script.		--toolbar-list: create ToolBar_List script.

    --template-modify: create Table_Modify script.	--template-modify-layout: Table_Modify_Layout.
    --toolbar-modify: create Toolbar_Modify script.	--ws-template-savemodify: ws_Table_SaveModify.
    --template-script-savemodify: Script_SaveModify.    

    --template-new: create Table_New script.		--template-new-layout: create Talbe_New_Layout script.
    --template-toolbar-new: create Toolbar_New script.	--ws-template-savenew: ws_Table_SaveNew .
    --template-script-savenew: create Script_SaveNew.

    --ws-template-data:	      ws_Table_Data script.     --ws-template-modifydata: ws_Table_ModifyData.
    --ws-template-delete:     ws_Table_Delete script.   --ws-template-importdata: ws_Table_importdata. 

    --template-printdata: Talbe-PrintData script.	--template-report: create Table_Report script.
    --template-ws-getreportdata: ws_GetReportData.	--template-sql: create template sql script.
build:
    --project <prj_a prj_b> : define project.	
    --relation <rlta1 rlt2 rlt3,rltb1 rltb2 rltb3>: redfine relations for project a and b.
    --define < deploy | execsql > : define deploy to targethost, or run --exec-sql to target dbhost.
example:
    template --schema-file STKImport.prj.xls --wks-name STKItems --create-cfg > cfg/STKItems.cfg
    template --cfg cfg/STKItems.cfg --all           ## create asp and sql script to \$OUTPUT path.
    template --cfg cfg/STKItems.cfg --run-sql       ## not implement, run --template-sql output to target DB.
    template --cfg cfg/STKITems.cfg --deploy-script	## deploy scripts to target path.
build example:
    template --project MsgImport  --relation "MsgImport MsgStock" --define "src execsql deploy" --build
    template --project "prja prjb" --relation "rla1 rla2,rlb1 rlb2" --define "cfg src sql deploy execsql" --build
default action(project/*.prj.sh): GD_ACTIONS="cfg sql menusql src execsql deploy execmenu"
EOF
}

#__main
TABLE_OP="table:,pkey:,fields"
COMMON_OP="help,output:,cfg:,all,pattern:,deploy-script,exec-sql"
CREATE_CFG="create-cfg,wks-name:,schema-path:,schema-file:"
GEN_OP="template,template-modify,template-modify-layout,template-new,template-new-layout,\
template-printdata,template-report,template-script-savemodify,toolbar-list,\
toolbar-modify,template-toolbar-new,template-script-savenew,template-ws-getreportdata,\
template-sql"
WS_OP="ws-template-modifydata,ws-template-importdata,ws-template-delete,ws-template-data"
BUILD_OP="build,project:,relation:,define:"
MENU_OP="template-menusql,exec-menusql"
#echo $GEN_OP
ALL_OP="$GEN_OP,$WS_OP,$COMMON_OP,$ABORT_OP,$CREATE_CFG,$BUILD_OP,$MENU_OP"
orig_command="$@"
OPT=`getopt -o "" --longoptions=$ALL_OP -- "$@"`
#orig_command="$*"

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi


_output=./output

#echo OPT: $OPT
eval set -- "$OPT"
if [  $# -eq 1 ] ; then __show_help; fi

deploy=disable
execsql=disable
execmenu=disable
buildsrc=disable
sql=disable
menusql=disable
cfg=disable
project=""
relation=""
set -e
while true ; do
    case "$1" in
	--define)   shift; defines="$1";
		    for defi in `echo $defines` ; do
			#echo defi: \"$defi\"
			if [ "$defi". = "deploy". ] ; then 
			    deploy=enabled ; #echo deploy: $deploy
			fi
			if [ "$defi". = "execsql". ] ; then 
			    execsql=enabled ; #echo execsql: $execsql
			fi
			if [ "$defi". = "execmenu". ] ; then 
			    execmenu=enabled ; #echo execsql: $execsql
			fi
			if [ "$defi". = "src". ] ; then 
			    buildsrc=enabled ; #echo execsql: $execsql
			fi
			if [ "$defi". = "cfg". ] ; then 
			    cfg=enabled ; #echo cfg: $cfg
			fi
			if [ "$defi". = "sql". ] ; then 
			    sql=enabled ; #echo sql: $sql
			fi
			if [ "$defi". = "menusql". ] ; then 
			    menusql=enabled ; #echo sql: $sql
			fi
		    done
		    shift;;
	--project)  shift; project="$project $1" ; shift;;
	--relation) shift; relation="$1"; shift;;
	--build)    _project_build  "$project" "$relation" "$deploy" "$execsql" "$buildsrc" \
				    "$cfg" "$sql" "$execmenu" "$menusql"; 
		    shift;;
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

			#PRG_NAME="Eng/zh_TW/zh_CN"
			if [ "$PRG_NAME". = "". ] ; then    PRG_NAME="$TEMPLATE/$TEMPLATE/$TEMPLATE"; fi
			if [ "$PRG_CATE". = "". ] ; then    PRG_CATE="0051"; fi
			if [ "$PRG_MODULE". = "". ] ; then  PRG_MODULE="HSS"; fi
		    else
			echo cfg file not exist.
		    fi
		    shift ;;
	--menu-execsql)
		    ;;
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
	--exec-menusql) _exec_menusql; shift;;
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
	--ws-template-importdata)  _ws_template_importdata; shift;;
	--template-ws-getreportdata)  _template_ws_getreportdata; shift;;
	--template-sql)  _template_sql; shift;;
	--template-menusql)  _template_menusql; shift;;
        --)             break ;;
        *)              __show_help;   break ;;
    esac
done

