
header_ws_template_savemodify() {
cat <<-EOF
<%@Language=Vbscript CodePage=65001%>
<%
Option Explicit
Response.Buffer=true
Response.Expires=-1
Session.codepage=65001
%>
<!--#include virtual='/GDCRM/library/sys_SystemCheck_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetProgramPermission_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_IsLogActivity_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetUserDefineRecordset_S.asp' -->
<%
'***********************************************
ON ERROR RESUME NEXT
'***********************************************
dim strErrMsg, strProgID, aryPerm, i, blnIsLog

strProgID = "##Template_#"
blnIsLog = sys_IsLogActivity(strProgID)

'**** 讀取使用者對於本程式的使用權限
aryPerm = sys_GetProgramPermission(strProgID,Session("s_EmplID"))

'**** 程式權限檢查 0=ExecPerm 1=AddPerm 2=ModifyPerm 3=DelPerm 4=PrintPerm 5=Ext1Perm 6=Ext2Perm 7=Ext3Perm 8=DataOwnerType
if IsArray(aryPerm) = false then
    call sys_WriteActivityLog(2,"B3AFE355-D9D9-4311-8192-48F5BE3E6DDD","Can not found program permission definition of user.")
    Response.Write objKey.ReadResString("CAN_NOT_FIND_USERS_PERMISSION",Session("s_Language"),Session("s_EmplID"),strProgID)
    Response.End
end if

'如果是PowerUser，則擁有所有的權限
if Session("s_PowerUser") = true then
    redim aryPerm(8): for i = 0 to 7 : aryPerm(i)=true :next :aryPerm(8)=9
end if

'必須有修改的權限才可以執行
if aryPerm(2) = false then
    call sys_WriteActivityLog(2,"80E9F4BB-88D1-4696-A879-840E5F49A496","User doesn't has permission to edit data.")
    Response.Write objKey.ReadResString("NO_EDIT_PERMISSION",Session("s_Language"))
    Response.End
end if

dim xmlDoc,objNode
set xmlDoc = Server.CreateObject("Microsoft.XMLDOM")
xmlDoc.async = false
xmlDoc.load Request

if (xmlDoc.parseError.errorCode <> 0) then
    call sys_WriteActivityLog(3,"6200CDC1-2C20-47DA-B812-202E08E9346F","XML document parse error." & vbcrlf & xmlDoc.parseError.reason)
    strErrMsg = objKey.ReadResString("LOAD_XML_DOCUMENT_ERROR",Session("s_Language")) & vbcrlf & _
                "{6200CDC1-2C20-47DA-B812-202E08E9346F}" & vbcrlf & _
                objKey.ReadResString("ERROR_DESCRIPTION",Session("s_Language")) & xmlDoc.parseError.reason

    Response.write strErrMsg
    Response.End
end if

'*****************************************************************************
'進行資料的檢查
'*****************************************************************************
set objNode = xmlDoc.documentElement.selectSingleNode("/Recordset/Record")
if Trim(objNode.selectSingleNode("##PKEY_#").text) = "" then
    Response.Write objKey.ReadResString("##PKEY_#",Session("s_Language")) & _
                   objKey.ReadResString("CAN_NOT_BLANK",Session("s_Language"))
    Response.End
end if

if err.number <> 0 then
    Response.write err.description & vbcrlf & "{4A00CD6E-CDE4-493B-95D4-3B7F4D9CD1D3}"
    call sys_WriteActivityLog(3,"4A00CD6E-CDE4-493B-95D4-3B7F4D9CD1D3","Error occur during checking user post data." & vbcrlf & err.description)
    Response.end
end if

'*****************************************************************************
' 開始讀取資料
'*****************************************************************************
dim strSQL,rst1
strSQL = "SELECT * FROM ##Template_# WHERE ##PKEY_# = N'" & Trim(objNode.selectSingleNode("##PKEY_#").text) & "'"
set rst1 = objPublic.CreateRecordset(strSQL,Application("a_CRMConnect"))

if err.number <> 0 then
    Response.write err.description & vbcrlf & "{79A241C1-CD45-406E-8216-34AF14C15290}"
    call sys_WriteActivityLog(3,"79A241C1-CD45-406E-8216-34AF14C15290","Create recordset error." & vbcrlf & strSQL & vbcrlf & err.description)
    Response.end
end if

if rst1.RecordCount <> 1 then
    Response.Write objKey.ReadResString("CAN_NOT_UPDATE_SPECIFIC_DATA",Session("s_Language")) & vbcrlf & _
                   "{CB4E95C8-6835-4FE6-80F7-DE8BC24E6C87}": response.end
else
    '開始更新資料
EOF
}
tailer_ws_template_savemodify() {
cat <<-EOF
    if clng(rst1.Fields("chkflag").value) <> clng(objNode.selectSingleNode("chkflag").text) then
        Response.Write objKey.ReadResString("MULTIUSER_UPDATE_THE_SAME_DATA_RELOAD",Session("s_Language"))
        Response.End
    else
        rst1.Fields("chkflag").value = clng(rst1.Fields("chkflag").value) + 1
    end if
	
    '檢查有沒有發生錯誤
    if err.number <> 0 then
        Response.write err.description & vbcrlf & "{EFB10961-92A8-48BE-9EC7-26E2FF45EBD0}"
        call sys_WriteActivityLog(3,"EFB10961-92A8-48BE-9EC7-26E2FF45EBD0","Error occur during update data to recordset's reocrd." & vbcrlf & err.description)
        Response.end
    end if

    '記錄原先資料的XML
    if blnIsLog and Application("a_LogTransData") then
        dim strLogXML
        strSQL = "SELECT * FROM ##Template_# WHERE ##PKEY_#= N'" & rst1("##PKEY_#").value & "' "
        strLogXML = objPublic.CreateRecordsetXML(strSQL, Application("a_CRMConnect"))
        if err.number <> 0 then err.clear: strLogXML = ""
    end if

    call objPublic.UpdateRecordset(rst1, Application("a_CRMConnect"))

    '檢查有沒有發生錯誤
    if err.number <> 0 then
        Response.write err.description & vbcrlf & "{AC98300C-81C2-4C90-9A2B-832305475D93}"
        call sys_WriteActivityLog(3,"AC98300C-81C2-4C90-9A2B-832305475D93","Error occur when call objPublic.UpdateRecordset()." & vbcrlf & err.description)
        Response.end
    end if
end if

'記錄成功修改的Log
if blnIsLog = true then
    if Application("a_LogTransData") = true then
        call sys_WriteActivityLog(1,"EAB42C31-8BD9-4CCC-B6B4-726DD0DD8A8C","(##Template_#) update data succeed.",strLogXML,xmlDoc.xml)
    else
        call sys_WriteActivityLog(1,"EAB42C31-8BD9-4CCC-B6B4-726DD0DD8A8C","(##Template_#) update data succeed.","##PKEY_#=" & rst1("##PKEY_#").value,"##PKEY_#=" & rst1("##PKEY_#").value)
    end if
end if
Response.Write "OK"
%>

EOF
}
field_ws_template_savemodify() {
cat <<-EOF
    rst1.Fields("##FieldName_#").value = Trim(objNode.selectSingleNode("##FieldName_#").text)
EOF
}

ws_template_savemodify() {
    header_ws_template_savemodify

    field_ws_template_savemodify | sed "s/##FieldName_#/$(echo $PKEY)/g"
    for fd in $(echo $FIELDS ) ; do
	FieldName=$(echo $fd | gawk -F "/" '{print $1}')
	field_ws_template_savemodify | sed "s/##FieldName_#/$(echo $FieldName)/g"
    done

    tailer_ws_template_savemodify

}
