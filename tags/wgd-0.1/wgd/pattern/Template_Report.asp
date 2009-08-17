<%@Language=Vbscript CodePage=65001%>
<%
Option Explicit
Response.Buffer=true
Response.Expires=-1
Session.codepage=65001
Response.AddHeader "Content-Type","text/html; charset=utf-8"
%>
<!--#include virtual='/GDCRM/library/sys_SystemCheck_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_Escape_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetProgramPermission_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetProgramDescription_S.asp' -->

<!--#include virtual='/GDCRM/library/sys_ReportResult_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_DateTimeFunction_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_UpdateReportData_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_VarReplace_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetReportName_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetTemplateName_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetReportDataFormat_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_CreateReportLabels_S.asp' -->
<!--#include virtual='/GDCRM/Prog/Sales/Sales_PrintData.asp' -->

<%
ON ERROR RESUME NEXT
dim strProgID, strProgDescription, aryPerm, strKey, strErrMsg, i
strProgID = "Sales"

'讀取程式名稱
strProgDescription = "(" & strProgID & ") " & sys_GetProgramDescription(strProgID,Session("s_Language"))

'讀取使用者對於本程式的使用權限
aryPerm = sys_GetProgramPermission(strProgID,Session("s_EmplID"))

'程式權限檢查 0=ExecPerm 1=AddPerm 2=ModifyPerm 3=DelPerm 4=PrintPerm 5=Ext1Perm 6=Ext2Perm 7=Ext3Perm 8=DataOwnerType
if IsArray(aryPerm) = false then
    call sys_WriteActivityLog(2,"B3AFE355-D9D9-4311-8192-48F5BE3E6DDD","Can not found program permission definition of user.")
    strErrMsg = objKey.ReadResString("CAN_NOT_FIND_USERS_PERMISSION",Session("s_Language"),Session("s_EmplID"),strProgID)
    call sys_ShowErrorHtml(strErrMsg,strProgDescription,"close")
end if

'如果是PowerUser，則擁有所有的權限
if Session("s_PowerUser") = true then
    redim aryPerm(8): for i = 0 to 7 : aryPerm(i)=true :next :aryPerm(8)=9
end if

'必須有列印的權限才可以執行
if aryPerm(4) = false then
    call sys_WriteActivityLog(2,"F8E8FF90-296F-46FF-A3B1-B46730957224","User doesn't has permission to print data.")
    strErrMsg = objKey.ReadResString("NO_PRINT_PERMISSION",Session("s_Language"))
    call sys_ShowErrorHtml(strErrMsg,strProgDescription,"close")
end if

if err.number <> 0 then
    Response.Write err.description & "<br>CEA5A136-0C49-453D-A7E2-6D695594C4B7"
    Response.End
end if

'*******************************************************************
'接收報表的參數設定
'*******************************************************************
%>
<!--#include virtual='/GDCRM/Library/sys_ReportParameter_S.asp' -->
<%
dim strXML      '*** 報表資料的XML
dim lngJobID    '*** Print Job的代號
dim lngScheduleID '*** Schedule Job的代號

if strSchedule = "Y" then
    lngScheduleID = sys_AddNewScheduleReport()
    if err.number <> 0 then
        Response.Write err.description & "<br>CD05A371-144F-47D9-AEF0-D2FDFEB0AD52"
        Response.End
    end if

    call sys_ScheduleReportResult(lngScheduleID)
else
    '產生報表XML
    strXML = Sales_PrintData()

    if err.number <> 0 then
        Response.Write err.description & "<br>5EE88DCE-F792-4EA6-B270-0FA9F1F48EDA"
        Response.End
    end if
    '******************************************************************************************
    lngJobID = sys_UpdateReportData()

    if err.number <> 0 then
        Response.Write err.description & "<br>48D04E75-262B-4548-9133-95C1955DFCFE"
        Response.End
    end if

    '顯示結果的畫面
    call sys_ReportResult(lngJobID)
end if
%>
