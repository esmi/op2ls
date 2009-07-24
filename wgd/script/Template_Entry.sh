

## Template_Entry...程式.

template_entry_header() {
cat <<-EOF
<%@Language=Vbscript CodePage=65001%>
<%
Option Explicit
Response.Buffer=true
Response.Expires=-1
Session.codepage=65001
%>
<%'**** Server-Side 系統標準公用函數 %>
<!--#include virtual='/GDCRM/library/sys_SystemCheck_S.asp'            ** 系統狀態檢查公用函數 -->
<!--#include virtual='/GDCRM/library/sys_Escape_S.asp'                 ** 傳回以 %uuuu 編碼後的字串 -->
<!--#include virtual='/GDCRM/library/sys_GetProgramPermission_S.asp'   ** 傳回程式的權限陣列 -->
<!--#include virtual='/GDCRM/library/sys_GetProgramDescription_S.asp'  ** 傳回程式名稱字串 -->
<!--#include virtual='/GDCRM/library/sys_GetProgramIconUrl_S.asp'      ** 傳回程式16x16的Icon URL -->

<%'**** Server-Side 系統特殊公用函數 %>

<%
'********************************************************************************************************************
'定義程式共用參數
'********************************************************************************************************************
dim strProgID                   '程式代號
dim strDefaultQueryField        '預設查詢欄位名稱
dim strDefaultQueryOperator     '預設查詢動作
dim strWhereClause              '資料 SQL 查詢的 Where 子句
dim strOrderByClause            '資料 SQL 查詢的 Order By 子句
dim strFilterClause             '資料 SQL 查詢的限制子句，會結合到 Where 子句中
dim lngViewID                   '預設顯示的 LayoutViewID
dim strLayoutViewDetail         'LayoutView 的XML內容
dim intPage                     '指定要顯示的資料頁數

strProgID = "##Template_#"
'預設查詢欄位名稱如果為多語言欄位時，請使用如下的寫法：
'strDefaultQueryField = "XXXXXX" & Session("s_Language")
strDefaultQueryField = "##PKEY_#"
strDefaultQueryOperator = "like"
strWhereClause = trim(Request("gd_W"))
strOrderByClause = trim(Request("gd_O"))
strFilterClause = trim(Request("gd_FI"))
lngViewID = trim(Request("gd_V"))
strLayoutViewDetail = trim(Request("gd_VD"))
'當未指定要顯示的頁數時，預設為第1頁
if isnumeric(Request("gd_P")) = true then
    intPage = cint(Request("gd_P"))
else
    intPage = 1
end if

'********************************************************************************************************************
'定義系統相關變數
'********************************************************************************************************************
dim aryPerm, strKey, strProgDescription, strErrMsg, i
'讀取程式名稱
strProgDescription = "(" & strProgID & ") " & sys_GetProgramDescription(strProgID,Session("s_Language"))

'********************************************************************************************************************
'程式權限檢查
'********************************************************************************************************************
aryPerm = sys_GetProgramPermission(strProgID,Session("s_EmplID"))

'如果是PowerUser，則擁有所有的權限
if Session("s_PowerUser") = true then
    redim aryPerm(8): for i = 0 to 7 : aryPerm(i)=true :next :aryPerm(8)=9
end if

'程式權限檢查 0=ExecPerm 1=AddPerm 2=ModifyPerm 3=DelPerm 4=PrintPerm 5=Ext1Perm 6=Ext2Perm 7=Ext3Perm 8=DataOwnerType
if IsArray(aryPerm) = false then
    call sys_WriteActivityLog(2,"B3AFE355-D9D9-4311-8192-48F5BE3E6DDD","Can not found program permission definition of user.")
    strErrMsg = objKey.ReadResString("CAN_NOT_FIND_USERS_PERMISSION",Session("s_Language"),Session("s_EmplID"),strProgID)
    call sys_ShowErrorHtml(strErrMsg,strProgDescription,"")
end if

'********************************************************************************************************************
'檢查使用者是否有執行的權限
'********************************************************************************************************************
if aryPerm(0) = false then
    call sys_WriteActivityLog(2,"0245DC22-6D78-4533-B495-BD627AE71B96","User doesn't has permission to execute program.")
    strErrMsg = objKey.ReadResString("NO_EXECUTE_PERMISSION",Session("s_Language"))
    call sys_ShowErrorHtml(strErrMsg,strProgDescription,"")
end if
'********************************************************************************************************************
%>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
<meta http-equiv='Content-Language' content='<%=Session("s_Content")%>'>
<link rel='stylesheet' type='text/css' href='/GDCRM/css/default.css'>
<!-- Client-Side標準公用函數-->
<!--#include virtual='/GDCRM/library/sys_SingleFormParameter_C.asp'-->
<!--#include virtual='/GDCRM/library/sys_SingleGridConst_C.asp'-->
<script language='vbscript.encode' src='/GDCRM/library/sys_MsgBox_C.vbs'></script>
<script language='vbscript.encode' src='/GDCRM/library/sys_FormatNumber_C.vbs'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_Right_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_XMLEncode_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_Trim_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_ShowWaiting_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_SingleGrid_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_DisableToolbar_List_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_ReportParameter_C.js'></script>
<!--#include virtual='/GDCRM/Library/sys_DateTime_Const.asp' -->
<script language='jscript.encode'  src='/GDCRM/Library/sys_DateTime_C.js'></script>
<script language='jscript.encode' src='/GDCRM/library/sys_KeyDown_List_C.js'></script>

<!-- Client-Side特殊公用函數-->

<!-- Start of 程式Global變數設定-->
<script language='jscript.encode'>
var g_blnDebug = <%=lcase(Session("s_DebugMode"))%>;
var g_aryPerm = new Array(<%=lcase(aryPerm(0))%>,<%=lcase(aryPerm(1))%>,<%=lcase(aryPerm(2))%>,<%=lcase(aryPerm(3))%>,<%=lcase(aryPerm(4))%>,<%=lcase(aryPerm(5))%>,<%=lcase(aryPerm(6))%>,<%=lcase(aryPerm(7))%>,<%=aryPerm(8)%>);
var g_strProgID = sys_XMLEncode("<%=strProgID%>");
var g_Language = "<%=Session("s_Language")%>";
var g_aryDelete = new Array();
var g_intPageSize = <%=Session("s_PageSize")%>;
var g_intCurrentPage;
var g_intPageCount = 0;
var g_xmlDocData;
var g_xmlDocStyle;
var g_blnResizeFlag=false;
var g_blnFieldMoveFlag=false;
var g_strCurColumnID = "";
var g_intCurColumnWidth = 0;
var g_intCurColumnRight = 0;
var g_blnLayoutViewStyleLoaded = false;
var g_strPermRestrict = "";
var g_xmlHttp;
var g_aryDisableList;
</script>
<!-- End of 程式Global變數設定-->

<Script language='jscript.encode'>
function Init() {                                           //初始化
    if (sys_Trim(document.all["gd_DisL"].value) != "") {
        g_aryDisableList = document.all["gd_DisL"].value.split(",");
    }
    var g_strDefaultQueryField = "<%=strDefaultQueryField%>";
    var g_strDefaultQueryOperator = "<%=strDefaultQueryOperator%>";
    window.defaultStatus = "<%=strProgDescription%>";
    top.document.title = "<%=strProgDescription%>";
    grid_Init();
}

function AfterGridInit() {                                  //After Grid Init
    sys_DisableToolbar_List();
}

function AddNew() {                                         //新增
    document.frmParameter.action = g_strProgID + "_New.asp?gd_Key=";
    document.frmParameter.submit();
}

function GetQueryData() {                                   //查詢
    var aryData = new Array(document.all['gd_DF'].value,document.all['gd_DO'].value,document.all['gd_W'].value,document.all['gd_O'].value);
    var strURL = "/GDCRM/Library/sys_SQB.asp?gd_ID="+g_strProgID;
    var aryRet = window.showModalDialog(strURL, aryData, 'dialogWidth:700px;dialogHeight:550px');

    if (typeof(aryRet) == 'undefined') {return;}

    document.all['gd_W'].value = aryRet[0];
    document.all['gd_O'].value = aryRet[1];
    document.all["myGrid"].CurrentPage = 1;
    grid_Init();
}

function GetLayoutView() {                                  //檢視
    var aryData = new Array(g_xmlDocStyle);
    var strURL = "/GDCRM/library/sys_LVB.asp?gd_ID="+g_strProgID;
    var aryRet = window.showModalDialog(strURL, aryData, 'dialogWidth:700px;dialogHeight:550px');

    if (typeof(aryRet) == 'undefined') {return;}

    g_xmlDocStyle = aryRet[0];
    g_blnLayoutViewStyleLoaded=true;
    document.all['gd_VD'].value = g_xmlDocStyle.xml;
    grid_Init();
}

function PrintReport() {                                    //列印
    try {
        var strURL = "/GDCRM/library/sys_ReportDialog.asp" +
                     "?ProgID=" + escape(g_strProgID) +
                     "&CurPage=" + g_intCurrentPage +
                     "&PageCount=" + g_intPageCount +
                     "&PrintDataURL=" + escape("/GDCRM/Prog/" + g_strProgID + "/ws_GetReportData.asp");

        var aryRet = window.showModalDialog(strURL,null,"dialogWidth:700px;dialogHeight:550px");

        if (typeof(aryRet) == "undefined") {return;}
        var strCMD = "";
        for (var i=0; i<=g_ReportParametersCount-1; i++) {
            strCMD += aryRet[i] + ",";
        }
        strCMD += aryRet[g_ReportParametersCount];
        document.all['gd_Cmd'].value = strCMD;
        document.frmParameter.action = g_strProgID + "_Report.asp";
        document.frmParameter.target = "_blank";
        document.frmParameter.submit();
        document.frmParameter.target = "";
    } catch (e) {alert(e.description);}
}

function GenExcel() {               //將資料匯出到Excel
    try {
        if (g_intPageCount < 1)  {return;}
        var aryData = new Array(g_intCurrentPage, g_intPageCount);
        var aryRet = window.showModalDialog("/GDCRM/library/sys_ConvertToExcel.asp",aryData,"dialogWidth:400px;dialogHeight:300px");
        var intSatrt = aryRet[0];
        var intEnd = aryRet[1];
    } catch (e) {return;}

    var strOldCmd = document.all['gd_Cmd'].value;
    var strOldVD =  document.all['gd_VD'].value;
    document.all['gd_Cmd'].value = "EXCEL,"+intSatrt+","+intEnd;
    document.all['gd_VD'].value = g_xmlDocStyle.xml;
    document.frmParameter.action = document.all["myGrid"].DataURL;
    document.frmParameter.target = "_blank";
    document.frmParameter.submit();
    document.frmParameter.target = "";
    document.all['gd_Cmd'].value = strOldCmd;
    document.all['gd_VD'].value = strOldVD;
}

function Exit() {                                           //離開
    if (top == window) {
        window.close();
    }
    else {
        var strModuleID = sys_Trim(document.all["gd_Mod"].value);
        var strCategoryID = sys_Trim(document.all["gd_Cat"].value);
        if ((strModuleID != "") && (strCategoryID != "")) {
            window.location = "/GDCRM/Library/sys_MenuFolder.asp?ModuleID="+strModuleID+"&CategoryID="+strCategoryID;
        }
        else {
            window.location = "/GDCRM/Content.asp";
        }
    }
}

function ShowHelp() {                                       //說明
    window.open("<%=Session("s_HelpURL")%>help_"+g_strProgID+".asp");
}

function MoveFirstPage() {                                  //第一頁
    document.all["myGrid"].CurrentPage = 1;
    grid_Init();
}

function MovePreviousPage() {                               //上一頁
    document.all["myGrid"].CurrentPage = g_intCurrentPage - 1;
    grid_Init();
}

function MoveNextPage() {                                   //下一頁
    document.all["myGrid"].CurrentPage = g_intCurrentPage + 1;
    grid_Init();
}

function MoveLastPage() {                                   //最後一頁
    document.all["myGrid"].CurrentPage = g_intPageCount;
    grid_Init();
}

function Refresh() {                                        //重新整理
    grid_Init();
}

function DeleteAllSelected() {                              //刪除所有選取的資料
    var strComfirmMsg = "<%=objKey.ReadResString("ARE_YOU_SURE_DELETE_ALL_SELECTED_DATA",Session("s_Language"))%>";

    var intCount = g_xmlDocData.documentElement.selectSingleNode("/Recordset").childNodes.length;
    if (intCount==0) {return;}

    var intChecked=0;

    for (var i=0; i<intCount; i++) {
        if (document.all['chkRecord'+i].checked == true) { intChecked ++; }
    }

    //檢查是否有選取要刪除的資料?
    if (intChecked == 0) {
        alert("<%=objKey.ReadResString("PLEASE_SELECT_DATA_THAT_YOU_WANT_TO_DELETE",Session("s_Language"))%>");
        return;
    }
    else {
        //確認是否刪除所有選取的資料
        if (sys_MsgBox(strComfirmMsg, 32+4+256, "<%=objKey.ReadResString("DELETE_CONFIRM",Session("s_Language"))%>") != 6) {
            return;
        }
    }
    var n = 0;
    for (var i=intCount-1; i>=0; i--) {
        if (document.all['chkRecord'+i].checked == true) {
            g_aryDelete[n] = i;
            n = n + 1;
        }
    }
    Delete(g_aryDelete[n-1],true);
}



function UserModifyContent(strContent,strFieldName) {       //欄位內容的調整
    var strHtml;
    switch (strFieldName) {
        case "IsActive": case "IsAudit":
            if (strContent == 0) { strHtml = "N"; }
            else { strHtml = "Y"; };
            break;
        default:
            strHtml = strContent;
            break;
    }
    return(strHtml);
}
EOF
}

