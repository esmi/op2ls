

#### base function
key_count() {
    local count=0
    for key_fd in `echo $MULTY_KEY | sed 's/,/ /g'` ; do
        count="`expr $count + 1`"
    done
    echo $count
}
key_name() {
    echo $1 | gawk -F , "{ print \$$2}"
}

template_modify_header() {
cat <<-EOF
<%@Language=Vbscript CodePage=65001%>
<%
Option Explicit
Response.Buffer=true
Response.Expires=-1
Session.codepage=65001
%>
<%'**** Server-Side 系統標準公用函數 %>
<!--#include virtual='/GDCRM/library/sys_SystemCheck_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_Escape_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetProgramPermission_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetProgramDescription_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GetProgramIconUrl_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_GenStatusBarModify_S.asp' -->
<!--#include virtual='/GDCRM/library/sys_CheckProgramPermission_S.asp' -->

<%
'*******************************************************************
'定義程式參數
'*******************************************************************
dim strProgID
dim strDefaultQueryField
dim strDefaultQueryOperator
dim strWhereClause
dim strOrderByClause
dim strFilterClause
dim lngViewID
dim strLayoutViewDetail
dim intPage
dim strKey

'**** 讀取傳入的系統相關參數
strProgID = "${TEMPLATE}"
strDefaultQueryField = trim(Request("gd_DF"))
strDefaultQueryOperator = trim(Request("gd_DO"))
strWhereClause = trim(Request("gd_W"))
strOrderByClause = trim(Request("gd_O"))
strFilterClause = trim(Request("gd_FI"))
lngViewID = trim(Request("gd_V"))
strLayoutViewDetail = trim(Request("gd_VD"))
if isnumeric(Request("gd_P")) = true then
    intPage = cint(Request("gd_P"))
else
    intPage = 1
end if

strKey= Trim(Request("gd_Key")) & ""

'*******************************************************************
'定義系統相關變數
'*******************************************************************
dim aryPerm, strProgDescription, strErrMsg, i
'讀取程式名稱
strProgDescription = "(" & strProgID & ") " & sys_GetProgramDescription(strProgID,Session("s_Language"))

'*******************************************************************
'定義附件資料表名稱
'*******************************************************************
dim strAttachTableName
strAttachTableName = "${TEMPLATE}"

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

'至少必須有執行的權限，如果沒有修改的權限，自動會從[修改模式]轉換為[檢視模式]
if aryPerm(0) = false then
    call sys_WriteActivityLog(2,"0245DC22-6D78-4533-B495-BD627AE71B96","User doesn't has permission to execute program.")
    strErrMsg = objKey.ReadResString("NO_EXECUTE_PERMISSION",Session("s_Language"))
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
end if
'************************************************************************************************
%>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
<meta http-equiv='Content-Language' content='<%=Session("s_Content")%>'>
<link rel='stylesheet' type='text/css' href='/GDCRM/css/default.css'>
<!--#include virtual='/GDCRM/library/sys_SingleFormParameter_C.asp'-->
<!--#include virtual='/GDCRM/library/sys_Msg_Modify_C.asp'-->
<!--#include virtual='/GDCRM/library/sys_MultiLanguageConst_C.asp'-->

<!-- Client-Side系統公用函數-->
<script language='jscript.encode' src='/GDCRM/library/sys_XMLEncode_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_ArrayToXML_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_Trim_C.js'></script>
<script language='vbscript.encode' src='/GDCRM/library/sys_MsgBox_C.vbs'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_ShowWaiting_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_GetAyncCallerID_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_CommonModifyFunction_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_KeyDown_Modify_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_SwitchMultiLangField_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_CopyMultiLanguageField_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_ShowAttachment_C.js'></script>

<!-- Start of 程式Global變數設定-->
<script language='jscript.encode'>
//標準的Global變數定義
var g_blnDebug = <%=lcase(Session("s_DebugMode"))%>;
var g_aryPerm = new Array(<%=lcase(aryPerm(0))%>,<%=lcase(aryPerm(1))%>,<%=lcase(aryPerm(2))%>,<%=lcase(aryPerm(3))%>,<%=lcase(aryPerm(4))%>,<%=lcase(aryPerm(5))%>,<%=lcase(aryPerm(6))%>,<%=lcase(aryPerm(7))%>,<%=aryPerm(8)%>);
var g_strProgID = sys_XMLEncode("<%=strProgID%>");
var g_blnChangeRemind = <%=lcase(Session("s_ChangeRemind"))%>;
var g_Language = "<%=Session("s_Language")%>";
var g_xmlDoc;
var g_intPosition;
var g_blnChanged = false;
var g_aryHttpCaller = new Array();
var g_intMaxReocrd = <%=Session("s_MaxRecord")%>;
var g_strDataSourceURL = "ws_" + g_strProgID + "_ModifyData.asp";

</script>
<!-- End of 程式Global變數設定-->

<Script Language='jscript.encode'>
function LoadInit() {
    
}

function Init() {               //初始化
    window.defaultStatus = "<%=strProgDescription%>";
    top.document.title = "<%=strProgDescription%>";
    if (g_aryPerm[2] == true) {
        document.all['nv_Save'].style.color = "silver";
        document.all['nv_Save'].style.cursor = "default";
    }
    //Normal initial section
    document.all['gd_Cmd'].value= "MODIFY"
    sys_GetData();
}

function BeforeLoadData() {
}

function AddNew() {             //新增
    document.frmParameter.action = g_strProgID + "_New.asp";
    document.frmParameter.submit();
}

function Delete() {             //刪除
    var strKey = document.all['gd_Key'].value;
    var strComfirmMsg = "<%=objKey.ReadResString("CONFIRM_TO_DELETE_DATA",Session("s_Language"))%>";

    //alert( "xxx" + strKey);
    //Confirm to delete
    if (sys_MsgBox(strComfirmMsg,32+4+256,"<%=objKey.ReadResString("DELETE_CONFIRM",Session("s_Language"))%>") != 6) {
        return;
    }
    sys_Delete_Modify(strKey);
}

function AfterDelete() {
    //You can add your code in here after delete data.
}

function FirstRecord() {        //第一筆
    if (g_intPosition == 1) {return;}
    if (sys_ChangeRemind() == true) {
        document.all['gd_Cmd'].value = "FIRST";
        sys_GetData();
    }
}

function PreviousRecord() {     //上一筆
    if (g_intPosition == 1) {return;}
    if (sys_ChangeRemind() == true) {
        document.all['gd_Cmd'].value = "PREVIOUS";
        document.all['gd_Key'].value = g_xmlDoc.documentElement.selectSingleNode("/Recordset/Prev").childNodes.item(0).text;
        sys_GetData();
    }
}

function JumpRecord() {         //跳到某一筆
    if (sys_ChangeRemind() == true) {
        document.all['gd_Cmd'].value = "JUMP";
        document.all['gd_Key'].value = document.all['cboJumpRecord'].value;
        sys_GetData();
    }
}

function NextRecord() {         //下一筆
    if (g_intPosition == g_xmlDoc.documentElement.selectSingleNode("@RecordCount").text) {return;}
    if (sys_ChangeRemind() == true) {
        document.all['gd_Cmd'].value = "NEXT";
        document.all['gd_Key'].value = g_xmlDoc.documentElement.selectSingleNode("/Recordset/Next").childNodes.item(0).text;
        sys_GetData();
    }
}

function LastRecord() {         //最後一筆
    if (g_intPosition == g_xmlDoc.documentElement.selectSingleNode("@RecordCount").text) {return;}
    if (sys_ChangeRemind() == true) {
        document.all['gd_Cmd'].value = "LAST";
        sys_GetData();
    }
}

function Refresh() {            //重新整理
    if (sys_ChangeRemind() == true) {
        Init();
    }
}

function Exit() {         //離開
    try {
        frmParameter.action = g_strProgID + ".asp";
        frmParameter.submit();
    }
    catch (e) {
        //Do nothing
    }
}
function ShowAttach() {
    sys_ShowAttachment("${TEMPLATE}",g_strProgID);
}

function SearchAttach() {
    sys_SearchAttachment("${TEMPLATE}");
}

function BeforeUnload() {
    if (g_blnChanged == true && g_blnChangeRemind==true) {
        window.event.returnValue = g_msgDataWasModifiedButNotSave;
    }
}

function ShowHelp() {           //說明
    window.open("<%=Session("s_HelpURL")%>help_"+g_strProgID+".asp");
}


// 顯示取得的資料
function ShowData() {
    var strNodeName,strTemp;
    var objNode= g_xmlDoc.documentElement.selectSingleNode("/Recordset/Record");

    for (var i=0; i < objNode.childNodes.length; i++) {
        strNodeName = objNode.childNodes.item(i).nodeName;
        //依據各欄位不同，進行特殊的調整
        switch (strNodeName) {
            default:
                if (typeof(document.all[strNodeName]) != "undefined") {
                    document.all[strNodeName].value = objNode.childNodes.item(i).text;
                }
        }
    }
    g_intPosition= g_xmlDoc.documentElement.selectSingleNode("/Recordset/Record/@AbsolutePosition").text;
    document.all['totalRecordCount'].innerText= g_xmlDoc.documentElement.selectSingleNode("/Recordset/@RecordCount").text;
    document.all['currentPosition'].innerText= g_intPosition;
    if (g_intPosition == 1) {
        sys_SwitchNavigator(1);
    }
    else {
        if (g_intPosition == parseInt(g_xmlDoc.documentElement.selectSingleNode("/Recordset/@RecordCount").text,10)) {
            sys_SwitchNavigator(2);
        }
        else {
            sys_SwitchNavigator(0);
        }
    }
    sys_CreateJumpRecord();
 AfterLoadData();
}
EOF
}


