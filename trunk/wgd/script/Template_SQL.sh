
#TEMPLATE=Whrs
#TABLE=Whrs
#PKEY=WhrsId
#LOCATION=Whrs

#PFIELD="$PKEY/text/nvarchar/5/Not/whrsId/信息量倉編碼/信息量倉編碼"
#FIELDS="Description/text/nvarchar/20//dscription/說明/說明 \
#Abbrevation/text/nvarchar/10//Abbrevation/簡稱/簡稱 \
#StockID/text/nvarchar/10//StockID/StockID/StockID \
#Enter_four/text/nvarchar/4//four_code/HS前四碼/HS前四碼 \
#ERP_StockId/text/nvarchar/10//ERPStockID/ERP倉庫代碼/ERP倉庫代碼"
#
#GD_ModuleID=HSS
#DOCROOT=/GDCRM

table_body() {
    local TableFD="$PFIELD $FIELDS"
    local priority=0
    for ft in $TableFD ; do
	local fieldname=$(echo $ft | gawk -F '/' '{print $1}' )
        local datatype=$(echo $ft | gawk -F '/' '{print $3}' )
	local datalength=$(echo $ft | gawk -F '/' '{print $4}' )
        local isnull=$(echo $ft | gawk -F '/' '{print $5}' )
	echo -n \[$fieldname\] \[$datatype\] '('$datalength')' $isnull NULL ,
    done
}
table_sql() {
cat <<-EOF
if exists (select * from dbo.sysobjects 
    where id = object_id(N'[dbo].[`echo $TEMPLATE`]') 
        and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[`echo $TEMPLATE`]
GO
CREATE TABLE [dbo].[`echo $TEMPLATE`] (
EOF
table_body | sed -e 's/,$//g' -e 's/,/,#/g' | tr '#' '\n'
cat <<-EOF
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[`echo $TEMPLATE`] ADD
CONSTRAINT [PK_`echo $TEMPLATE`] PRIMARY KEY  CLUSTERED
(
[`echo $PKEY`]
)  ON [PRIMARY]
GO
EOF
}

table_function_body() {
local TableFD="$PFIELD $FIELDS"
for ft in $TableFD ; do

    local fieldname=$(echo $ft | gawk -F '/' '{print $1}' )
    echo -n $fieldname,
done
}
table_function() {
cat <<-EOF
if exists ( select * from dbo.sysobjects 
    where id = object_id(N'[dbo].[fn_Data_$(echo $TEMPLATE)]') 
      and name = Object_name(object_id(N'[dbo].[fn_Data_$(echo $TEMPLATE)]')) ) 
drop function [dbo].[fn_data_$(echo $TEMPLATE)]
EOF

cat <<-EOF

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
Create FUNCTION [dbo].[fn_Data_Whrs](@strLang nvarchar(3))
RETURNS TABLE
AS
RETURN (
EOF

table_function_body | sed -e 's/^/select /g' -e 's/,$//g'

cat <<-EOF
  FROM `echo $TEMPLATE`
)
GO
EOF
}
program_sql() {
    local ProgID=$TEMPLATE
    local Priority=20
    local ModuleID=$GD_ModuleID
    local CategoryID=0051
    local ProgNameENG=$TABLE
    local ProgNameCHT=$TABLE

    local ProgNameCHS=$TABLE
    local ParentProgID=""
    local IsDisplay=1
    local IsLog=0
    local ProgIconUrl=$DOCROOT/images/sys_tool_Program.gif
    local ProgIconUrl64=$DOCROOT/images/sys_tool_Program_64.gif
    local URL=$DOCROOT/Prog/$LOCATION/$TEMPLATE.asp
    local Target="fraContent"
    local MarkTableName=""
    local ExtNotes=""
    local chkflag=0

    echo delete from Program where ProgID=\'$ProgID\'
    echo go
    echo insert into Program \
    values \( \'$ProgID\', \
	    $Priority, \
	    \'$ModuleID\', \
	    \'$CategoryID\', \
	    \'$ProgNameENG\', \
	    \'$ProgNameCHT\', \
	    \'$ProgNameCHS\', \
	    \'$ParentProgID\', \
	    $IsDisplay, \
	    $IsLog, \
	    \'$ProgIconUrl\', \
	    \'$ProgIconUrl64\', \
	    \'$URL\', \
	    \'$Target\', \
	    \'$MarkTableName\', \
	    \'$ExtNotes\', \
	    $chkflag  \)
    echo go
}
programfields_sql() {

echo delete ProgramField where ProgID=\'$TEMPLATE\'
echo go
local TableFD="$PFIELD $FIELDS"
local priority=0
for ft in $TableFD ; do

    local priority=$(expr $priority + 10)
    local fieldname=$(echo $ft | gawk -F '/' '{print $1}' )
    local datatype=$(echo $ft | gawk -F '/' '{print $3}' )
    
    local fieldtitleeng=$(echo $ft | gawk -F '/' '{print $6}' )
    local fieldtitlecht=$(echo $ft | gawk -F '/' '{print $7}' )
    local fieldtitlechs=$(echo $ft | gawk -F '/' '{print $8}' )

    local ProgID=$TEMPLATE
    local Priority="$priority"
    local Fieldname="$fieldname"
    local IsMultiLang=1
    local DialogWindow=""
    local FieldTitleENG="$fieldtitleeng"
    local FieldTitleCHT="$fieldtitlecht"
    local FieldTitleCHS="$fieldtitlechs"
    local DataType="$datatype"
    local CanSorted="N"
    local CanQuery=1
    local CanView=1
    local Width=20
    local Align="left"
    local SampleLength=2
    local chkflag=0
    echo insert into ProgramField \
    values \( \
	\'$ProgID\', \
	$Priority, \
	\'$Fieldname\', \
	$IsMultiLang, \
	\'$DialogWindow\', \
	\'$FieldTitleENG\', \
	\'$FieldTitleCHT\', \
	\'$FieldTitleCHS\', \
	\'$DataType\', \
	\'$CanSorted\', \
	$CanQuery, \
	$CanView, \
	$Width, \
	\'$Align\', \
	$SampleLength, \
	$chkflag \)
    echo go
done
}

perm_template_detail() {

    local PermTemplateID="__Default"
    local ProgID="$TEMPLATE"
    local ExecPerm=1
    local AddPerm=0
    local MarkTableNameodifyPerm=0
    local DelPermNULL=0
    local PrintPerm=0
    local IsLog=0
    local Ext1Perm=0
    local Ext2Perm=0
    local Ext3Perm=0
    local DataTypeataOwnerType=0
    local CreateDeptID="__Root"
    local CreateeatorID="admin"
    local CreateDate="$(echo `date --rfc-3339=second` | sed 's/+.*$//g')"
    local ModifyDeptID="__Root"
    local ModifierID="admin"
    local ModifierIDyDate="$CreateDate"
    local chkflag=0

    echo delete PermTemplateDetail \
	     where ProgID = \'$TEMPLATE\' and PermTemplateID = \'$PermTemplateID\'
    echo insert PermTemplateDetail \
    values  \( \
	\'$PermTemplateID\', \
	\'$ProgID\', \
	$ExecPerm, \
	$AddPerm, \
	$MarkTableNameodifyPerm, \
	$DelPermNULL, \
	$PrintPerm, \
	$IsLog, \
	$Ext1Perm, \
	$Ext2Perm, \
	$Ext3Perm, \
	$DataTypeataOwnerType, \
	\'$CreateDeptID\', \
	\'$CreateeatorID\', \
	\'$CreateDate\', \
	\'$ModifyDeptID\', \
	\'$ModifierID\', \
	\'$ModifierIDyDate\', \
	$chkflag \
    \)
}

template_sql() {
    echo use $GD_DATABASE
    table_sql
    table_function
    program_sql
    programfields_sql 
    perm_template_detail
    
}
