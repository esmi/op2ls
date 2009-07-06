<table cellpadding=3 cellspacing=0 border=0 style='margin-left:10px;margin-top:10px'>
<!-- PKEY Field: ##PKEY_# -->
<tr>
    <td align=right nowrap>
        <%=objKey.ReadResString("##PKEY_#",Session("s_Language"))%>:</td>
    <td><%=strKeyField%></td>
    <td nowrap>
        <input id='##PKEY_#' type='text' class='clsLockField' readonly size='25'>
    </td>
</tr>
</table>

<input type='hidden' id='PermissionID' name='PermissionID'>

<table cellpadding=0 cellspacing=0 border=0 style='margin-left:10px;margin-top:10px'>
    <tr><td>
        <span id='Tab1' class='clsTab' onclick='jscript:sys_SwitchTab(1);'>
            <%=objKey.ReadResString("MASTER_DATA",Session("s_Language"))%></span>
        <span id='Tab2' class='clsTab' onclick='jscript:sys_SwitchTab(2);'>
            <%=objKey.ReadResString("SYSTEM_DATA",Session("s_Language"))%></span>
    </td></tr>
</table>

<!--主要資料-->
<table id='blkTab1' cellpadding=3 cellspacing=0 border=0 style='display:none;margin-left:10px;margin-top:10px'>
<!-- begin of others Fields ..... -->



<!-- begin of others Fields ..... -->
</table>

<!--系統資料-->
<table id='blkTab2' cellpadding=3 cellspacing=0 border=0 style='display:none;margin-left:10px;margin-top:10px'>
<%=sys_GenModifierTablet()%>
<%=sys_GenPermissionTablet()%>
</table>
