<%@Language=Vbscript CodePage=65001%>
<%
Option Explicit
Response.Buffer=true
Response.Expires=-1
Session.codepage=65001
Response.CacheControl = "no-cache"
%>
<%'**** Server-Side 系統標準公用函數 %>
<!--#include virtual='/GDCRM/library/sys_SystemCheck_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_Escape_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetProgramPermission_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetProgramDescription_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetProgramIconUrl_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_CheckProgramPermission_S.asp' -->
<%
'*******************************************************************
'定義程式參數
'*******************************************************************
dim strProgID
strProgID = "##Template_#"

'*******************************************************************
'定義系統相關變數
'*******************************************************************
dim aryPerm, strProgDescription, strErrMsg, i
'讀取程式名稱
strProgDescription = "(" & strProgID & ") " & sys_GetProgramDescription(strProgID,Session("s_Language"))

'*******************************************************************
'程式權限檢查
'*******************************************************************
'讀取使用者對於本程式的使用權限
aryPerm = sys_GetProgramPermission(strProgID,Session("s_EmplID"))

'程式權限檢查 0=ExecPerm 1=AddPerm 2=ModifyPerm 3=DelPerm 4=PrintPerm 5=Ext1Perm 6=Ext2Perm 7=Ext3Perm 8=DataOwnerType
if IsArray(aryPerm) = false then
    call sys_WriteActivityLog(2,"B3AFE355-D9D9-4311-8192-48F5BE3E6DDD","Can not found program permission definition of user.")
    strErrMsg = objKey.ReadResString("CAN_NOT_FIND_USERS_PERMISSION",Session("s_Language"),Session("s_EmplID"),strProgID)
    call sys_ShowErrorHtml(strErrMsg,strProgDescription,"")
end if

'如果是PowerUser，則擁有所有的權限
if Session("s_PowerUser") = true then
    redim aryPerm(8): for i = 0 to 7 : aryPerm(i)=true :next :aryPerm(8)=9
end if

'必須有新增的權限才可以執行
if aryPerm(1) = false then
    call sys_WriteActivityLog(2,"43DB50E5-5CA0-48EC-AA19-5EAB822A85B1","User doesn't has permission to add data.")
    strErrMsg = objKey.ReadResString("NO_ADD_PERMISSION",Session("s_Language"))
    call sys_ShowErrorHtml(strErrMsg,strProgDescription,"")
end if

'*****************************************************************
dim strReadOnlyTAG,  strReadOnlyTAG2, strReadOnlyClass, strHideButton
dim strKeyField,  strNotEmptyField

if aryPerm(2) = true then
    '使用者具有修改的權限
    strReadOnlyTAG = ""
    strReadOnlyTAG2 = ""
    strReadOnlyClass = "clsEditField"
    strKeyField = "<font color='darkblue'>#</font>"
    strNotEmptyField = "<font color='red'>*</font>"
    strHideButton = ""
else
    '使用者僅能檢視資料
    strReadOnlyTAG = " readonly "
    strReadOnlyTAG2 = " disabled=true "
    strReadOnlyClass = "clsLockField"
    strKeyField = ""
    strNotEmptyField = ""
    strHideButton = " style='display:none' "
end If
'*****************************************************************
%>

<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
<meta http-equiv='Content-Language' content='<%=Session("s_Content")%>'>
<link rel='stylesheet' type='text/css' href='/GDCRM/css/default.css'>
<!--#include virtual='/GDCRM/library/sys_SingleFormParameter_C.asp'-->
<!--#include virtual='/GDCRM/library/sys_Msg_Modify_C.asp'-->

<script language='jscript.encode'>
var g_msgLoading = "<%=objKey.ReadResString("LOADING",Session("s_Language"))%>...";
var g_msgChecking = "<%=objKey.ReadResString("CHECKING",Session("s_Language"))%>...";
var g_msgConfirmToSaveModify = "<%=objKey.ReadResString("CONFIRM_TO_SAVE_MODIFY",Session("s_Language"))%>\n";
var g_msgModifyConfirm = "<%=objKey.ReadResString("MODIFY_CONFIRM",Session("s_Language"))%>";
var g_msgErrorReason = "<%=objKey.ReadResString("ERROR_REASON",Session("s_Language"))%>";
var g_msgCanNotBlank = "<%=objKey.ReadResString("CAN_NOT_BLANK",Session("s_Language"))%>";
var g_msgSorryAsyncCallNotComplete = "<%=objKey.ReadResString("SORRY_ASYNC_CALL_NOT_COMPLETE",Session("s_Language"))%>";
var g_msgSaveDataSucceed = "<%=objKey.ReadResString("SAVE_DATA_SUCCEED",Session("s_Language"))%>";
var g_msgErrorOccurWhenSaveData = "<%=objKey.ReadResString("ERROR_OCCUR_WHEN_SAVE_DATA",Session("s_Language"))%>";
var g_msgMaxLengthChar = "<%=objKey.ReadResString("MAX_LENGTH_CHAR",Session("s_Language"),"<var1>","<var2>")%>";
var g_msgDataWasModifiedButNotSave = "<%=objKey.ReadResString("DATA_WAS_MODIFIED_BUT_NOT_SAVE",Session("s_Language"))%>";
</script>