#### AfterLoadData()
_multy_key_split2() {
    local lastkey="`key_name $MULTY_KEY $KEY_COUNT`"

    for fd in `echo $MULTY_KEY | sed 's/,/ /g'` ; do
	tailer="+ \"' AND \" + "
	if [ $fd = $lastkey ] ; then 
	    tailer="+ \"'\" ;"
	fi
	echo -e "\\t\\t\"$fd=N'\" + escape(document.all['"$fd"'].value) " $tailer
    done
}
_multy_key_split1() {
   
    local lastkey="`key_name $MULTY_KEY $KEY_COUNT`"

    for fd in `echo $MULTY_KEY | sed 's/,/ /g'` ; do
	tailer="+ \",\" +"
	if [ $fd = $lastkey ] ; then 
	    tailer=";"
	fi
	echo  "document.all['"$fd"'].value " $tailer
    done
    
}

_after_load_data_setting_key(){

if [ "$KEY_TYPE". = "MULTY_KEY". ] ; then
    _multy_key_split1 $MULTY_KEY 
else
    echo "document.all['##PKEY_#'].value;"
fi
}
after_load_data() {
cat <<-EOF
function AfterLoadData() {
    //Update Attachment Icon
    sys_ChangeAttachToolIcon();
    //sys_SwitchTab(g_intCurrentTab);
    //Setting key filed value
    document.all['gd_Key'].value = 
    $(_after_load_data_setting_key | sed 's/^/\t\t/g') 

    //Setting default focus field.
    //document.all['DeptId'].focus();
    //Setting change remind flag
    g_blnChanged= false;
    document.all["blkProgTitle"].style.color = "white"
EOF

if [ "$PRG_TYPE". = "DBL". ] ; then
cat <<-EOF
    //Related table. ref: Template_Modify_Layout
    document.all.${RELATED_TABLE}_Data.src = "/GDCRM/Prog/${RELATED_TABLE}/${RELATED_TABLE}.asp?gd_FI=" +
    `_multy_key_split2 $MULTY_KEY`
EOF
fi
if [ "$IS_IMPORT". = "TRUE". ] ; then
cat <<-EOF
    if ( document.all['cnt'].value != 0   ) { 
        document.all['act_import'].disabled=true;
    }
}
EOF
fi
}

