﻿<%@Language=Vbscript CodePage=65001%>
<%
Option Explicit
Response.Buffer=true
Response.Expires=-1
Session.codepage=65001
%>
<!--#include virtual='/GDCRM/library/sys_SystemCheck_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetProgramPermission_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_DateTimeFunction_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_VarReplace_S.asp' -->
<%
'*******************************************************************
'ON ERROR RESUME NEXT
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

'至少必須有執行的權限
if aryPerm(0) = false then
    call sys_WriteActivityLog(2,"0245DC22-6D78-4533-B495-BD627AE71B96","User doesn't has permission to execute program.")
    Response.Write objKey.ReadResString("NO_EXECUTE_PERMISSION",Session("s_Language"))
    Response.End
end if

'(開始)==> 接收傳入的參數
dim strKey
strKey = trim(Request("gd_Key"))

dim strCommand
strCommand = ucase(trim(Request("gd_Cmd")))

dim strWhereClause
strWhereClause = trim(Request("gd_W"))
strWhereClause = sys_VarReplace(strWhereClause)

dim strOrderByClause
strOrderByClause = trim(Request("gd_O"))

dim strFilterClause
strFilterClause = trim(Request("gd_FI"))
strFilterClause = sys_VarReplace(strFilterClause)

dim strPermRestrict
strPermRestrict = ""
'(結束)==> 接收傳入的參數

'找出目前範圍內的資料
dim strSQL
strSQL = "SELECT TOP " & Session("s_MaxRecord") & " ##PKEY_# " & _
         "FROM fn_Data_##Template_#('" & Session("s_Language") & "') "

'(開始)==> 組成SQL的條件限制子句
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
'(結束)==> 組成SQL的條件限制子句

'先找出符合查詢條件範圍內的資料清單
dim rst1
set rst1 = objPublic.CreateRecordset(strSQL, Application("a_CRMConnect"))
'檢查有沒有發生錯誤
if err.number <> 0 then
    Response.write err.description & vbcrlf & "{79A241C1-CD45-406E-8216-34AF14C15290}"
    call sys_WriteActivityLog(3,"79A241C1-CD45-406E-8216-34AF14C15290","Create recordset error." & vbcrlf & strSQL & vbcrlf & err.description)
    Response.end
end if

'如果找不到任何資料，傳回 NONE
if rst1.RecordCount = 0 then
    Response.Write "NONE"
    Response.End
end if

'**************************************************************************************************
'**************************************************************************************************
'根據傳入的指令來進行資料的擷取，傳回指定的Record資料
dim intCurrentPosition, strPrevRecord, strNextRecord
dim intScope
intScope = 50

