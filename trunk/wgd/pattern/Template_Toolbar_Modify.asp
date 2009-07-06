<div class='clsToolbar'>
<table cellspacing=1 cellpadding=1 border=0>
    <tr>
        <%if aryPerm(1) = true then %>
            <td nowrap><span onclick='AddNew();' class='clsHref' language='jscript'
                onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
                title='<%=objKey.ReadResString("ADD_NEW_RECORD",Session("s_Language"))%>'>
                <img src='/GDCRM/images/sys_tool_AddNew.gif' align='absmiddle' border='0'>
                <%=objKey.ReadResString("ADD",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
            </td>
        <%end if%>
        <%if aryPerm(2) = true then %>
            <td nowrap><span onclick='Save();' class='clsHref' language='jscript' id='nv_Save'
                onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
                title='<%=objKey.ReadResString("SAVE_TITLE",Session("s_Language"))%>'>
                <img src='/GDCRM/images/sys_tool_Save.gif' align='absmiddle' border='0'>
                <%=objKey.ReadResString("SAVE",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
            </td>
        <%end if%>
        <%if aryPerm(3) = true then %>
            <td nowrap><span onclick='Delete();' class='clsHref' language='jscript'
                onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
                title='<%=objKey.ReadResString("DELETE_TITLE",Session("s_Language"))%>'>
                <img src='/GDCRM/images/sys_tool_delete.gif' align='absmiddle' border='0'>
                <%=objKey.ReadResString("DELETE",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
            </td>
        <%end if%>

        <td nowrap><span onclick='Exit();' class='clsHref' language='jscript'
            onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
            title='<%=objKey.ReadResString("EXIT_TITLE",Session("s_Language"))%>'>
            <img src='/GDCRM/images/sys_tool_Exit.gif' align='absmiddle' border='0'>
            <%=objKey.ReadResString("EXIT",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
        </td>

        <td nowrap><span onclick='ShowHelp();' class='clsHref' language='jscript'
            onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
            title='<%=objKey.ReadResString("HELP_TITLE",Session("s_Language"))%>'>
            <img src='/GDCRM/images/sys_tool_Help.gif' align='absmiddle' border='0'>
            <%=objKey.ReadResString("HELP",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
        </td>
    </tr>
</table>
</div>
<div class='clsToolbar'>
<table cellspacing=1 cellpadding=1 border=0>
    <tr>
        <td nowrap><span onclick='FirstRecord();' class='clsHref' language='jscript' id='nv_First'
            onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
            title='<%=objKey.ReadResString("MOVE_TO_FIRST_RECORD",Session("s_Language"))%>'>
            <img src='/GDCRM/images/sys_tool_First.gif' align='absmiddle' border='0'>
            <%=objKey.ReadResString("FIRST_RECORD",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
        </td>

        <td nowrap><span onclick='PreviousRecord();' class='clsHref' language='jscript' id='nv_Prev'
            onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
            title='<%=objKey.ReadResString("MOVE_TO_PREVIOUS_RECORD",Session("s_Language"))%>'>
            <img src='/GDCRM/images/sys_tool_Previous.gif' align='absmiddle' border='0'>
            <%=objKey.ReadResString("PREVIOUS_RECORD",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
        </td>

        <td nowrap>
            <select id='cboJumpRecord' onchange='JumpRecord();' language='jscript'></select>&nbsp;&nbsp;&nbsp;
        </td>

        <td nowrap><span onclick='NextRecord();' class='clsHref' language='jscript' id='nv_Next'
            onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
            title='<%=objKey.ReadResString("MOVE_TO_NEXT_RECORD",Session("s_Language"))%>'>
            <img src='/GDCRM/images/sys_tool_Next.gif' align='absmiddle' border='0'>
            <%=objKey.ReadResString("NEXT_RECORD",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
        </td>

        <td nowrap><span onclick='LastRecord();' class='clsHref' language='jscript' id='nv_Last'
            onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
            title='<%=objKey.ReadResString("MOVE_TO_LAST_RECORD",Session("s_Language"))%>'>
            <img src='/GDCRM/images/sys_tool_Last.gif' align='absmiddle' border='0'>
            <%=objKey.ReadResString("LAST_RECORD",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
        </td>
        <td nowrap><span onclick='Refresh();' class='clsHref' language='jscript'
            onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
            title='<%=objKey.ReadResString("REFRESH_TITLE",Session("s_Language"))%>'>
            <img src='/GDCRM/images/sys_tool_Refresh.gif' align='absmiddle' border='0'>
            <%=objKey.ReadResString("REFRESH",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
        </td>

    </tr>
</table>
</div>
