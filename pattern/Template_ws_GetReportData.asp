<%@Language=Vbscript CodePage=65001%>
<%
Option Explicit
Response.Buffer=true
Response.Expires=-1
Session.codepage=65001
%>
<!--#include virtual='/GDCRM/library/sys_SystemCheck_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_Escape_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetProgramPermission_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetProgramDescription_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_DateTimeFunction_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_VarReplace_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetReportName_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetTemplateName_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetReportDataFormat_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_CreateReportLabels_S.asp' -->
<!--#include virtual='/GDCRM/Prog/Sales/Sales_PrintData.asp' -->
<%
ON ERROR RESUME NEXT
'產生報表XML
dim strProgID
strProgID = "Sales"
'*** 在 Sales_PrintData() 函數中，會執行權限檢查

dim intPageSize, intStartPage,intEndPage, strWhereClause, strOrderByClause, strFilterClause
dim strLanguage, strReportID, strTemplateID
dim intTimezoneID,intOldTimezoneID,strOldTimezoneName,intOldTimezoneOffset,intOldTimezoneDST,strOldTimezoneDSTperiod
dim xmlDoc, strXML

set xmlDoc = Server.CreateObject("Microsoft.XMLDOM")
xmlDoc.Load Request

if err.number <> 0 then
    Response.Write "(" & strProgID & ") Load XMLData Error (1)<br>" & err.Description
end if

If xmlDoc.parseError.errorCode <> 0 Then
    Response.Write "(" & strProgID & ") Load XMLData Error (2)<br>" & xmlData.parseError.reason
end if

dim objRoot
set objRoot = xmlDoc.documentElement.selectSingleNode("/Data")

intPageSize = cint(objRoot.selectSingleNode("PageSize").text)
intStartPage = cint(objRoot.selectSingleNode("StartPage").text)
intEndPage = cint(objRoot.selectSingleNode("EndPage").text)
strWhereClause = objRoot.selectSingleNode("WhereClause").text
strFilterClause = objRoot.selectSingleNode("FilterClause").text
strOrderByClause = objRoot.selectSingleNode("OrderClause").text
strLanguage = objRoot.selectSingleNode("Language").text
strReportID = objRoot.selectSingleNode("ReportID").text
strTemplateID = objRoot.selectSingleNode("TemplateID").text
intTimezoneID = cint(objRoot.selectSingleNode("TimezoneID").text)

Call sys_StoreOldTimezoneSetting()
Call sys_ChangeCurrentTimezoeSetting(intTimezoneID,strLanguage)
strXML = Sales_PrintData()
Call sys_RestroreTimezoneSetting()

if err.number <> 0 then
    Response.Write err.description
else
    Response.Write strXML
end if
%>
