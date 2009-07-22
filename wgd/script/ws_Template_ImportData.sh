

importdata_header() {
cat <<-EOF
<%@Language=Vbscript CodePage=65001%>
<%
Option Explicit
Response.Buffer=true
Response.Expires=-1
Session.codepage=65001
%>
<!--#include virtual='/GDCRM/library/sys_SystemCheck_S.asp' -->
<%
EOF
}

importdata_related_data() {
cat <<-EOF
'*******************************************************************
'定義程式參數
'*******************************************************************
dim strKey
Dim $(strKeyValue_list $KEYMULTY_CNT)
strKey = trim(Request("gd_Key"))
if instr(1,strKey,",") > 0 then
$(strKeyValue_assign)
Else
    Response.Write "Need Key Value"
    Response.End
End If
'other related data define.
'...
EOF
}


importdata_get_attach_info() {
cat <<-EOF
'*******************************************************************
'取得當比資料的附件相關資料
'*******************************************************************
Dim strSQLTemp
Dim rstTemp
Dim strExcelSource

strSQLTemp = "Select * from fn_Data_Attachments() " & _
	     "where AttachID=(Select AttachID from ${TEMPLATE} " & _
			      " where " & $(modifydata_where_filter) & ")"

' DeptID=N'" &  strKeyValue1 & "'  AND " & _ 
'				    "PeriodId=N'" & strKeyValue2 & "' AND " & _
'				    "WhrsId=N'" & strKeyValue3 & "')"

'Response.Write strSQLTemp
'Response.End

Set rstTemp = objPublic.CreateRecordset(strSQLTemp, Application("a_CRMConnect"))

If rstTemp.RecordCount = 1 Then
	strExcelSource = Application("a_DocRootPath") & _
				    "${TEMPLATE}\" &  _
				    Left(rstTemp.Fields("FileID").value,2) & "\" & _
				    rstTemp.Fields("FileID").value & "\" & _
				    rstTemp.Fields("FileName").value
else
    if rstTemp.RecordCount < 1 then
	Response.Write "Attachment data not found, Please check attachment data"
    End if
    if rstTemp.RecordCount > 1 then
	Response.Write "Attachment data more than one file, Please check attachment data"
    End if
    'Response.Write "Attachment data error, Please check attachment data"
    Response.End
End if
EOF
}

importdata_prepare() {
cat <<-EOF
Dim cnnExcel
Dim strExcelConn
Dim rstExcel
Dim strSQL

Dim strSQL${RELATED_TABLE}
Dim rst${RELATED_TABLE}

strSQL${RELATED_TABLE} = "Select * from ${RELATED_TABLE} where (1=2)"
Set rst${RELATED_TABLE} = objPublic.CreateRecordset(strSQL${RELATED_TABLE}, Application("a_CRMConnect"))

 
strExcelConn = "Provider=Microsoft.Jet.OLEDB.4.0" & _
                   ";Data Source=" & strExcelSource & _
                   ";Extended Properties=""Excel 8.0;HDR=Yes"""

Set cnnExcel = Server.CreateObject("ADODB.Connection")
Set rstExcel = Server.CreateObject("ADODB.Recordset")

'[Sheet1$]工作表名稱需要有固定名稱:[${WKSHEET}$]
'ATTACH_FIELDS: ${ATTACH_FIELDS}
strSQL = "Select ${ATTACH_FIELDS} from [${WKSHEET}$]"

cnnExcel.CursorLocation = 3
cnnExcel.Open strExcelConn

rstExcel.CursorLocation = 3
rstExcel.CursorType = 1
rstExcel.LockType = 3

EOF
}

importdata_attach_open() {
cat <<-EOF
rstExcel.Open strSQL,cnnExcel
EOF
}

importdata_attach_check() {
#'Check attachment data.
cat <<-EOF
Dim intCount
rstExcel.MoveFirst
EOF
if [ "$IS_FIRST_TITLE". = "TRUE". ] ; then echo rstExcel.MoveNext; fi
cat <<-EOF
For intCount = 1 To (rstExcel.RecordCount-1)

    'if ( _importdata_check_key() ) then _importdata_msg_sting1
    if ( $(_importdata_check_key) ) then
        response.Write "Record #: " & cstr( intCount + 2 ) & " error, "   & _
			$(_importdata_msg_string1)
        response.End
    end if	    
    rstExcel.MoveNext
Next
EOF
}

importdata_write() {
cat <<-EOF
rstExcel.MoveFirst
EOF

if [ "$IS_FIRST_TITLE". = "TRUE". ] ; then echo rstExcel.MoveNext; fi
cat <<-EOF
For intCount = 1 To (rstExcel.RecordCount-1)
    rst${RELATED_TABLE}.AddNew
    ' _importdata_key_assign()
    $(_importdata_key_assign)
    
    ' _importdata_attach_fields()
    $( _importdata_attach_fields)
    rstExcel.MoveNext
Next

objPublic.UpdateRecordset rst${RELATED_TABLE}, Application("a_CRMConnect")
EOF
}

importdata_tailer() {
cat <<-EOF
If Err.number = 0 then
    Response.Write "OK"
Else
    Response.Write Err.Description
End if
%>
EOF
}

_importdata_attach_fields() {

    local wc=`echo $ATTACH_FIELDS | sed 's/,/ /g' | wc -w`
    for i in `echo $ATTACH_FIELDS | sed 's/,/ /g'` ; do
	echo -e "\\trst${RELATED_TABLE}(\"${i}\").value=rstExcel(\"${i}\").value"
    done

}
_importdata_key_assign() {
    for i in `seq $KEYMULTY_CNT` ; do
	if [ "$i". == "$KEYMULTY_CNT". ] ; then
	    tailer=''
	else
	    tailer=' & ", " & _ '
	fi
        fd=`echo $KEY_MULTY | gawk -F ',' "{print $(echo '$'$(echo $i))}"`
	echo  -e "\\trst""${RELATED_TABLE}(\""$fd"\").value=strKeyValue"$i
    done
}
_importdata_msg_string1() {
    for i in `seq $KEYMULTY_CNT` ; do
	if [ "$i". == "$KEYMULTY_CNT". ] ; then
	    tailer=''
	else
	    tailer=' & ", " & _ '
	fi
        fd=`echo $KEY_MULTY | gawk -F ',' "{print $(echo '$'$(echo $i))}"`
	echo  -e "\\t\"$fd: \" & "strKeyValue$i' & "(" & cstr(rstExcel("'$fd'").value) & ")"' \
		$tailer
    done
}
_importdata_check_key() {
    for i in `seq $KEYMULTY_CNT` ; do
	if [ "$i". == "$KEYMULTY_CNT". ] ; then
	    tailer=''
	else
	    tailer=' or '
	fi
	echo  -n "cstr(rstExcel(\""`echo $KEY_MULTY | 
		    gawk -F ',' "{print $(echo '$'$(echo $i))}"`"\").value) <> "strKeyValue$i"$tailer"
    done

}

ws_template_importdata() {
    KEYMULTY_CNT=`echo $KEY_MULTY | sed 's/,/ /g' | wc -w`
    echo 1>&2 $KEYMULTY_CNT
    importdata_header
    importdata_related_data
    importdata_get_attach_info
    importdata_prepare
    importdata_attach_open
    importdata_attach_check
    importdata_write
    importdata_tailer
}

