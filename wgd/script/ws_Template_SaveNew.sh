

header_ws_template_savenew() {
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

'必須有新增的權限才可以執行
if aryPerm(1) = false then
    call sys_WriteActivityLog(2,"43DB50E5-5CA0-48EC-AA19-5EAB822A85B1","User doesn't has permission to add data.")
    Response.Write objKey.ReadResString("NO_ADD_PERMISSION",Session("s_Language"))
    Response.End
end if

dim xmlDoc
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

'***********************************************
'進行資料的檢查
'***********************************************
dim objNode
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

dim strSQL,rst1
' 檢查是否有重複的鍵值
strSQL = "SELECT * FROM ##Template_# WHERE ##PKEY_#=N'" & Trim(objNode.selectSingleNode("##PKEY_#").text) & "'"
set rst1 = objPublic.CreateRecordset(strSQL,Application("a_CRMConnect"))
if err.number <> 0 then
    Response.write err.description & vbcrlf & "{79A241C1-CD45-406E-8216-34AF14C15290}"
    call sys_WriteActivityLog(3,"79A241C1-CD45-406E-8216-34AF14C15290","Create recordset error." & vbcrlf & strSQL & vbcrlf & err.description)
    Response.end
end if

if rst1.RecordCount<> 0 then
    Response.write objKey.ReadResString("MUST_BE_UNIQUE",Session("s_Language"),objKey.ReadResString("##PKEY_#",Session("s_Language")))
    Response.end
end if

strSQL = "SELECT * FROM ##Template_# WHERE (1=0)"
set rst1 = objPublic.CreateRecordset(strSQL,Application("a_CRMConnect"))

if err.number <> 0 then
    Response.write err.description & vbcrlf & "{79A241C1-CD45-406E-8216-34AF14C15290}"
    call sys_WriteActivityLog(3,"79A241C1-CD45-406E-8216-34AF14C15290","Create recordset error." & vbcrlf & strSQL & vbcrlf & err.description)
    Response.end
end if

'***********************************************
'開始新增資料
'***********************************************
rst1.AddNew
EOF
}
tailer_ws_template_savenew() {
cat <<-EOF
'RST1("CREATORID").VALUE = SESSION("S_EMPLID")
'rst1("CreateDeptID").value = Session("s_EmplDeptID")
'rst1("CreateDate").value = objPublic.GetServerNowUTC
'rst1("ModifierID").value = Session("s_EmplID")
'rst1("ModifyDeptID").value = Session("s_EmplDeptID")
'rst1("ModifyDate").value = objPublic.GetServerNowUTC
'rst1("OwnerID").value = Session("s_EmplID")
'rst1("OwnerDeptID").value = Session("s_EmplDeptID")

'檢查有沒有發生錯誤
if err.number <> 0 then
    Response.write err.description & vbcrlf & "{F056EE9E-EBF3-4ECC-9C3C-7CFCF0A8CE36}"
    call sys_WriteActivityLog(3,"F056EE9E-EBF3-4ECC-9C3C-7CFCF0A8CE36","Error occur during adding data to recordset's new reocrd." & vbcrlf & err.description)
    Response.end
end if


'執行寫入的動作
set rst1 = objPublic.UpdateRecordset(rst1,Application("a_CRMConnect"))

'檢查有沒有發生錯誤
if err.number <> 0 then
    Response.write err.description & vbcrlf & "{AC98300C-81C2-4C90-9A2B-832305475D93}"
    call sys_WriteActivityLog(3,"AC98300C-81C2-4C90-9A2B-832305475D93","Error occur when call objPublic.UpdateRecordset()." & vbcrlf & err.description)
    Response.end
end if

dim strXML
strXML = "<?xml version='1.0' encoding='utf-8' ?>" & vbcrlf & _
         "<Recordset>" & vbcrlf & _
         "<Record>" & _
         "<Key>" & rst1("##PKEY_#").value & "</Key>" & _
         "</Record>" & _
         "</Recordset>"

Response.Write strXML

'記錄成功新增的Log
if blnIsLog = true then
    if Application("a_LogTransData") = true then
        call sys_WriteActivityLog(1,"9AEDBDED-F118-4EC7-8EDA-6AB54894C66C","(##Template_#) Save new data succeed.",null,xmlDoc.xml)
    else
        call sys_WriteActivityLog(1,"9AEDBDED-F118-4EC7-8EDA-6AB54894C66C","(##Template_#) Save new data succeed.",null,"##PKEY_#=" & rst1("##PKEY_#").value)
    end if
end if
%>

EOF
}
field_ws_template_savenew() {
cat <<-EOF
rst1.Fields("##FieldName_#").value = Trim(objNode.selectSingleNode("##FieldName_#").text)
EOF
}

ws_template_savenew() {
    header_ws_template_savenew

    #field_ws_template_savenew | sed "s/##FieldName_#/$(echo $PKEY)/g"
    for fd in $(echo $FIELDS ) ; do
	FieldName=$(echo $fd | gawk -F "/" '{print $1}')
	FieldShowType=$(echo $fd | gawk -F "/" '{print $2}')
	if [ ! "$FieldShowType". = "System".  ] ; then
	    if [ ! "$FieldShowType". = "Hidden".  ] ; then
		field_ws_template_savenew | sed "s/##FieldName_#/$(echo $FieldName)/g"
	    fi
	 fi
    done

    tailer_ws_template_savenew

}