<!-- Client-Side系統公用函數-->
<script language='jscript.encode' src='/GDCRM/library/sys_XMLEncode_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_ArrayToXML_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_Trim_C.js'></script>
<script language='vbscript.encode' src='/GDCRM/library/sys_MsgBox_C.vbs'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_ShowWaiting_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_GetAyncCallerID_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_CommonNewFunction_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_IsInteger_C.js'></script>
<!--#include virtual='/GDCRM/Library/sys_DateTime_Const.asp' -->
<script language='jscript.encode'  src='/GDCRM/Library/sys_DateTime_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_ChoiceDate_C.js'></script>

<!-- 載入開窗查詢公用函數及Message-->
<script language='jscript.encode'>
    // 開窗程式使用的Message
    //*** For Employee
    var g_msgEmployeeID = "<%=objKey.ReadResString("EMP_EMPL_ID",Session("s_Language"))%>";
    var g_msgMustBeExistEmployeeId = "<%=objKey.ReadResString("MUST_BE_EXIST_EMPLOYEE_ID",Session("s_Language"))%>"
</script>

<!-- 載入開窗查詢公用函數-->
<script language='jscript.encode' src='/GDCRM/library/sys_ChoiceEmployee_C.js'>//** Employee </script>

<!-- Start of 程式Global變數設定-->
<script language='jscript.encode'>
//標準的Global變數定義
var g_blnDebug = <%=lcase(Session("s_DebugMode"))%>;
var g_aryPerm = new Array(<%=lcase(aryPerm(0))%>,<%=lcase(aryPerm(1))%>,<%=lcase(aryPerm(2))%>,<%=lcase(aryPerm(3))%>,<%=lcase(aryPerm(4))%>,<%=lcase(aryPerm(5))%>,<%=lcase(aryPerm(6))%>,<%=lcase(aryPerm(7))%>,<%=aryPerm(8)%>);
var g_strProgID = sys_XMLEncode("<%=strProgID%>");
var g_blnChangeRemind = <%=lcase(Session("s_ChangeRemind"))%>;
var g_Language = "<%=Session("s_Language")%>";
var g_xmlDoc;
var g_blnChanged = false;
var g_aryHttpCaller = new Array();
</script>
<!-- End of 程式Global變數設定-->

<Script Language='jscript.encode'>
function LoadInit() {
}

function Init() {               //初始化
    window.defaultStatus = "<%=strProgDescription%>";
    top.document.title = "<%=strProgDescription%>";
    document.all["nv_Save"].style.color = "silver";
    document.all["nv_Save"].style.cursor = "default";
	
    //Setting default focus field.
    document.all['##PKEY_#'].focus();

    //	document.all['Valid'].value = "Y";

    //Setting change remind flag
    g_blnChanged= false;
    document.all["blkProgTitle"].style.color = "white"
}

function Exit() {               //離開
    try {
        frmParameter.action = g_strProgID + ".asp";
        frmParameter.submit();
    } catch (e) {}
}

function BeforeUnload() {
    if (g_blnChanged == true && g_blnChangeRemind==true) {
        window.event.returnValue = g_msgDataWasModifiedButNotSave;
    }
}

function ShowHelp() {           //說明
    window.open("<%=Session("s_HelpURL")%>help_"+g_strProgID+".asp");
}

function AfterSave() {
    alert("<%=objKey.ReadResString("SAVE_DATA_SUCCEED",Session("s_Language"))%>");
    document.all["blkProgTitle"].style.color = "white";
    g_blnChanged = false;
    ClearField();
    //Setting default focus field.
    document.all['##PKEY_#'].focus();
}

function IsActive_onclick() {
    if (document.all['IsActive'].checked)
        document.all['IsActive'].value = 1;
    else
        document.all['IsActive'].value = 0;
}

</script>
<!--#include virtual='/GDCRM/Prog/##Location_#/Script_SaveNew.asp'-->
</head>
<body onload='LoadInit();Init();' onbeforeunload='BeforeUnload();' onkeydown='sys_KeyDown_New();' language='Jscript'>
<div class='clsProgTitle' id='blkProgTitle'><nobr>
    <img class='clsIcon16' src='<%=sys_GetProgramIconUrl(strProgID)%>' align='absmiddle' hspace=5>
    <%=strProgDescription%></nobr>
</div>
<!--#include virtual='/GDCRM/Prog/##Location_#/Toolbar_New.asp' -->
<!--#include virtual='/GDCRM/Prog/##Location_#/##Template_#_New_Layout.asp' -->
</body>
</html>
