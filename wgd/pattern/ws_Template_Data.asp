﻿<%@Language=Vbscript CodePage=65001%>
<%
Option Explicit
Response.Buffer=true
Response.Expires=-1
Session.codepage=65001
%>
<!--#include virtual='/GDCRM/library/sys_SystemCheck_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetProgramPermission_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetCalledArray_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_KeyInArray_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_DateTimeFunction_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_VarReplace_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_ConvertExcel_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_CheckSQLInjection_S.asp' -->
<%
'*******************************************************************
ON ERROR RESUME NEXT
'*******************************************************************
dim aryPerm, strProgID, i
strProgID = "##Template_#"

'*******************************************************************
'程式權限檢查
'*******************************************************************
'讀取使用者對於本程式的使用權限
aryPerm = sys_GetProgramPermission(strProgID,Session("s_EmplID"))

'程式權限檢查 0=ExecPerm 1=AddPerm 2=ModifyPerm 3=DelPerm 4=PrintPerm 5=Ext1Perm 6=Ext2Perm 7=Ext3Perm 8=DataOwnerType
if IsArray(aryPerm) = false then
    call sys_WriteActivityLog(2,"B3AFE355-D9D9-4311-8192-48F5BE3E6DDD","Can not found program permission definition of user.")
    Response.Write objKey.ReadResString("CAN_NOT_FIND_USERS_PERMISSION",Session("s_Language"),Session("s_EmplID"),strProgID)
    Response.End
end if

'如果是PowerUser，則擁有所有的權限
if Session("s_PowerUser") = true then
    redim aryPerm(8): for i = 0 to 7 : aryPerm(i)=true :next :aryPerm(8)=9
end if

'至少必須有執行的權限，如果沒有修改的權限，自動會從[修改模式]轉換為[檢視模式]
if aryPerm(0) = false then
    call sys_WriteActivityLog(2,"0245DC22-6D78-4533-B495-BD627AE71B96","User doesn't has permission to execute program.")
    Response.Write objKey.ReadResString("NO_EXECUTE_PERMISSION",Session("s_Language"))
    Response.End
end if

'(開始)==> 接收傳入的參數
dim aryCmd,intStartPage,intEndPage,strErrMsg
if Left(Request("gd_Cmd"),5) = "EXCEL" then
    aryCmd = split(Request("gd_Cmd"),",")
    intStartPage = cint(aryCmd(1))
    intEndPage = cint(aryCmd(2))
    if err.number <> 0 then
        strErrMsg = objKey.ReadResString("EXCEL_PARAMETER_ERROR",Session("s_Language")) & "<p>" & err.description
        call sys_ShowErrorHtml(strErrMsg,"","close")
    end if
end if

dim intPage
if isNumeric(Request("gd_P")) <> true then
    intPage = 1
else
    intPage = cint(Request("gd_P"))
    if intPage <= 0 then intPage = 1
end if

dim intPageSize
if isNumeric(trim(Request("gd_S"))) <> true then
    intPageSize = Session("s_PageSize")    '未傳入時，預設值為使用者的分頁大小
else
    intPageSize = cint(trim(Request("gd_S")))
    if intPageSize <= 0 then intPageSize = 1        '每頁的下限為1筆
    if intPageSize >= 100 then intPageSize = 100    '每頁的上限為100筆
end if

dim strWhereClause
strWhereClause = trim(Request("gd_W"))
sys_CheckSQLInjection(strWhereClause)
strWhereClause = sys_VarReplace(strWhereClause)

dim strOrderByClause
strOrderByClause = trim(Request("gd_O"))
sys_CheckSQLInjection(strOrderByClause)

dim strFilterClause
strFilterClause = trim(Request("gd_FI"))
sys_CheckSQLInjection(strFilterClause)
strFilterClause = sys_VarReplace(strFilterClause)

dim strPermRestrict
strPermRestrict = ""

dim strPartialField
strPartialField = ucase(trim(Request("gd_PF")))
'(結束)==> 接收傳入的參數

