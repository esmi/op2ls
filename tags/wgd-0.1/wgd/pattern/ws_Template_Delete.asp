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
<!--#include virtual='/GDCRM/library/sys_CheckRelateTable_S.asp' -->
<%
'*******************************************************************
ON ERROR RESUME NEXT
'*******************************************************************
dim aryPerm, strProgID, i
dim strKeyFieldName, strProgTableName

strProgID = "##Template_#"
blnIsLog = sys_IsLogActivity(strProgID)
strProgTableName = "##Template_#"
strKeyFieldName = "##PKEY_#"

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

'必須有刪除的權限才可以執行
if aryPerm(3) = false then
    call sys_WriteActivityLog(2,"5DE78A86-D0B0-4743-9DA9-D573459D51CB","User doesn't has permission to delete data.")
    Response.Write objKey.ReadResString("NO_DELETE_PERMISSION",Session("s_Language"))
    Response.End
end if

'***********************************************
'找出指定的資料
'***********************************************
dim strSQL, rst1, strKey, strErrMsg
strKey = replace(Request("gd_Key"),"'","''")
strSQL = "SELECT * FROM " & strProgTableName & " WHERE " & strKeyFieldName & " = N'" & strKey & "'"

set rst1 = objPublic.CreateRecordset(strSQL,Application("a_CRMConnect"))
'檢查有沒有發生錯誤
if err.number <> 0 then
    call sys_WriteActivityLog(3,"79A241C1-CD45-406E-8216-34AF14C15290","Create recordset error." & vbcrlf & strSQL & vbcrlf & err.description)
    Response.write err.description & vbcrlf & "{79A241C1-CD45-406E-8216-34AF14C15290}"
    Response.end
end if

'檢查是否有關聯性的資料(參考到此)存在
strErrMsg= CheckRelateTable(strProgTableName,strKeyFieldName,strKey)
if strErrMsg <> "" then
    strErrMsg= objKey.ReadResString("NOT_ALLOW_DEL_STILL_REF",Session("s_Language")) & " " & strErrMsg
    Response.write strErrMsg
    Response.End
end if

dim strXML
strXML = objPublic.CreateRecordsetXML(strSQL,Application("a_CRMConnect"),1,1)

'檢查有沒有發生錯誤
if err.number <> 0 then
    call sys_WriteActivityLog(3,"79A241C1-CD45-406E-8216-34AF14C15290","Create recordset error." & vbcrlf & strSQL & vbcrlf & err.description)
    Response.write err.description & vbcrlf & "{79A241C1-CD45-406E-8216-34AF14C15290}"
    Response.end
end if

'***********************************************
'開始刪除資料
'***********************************************
if rst1.RecordCount = 1 then
    '**進行資料的檢查

    '**開啟資料庫的連結
    dim cnnDB
    set cnnDB = Server.CreateObject("ADODB.Connection")
    cnnDB.CursorLocation = 3    '3=adUseClient
    cnnDB.open Application("a_CRMConnect")
    cnnDB.BeginTrans

    '**刪除指定的 ##PKEY_# 資料
    strSQL = "DELETE " & strProgTableName & " WHERE " & strKeyFieldName & " = N'" & strKey & "'"
    cnnDB.Execute strSQL
    if err.number <> 0 then call DumpDeleteError("##PKEY_#")

    cnnDB.CommitTrans
    cnnDB.Close
    set cnnDB = nothing
    Response.Write "OK"
    '記錄成功刪除的Log
    if blnIsLog = true then
        if Application("a_LogTransData") = true then
            call sys_WriteActivityLog(1,"A597CE8B-3850-44D6-98FC-ED330C2E0CA4","(##Template_#) delete data succeed.",strXML)
        else
            call sys_WriteActivityLog(1,"A597CE8B-3850-44D6-98FC-ED330C2E0CA4","(##Template_#) delete data succeed.","##PKEY_#=" & rst1("##PKEY_#").value)
        end if
    end if
else
    Response.Write objKey.ReadResString("CAN_NOT_DELETE_SPECIFIC_DATA",Session("s_Language")) & vbcrlf & _
                   "{27B7C0AF-0B1F-4F15-A9C8-ABAF3339A1FA}"
end if

Sub DumpDeleteError(strTable)
    cnnDB.RollbackTrans
    cnnDB.Close
    set cnnDB = nothing
    Response.write "(" & strTable & ")" & vbcrlf & err.description & vbcrlf & "{F8672C5E-AD9C-42DC-B278-5D54615C124E}"
    call sys_WriteActivityLog(3,"F8672C5E-AD9C-42DC-B278-5D54615C124E","Error occur when delete data in related table." & vbcrlf & _
                                "(" & strTable & ")" & err.description)
    Response.End
End Sub
%>