## ImportData
import_data() {
if [ "$IS_IMPORT". = "TRUE". ] ; then
cat <<-EOF
function ImportData() {
    if ( document.all['act_import'].disabled ) { 
        alert("Data has been imported; Action disabled"); 
    }
    else {
    
        var strURL = "ws_ImportData.asp?gd_Key=" + escape(document.all['gd_Key'].value);
        var xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
        xmlHttp.open("GET", strURL, false);
        xmlHttp.send();
        var strXML=xmlHttp.responseText;

        if (strXML == 'OK') {
            document.all['act_import'].disabled=true;
            Refresh();
        }
        else {
            alert(strXML);
        }
    }
} 
EOF
fi
}

template_modify_tailer() {
cat <<-EOF
</Script>
<!--#include virtual='/GDCRM/Prog/${TEMPLATE}/Script_SaveModify.asp'-->

</head>
<body onload='LoadInit();Init();' onbeforeunload='BeforeUnload();' onkeydown='sys_KeyDown_Modify();' language='Jscript'>
<div class='clsProgTitle' id='blkProgTitle'><nobr>
    <img class='clsIcon16' src='<%=sys_GetProgramIconUrl(strProgID)%>' align='absmiddle' hspace=5
    onmousedown='sys_ClearDataModifiedFlag();'>
    <%=strProgDescription%></nobr>
</div>
<!--#include virtual='/GDCRM/Prog/${TEMPLATE}/Toolbar_Modify.asp' -->
<!--#include virtual='/GDCRM/Prog/${TEMPLATE}/${TEMPLATE}_Modify_Layout.asp' -->
<p>
<div style='margin:5px;color:#0f5900'><%=sys_GenStatusBarModify()%></div>
EOF
if [ "$IS_ATTACH". = "TRUE". ] ; then
    echo "<input id='AttachID' type='hidden'>"
fi
cat <<-EOF
<p>
</body>
</html>
EOF
}
TEMPLATE=HSImport
PRG_TYPE=DBL

IS_ATTACH=TRUE
IS_IMPORT=TRUE

RELATED_TABLE="MsgCustoms"
KEY_TYPE="MULTY_KEY"
MULTY_KEY="DeptId,PeriodId,WhrsId"
KEY_COUNT="`key_count`"

echo $KEY_COUNT

#for i in $(seq 1 $KEY_COUNT) ; do
#    key_name $MULTY_KEY $i
#done

template_modify() {
template_modify_header
after_load_data
import_data
template_modify_tailer
}

#template_modify