dim strSQL
'參數 Request("gd_T") 是代表是否為SQB測試SQL語法?
if Request("gd_T") = "Y" then
    strSQL = "SELECT TOP 1 ##PKEY_# FROM fn_Data_##Template_#('" & Session("s_Language") & "') "
else
    strSQL = "SELECT TOP " & Session("s_MaxRecord") & " * " & _
             "FROM fn_Data_##Template_#('" & Session("s_Language") & "') "
end if

if strFilterClause <> "" then
    if strWhereClause <> "" then
        if strPermRestrict = "" then
            strSQL = strSQL & " WHERE (" & strWhereClause & ") AND (" & strFilterClause & ") "
        else
            strSQL = strSQL & " WHERE (" & strPermRestrict & ") AND (" & strFilterClause & ") AND (" & strWhereClause & ")"
        end if
    else
        if strPermRestrict = "" then
            strSQL = strSQL & " WHERE " & strFilterClause
        else
            strSQL = strSQL & " WHERE (" & strPermRestrict & ") AND (" & strFilterClause & ")"
        end if
    end if
else
    if strWhereClause <> "" then
        if strPermRestrict = "" then
            strSQL = strSQL & " WHERE " & strWhereClause
        else
            strSQL = strSQL & " WHERE (" & strPermRestrict & ") AND (" & strWhereClause & ")"
        end if
    else
        if strPermRestrict = "" then
            'DO NOTHING
        else
            strSQL = strSQL & " WHERE " & strPermRestrict
        end if
    end if
end if

if strOrderByClause <> "" then
    strSQL = strSQL & " ORDER BY " & strOrderByClause
else
    strSQL = strSQL & " ORDER BY ##PKEY_# "
end if

'*** for debug
'Response.Write strSQL
'Response.End
'*** for debug

if IsArray(aryCmd) then
    Call sys_ConvertExcel()
elseif Request("gd_T") = "Y" then
    dim rst1,cnnDB
    set cnnDB = Server.CreateObject("ADODB.Connection")
    cnnDB.Open Application("a_CRMConnect")
    set rst1 = Server.CreateObject("ADODB.Recordset")
    rst1.open strSQL,cnnDB
    if err.number <> 0 then
        Response.Write err.description
    else
        Response.Write "OK"
    end if
else
    dim strXML,aryFields
    if strPartialField = "Y" then
        dim xmlStyle
        set xmlStyle = Server.CreateObject("Microsoft.XMLDOM")
        xmlStyle.async = false
        xmlStyle.load Request
        aryFields = sys_GetCalledArray(xmlStyle)
        aryFields = sys_KeyInArray(aryFields,"##PKEY_#")
        '檢查有沒有發生錯誤
        if err.number <> 0 then
            Response.write err.description & vbcrlf & "{D285C51A-00CA-458A-B1C5-B05B20A165F4}"
            call sys_WriteActivityLog(3,"D285C51A-00CA-458A-B1C5-B05B20A165F4","Error occur when get partial field." & vbcrlf & err.description)
            Response.end
        end if
        '僅傳回指定的欄位
        strXML = objPublic.CreateRecordsetXML(strSQL,Application("a_CRMConnect"),intPage,intPageSize,aryFields)
    else
        strXML = objPublic.CreateRecordsetXML(strSQL,Application("a_CRMConnect"),intPage,intPageSize)
    end if

    if err.number <> 0 then
        Response.write err.description & vbcrlf & "{625A074D-606E-41CD-B006-9DA4150290DF}"
        call sys_WriteActivityLog(3,"625A074D-606E-41CD-B006-9DA4150290DF","Error occur when call objPublic.CreateRecordsetXML()." & vbcrlf & err.description)
    else
        Response.Write strXML
    end if
end if

Function UserModifyContent(strContent,strFieldName,objNode)
    dim str1
    select case strFieldName
        case else
            str1 = strContent
    end select
    UserModifyContent = str1
End Function

Function HtmlPostProcess(strHtml)
    HtmlPostProcess = strHtml
End Function
%>