select case strCommand
    case "FIRST"
        rst1.MoveFirst
        strKey = rst1("##PKEY_#").value    '紀錄目前的 Key 值
        intCurrentPosition = 1              '紀錄目前的 Position

        '找出往後 intScope 筆數的 Key 值
        strPrevRecord= "<Prev></Prev>" & vbcrlf
        strNextRecord= "<Next>" & vbcrlf
        for i = 1 to intScope
            rst1.MoveNext
            if rst1.EOF then
                exit for
            end if
            strNextRecord= strNextRecord & "<Key>" & sys_XMLEncode(rst1("##PKEY_#").value) & "</Key>" & vbcrlf
        next
        strNextRecord= strNextRecord & "</Next>" & vbcrlf

    case "LAST"
        rst1.MoveLast
        strKey = rst1("##PKEY_#").value        '紀錄目前的 Key 值
        intCurrentPosition = rst1.RecordCount   '紀錄目前的 Position

        '找出往前 intScope 筆數的 Key 值
        strNextRecord= "<Next></Next>" & vbcrlf
        strPrevRecord= "<Prev>" & vbcrlf
        for i = 1 to intScope
            rst1.MovePrevious
            if rst1.BOF then
                exit for
            end if
            strPrevRecord= strPrevRecord & "<Key>" & sys_XMLEncode(rst1("##PKEY_#").value) & "</Key>" & vbcrlf
        next
        strPrevRecord= strPrevRecord & "</Prev>" & vbcrlf

    case else

        rst1.Find "##PKEY_# = '" & strKey & "'"
        if rst1.EOF then
            Response.Write "NONE"
            Response.End
        end if

        intCurrentPosition = rst1.AbsolutePosition  '紀錄目前的 Position

        '找出往前 intScope 筆數的 Key 值
        strPrevRecord= "<Prev>" & vbcrlf
        for i = 1 to intScope
            rst1.MovePrevious
            if rst1.BOF then
                exit for
            end if
            strPrevRecord= strPrevRecord & "<Key>" & sys_XMLEncode(rst1("##PKEY_#").value) & "</Key>" & vbcrlf
        next
        strPrevRecord= strPrevRecord & "</Prev>" & vbcrlf

        '移回原來的紀錄位置
        rst1.AbsolutePosition = intCurrentPosition

        '找出往後 intScope 筆數的 Key 值
        strNextRecord= "<Next>" & vbcrlf
        for i = 1 to intScope
            rst1.MoveNext
            if rst1.EOF then
                exit for
            end if
            strNextRecord= strNextRecord & "<Key>" & sys_XMLEncode(rst1("##PKEY_#").value) & "</Key>" & vbcrlf
        next
        strNextRecord= strNextRecord & "</Next>" & vbcrlf
end select

if err.number <> 0 then
    Response.write err.description & vbcrlf & "{EDAFB8A4-B903-423D-8DBB-09D1B31E8BB7}"
    call sys_WriteActivityLog(3,"EDAFB8A4-B903-423D-8DBB-09D1B31E8BB7","Error occur when move to specify record." & vbcrlf & err.description)
    Response.End
end if

'**************************************************************************************************
'**************************************************************************************************
dim strXML

'讀取要修改的那一筆
strSQL = "SELECT * " & _
         "FROM fn_Data_##Template_#('" & Session("s_Language") & "') " & _
         "WHERE ##PKEY_# = N'" & strKey & "'"

strXML = objPublic.CreateRecordsetXML(strSQL,Application("a_CRMConnect"))
if err.number <> 0 then
    Response.write err.description & vbcrlf & "{625A074D-606E-41CD-B006-9DA4150290DF}"
    call sys_WriteActivityLog(3,"625A074D-606E-41CD-B006-9DA4150290DF","Error occur when call objPublic.CreateRecordsetXML()." & vbcrlf & err.description)
    Response.End
end if

'將找到的XML資料讀到 xmlDoc 之中
dim xmlDoc, objNode
set xmlDoc = Server.CreateObject("Microsoft.XMLDOM")
xmlDoc.async = false
xmlDoc.loadXML strXML

set objNode= xmlDoc.documentElement
'紀錄資料總筆數
objNode.selectSingleNode("@RecordCount").text= rst1.RecordCount
'紀錄目前位置
objNode.selectSingleNode("/Recordset/Record/@AbsolutePosition").text= intCurrentPosition

dim xmlDocTemp, objNodeTemp
set xmlDocTemp = Server.CreateObject("Microsoft.XMLDOM")
xmlDocTemp.async = false

'將Previous位置指標的XML加到xmlDoc之中
xmlDocTemp.loadXML strPrevRecord
set objNodeTemp = xmlDocTemp.documentElement
objNode.appendChild(objNodeTemp)

'將Next位置指標的XML加到xmlDoc之中
xmlDocTemp.loadXML strNextRecord
set objNodeTemp = xmlDocTemp.documentElement
objNode.appendChild(objNodeTemp)

if err.number <> 0 then
    Response.write err.description & vbcrlf & "{591B9F27-048C-4368-9EC2-7D11EB72889B}"
    call sys_WriteActivityLog(3,"591B9F27-048C-4368-9EC2-7D11EB72889B","Error occur when bulild XML document for record." & vbcrlf & err.description)
    Response.End
end if

'輸出 XML
Response.Write objNode.xml
%>
