<div class='clsToolbar'>
<table cellspacing=1 cellpadding=1 border=0 >
    <tr>
        <%if aryPerm(1) = true then %>
            <td nowrap><span onclick='Save();' class='clsHref' language='jscript' id='nv_Save'
                onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
                title='<%=objKey.ReadResString("SAVE_TITLE",Session("s_Language"))%>'>
                <img src='/GDCRM/images/sys_tool_Save.gif' align='absmiddle' border='0'>
                <%=objKey.ReadResString("SAVE",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
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