template_entry_multy_key2() {
    local lastkey="`key_name "$KEY_MULTY" $KEY_COUNT`"
    #echo 1>&2 "$lastkey"
    #echo 1>&2 "$RES_MULTY"
    for fd_res in `echo "$RES_MULTY"` ; do
	fd="`echo $fd_res | sed 's/,.*$//g'`"
	res="`echo $fd_res | sed 's/^.*,//g'`"
	#echo 1>&2 "$fd,$res"
	tailer="+ "
	if [ $fd = $lastkey ] ; then 
	    tailer=";"
	fi
	echo  "$1""$res""$2"
	echo  "$3""$fd""$4" $tailer
    done
}
template_entry_multy_key1() {
    local lastkey="`key_name "$KEY_MULTY" $KEY_COUNT`"
    #echo 1>&2 "$lastkey"
    for fd in `echo "$KEY_MULTY" | sed 's/,/ /g'` ; do
	tailer="+ \",\" +"
	if [ $fd = $lastkey ] ; then 
	    tailer=";"
	fi
	echo  "$1""$fd""$2" $tailer
    done
    
}
template_entry_multy_key() {
cat <<-EOF
function Display(n) {                                       //檢視或修改
    var objNode = g_xmlDocData.documentElement.selectSingleNode("/Recordset").childNodes.item(n);

    //找出修改資料時，所需要的資料鍵值(Key Fields)，放到gd_Key的TextBox之中
EOF

if [ "$KEY_TYPE". = "MULTY_KEY". ] ; then
cat <<-EOF
    var strKeyValue = 
	`template_entry_multy_key1 '		    objNode.selectSingleNode("'  '").text'`
EOF
else
cat <<-EOF
    var strKeyValue = objNode.selectSingleNode("##PKEY_#").text;
EOF
fi
cat <<-EOF 
    document.all['gd_Key'].value = sys_XMLEncode(strKeyValue);
    //檢視或修改指定的資料
    document.frmParameter.action = g_strProgID + "_Modify.asp";
    document.frmParameter.submit();
}
EOF
cat <<-EOF
function Delete(n,blnBatchMode) {                           //刪除指定資料
    var objNode = g_xmlDocData.documentElement.selectSingleNode("/Recordset").childNodes.item(n);
    //找出刪除資料時，所需要的資料鍵值(Key Fields)
EOF
if [ "$KEY_TYPE". = "MULTY_KEY". ] ; then
cat <<-EOF
    var strKeyValue = 
	`template_entry_multy_key1 '		    objNode.selectSingleNode("'  '").text'`
    //alert( strKeyValue);
EOF
else
cat <<-EOF
    var strKeyValue = objNode.selectSingleNode("##PKEY_#").text;
EOF
fi
cat <<-EOF
    var strComfirmMsg = "<%=objKey.ReadResString("CONFIRM_TO_DELETE_DATA",Session("s_Language"))%>";

    if (blnBatchMode != true) {
        if (sys_MsgBox(strComfirmMsg, 32+4+256, "<%=objKey.ReadResString("DELETE_CONFIRM",Session("s_Language"))%>") != 6) {
            return;
        }
    }

    //向主機端發出HTTP Request
    var strURL = "ws_" + g_strProgID + "_Delete.asp?gd_Key=" + escape(strKeyValue);

    g_xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
    g_xmlHttp.open("GET",strURL,true);
    g_xmlHttp.send();
    ShowWaiting("Deleting");    //ShowWaiting(strMsgType)  strMsgType= 'Deleting' or 'Saving' or 'Loading'
    g_xmlHttp.onreadystatechange = Function( "DeleteFinish(" + n + "," + blnBatchMode + ");" );
}
EOF
cat <<-EOF
function DeleteFinish(n,blnBatchMode) {                     //刪除完成
    var strErrMsg;
    if (g_xmlHttp.readyState != 4) {
        return;
    }
    document.all['gobj_WaitingMessageBox'].style.display = "none";
    var objNode = g_xmlDocData.documentElement.selectSingleNode("/Recordset").childNodes.item(n);
    //*** 刪除發生錯誤時的提示文字
EOF

if [ "$KEY_TYPE". = "MULTY_KEY". ] ; then
cat <<-EOF
    var strRemindMsg = 
	$(template_entry_multy_key2 \
            '               "<%=objKey.ReadResString("'	    '",Session("s_Language"))%>" + " : " +  ' \
	    '		    objNode.selectSingleNode("'	    '").text')
EOF
else
cat <<-EOF
    var strRemindMsg = "<%=objKey.ReadResString("##PKEY_#",Session("s_Language"))%>" + " : " +
                       objNode.selectSingleNode("##PKEY_#").text;
EOF
fi
cat <<-EOF
    if (g_xmlHttp.responseText != "OK") {
        var strErrMsg = "<%=objKey.ReadResString("ERROR_OCCUR_WHEN_DELETE_DATA",Session("s_Language"))%>\n\n" +
                        strRemindMsg + "\n\n" +
                        "<%=objKey.ReadResString("ERROR_REASON",Session("s_Language"))%>" + g_xmlHttp.responseText;
        alert(strErrMsg);

        if (blnBatchMode == true) {
            if (sys_MsgBox("<%=objKey.ReadResString("WANT_TO_CONTINUE",Session("s_Language"))%>",
                           32+4+256,"<%=objKey.ReadResString("DELETE_CONFIRM",Session("s_Language"))%>") != 6) {
                //清除刪除選取陣列
                g_aryDelete = new Array();
                grid_Init();
                return;
            }
        }
        else {
            return;
        }
    }

    //顯示刪除成功的訊息
    if (blnBatchMode == true) {
        g_aryDelete.length = g_aryDelete.length - 1;
        if (g_aryDelete.length > 0 ) {
            var intNextItem = g_aryDelete[g_aryDelete.length-1];
            Delete(intNextItem, true);
        }
        else {
            alert("<%=objKey.ReadResString("BATCH_DELETE_COMPLETE",Session("s_Language"))%>");
            grid_Init();
        }
    }
    else {
        alert("<%=objKey.ReadResString("DELTE_DATA_SUCCEED",Session("s_Language"))%>");
        grid_Init();
    }
}

EOF

if [ "$IS_ATTACH". = "TRUE". ]; then
cat <<-EOF
function SearchAttach() {                                   //搜尋附件
    var strAttachTableName = "##Template_#";
    var strURL = "/GDCRM/Search/Search.asp?AttachTable=" + strAttachTableName ;
    window.open(strURL,"SearchAttachmentWindow","width=640,height=480,status=yes,scrollbars=yes,resizable=yes");
}
EOF
fi

}

template_entry_tailer(){
cat <<-EOF
</Script>
</head>
<body onload='jscript:self.focus();Init();' onkeydown='jscript:sys_KeyDown_List();'>
<div class='clsProgTitle' id='blkProgTitle'><nobr>
    <img class='clsIcon16' src='<%=sys_GetProgramIconUrl(strProgID)%>' align='absmiddle' hspace=5>
    <%=sys_XMLEncode(strProgDescription)%></nobr>
</div>
<!--#include virtual='/GDCRM/Prog/##Location_#/Toolbar_List.asp'-->
<br>
<div id="myGrid" name="myGrid" DataURL='ws_<%=strProgID%>_Data.asp' CurrentPage='<%=intPage%>'
    style='border:solid 0px darkgreen;position:relative;z-index:10;'></div>
</body>
</html>
EOF
}

template_entry() {
KEY_COUNT="`key_count`"
template_entry_header
template_entry_multy_key
template_entry_tailer
}
