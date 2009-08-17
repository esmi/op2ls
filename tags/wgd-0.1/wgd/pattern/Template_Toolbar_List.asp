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

        <td nowrap><span onclick='GetQueryData();' class='clsHref' language='jscript'
            onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
            title='<%=objKey.ReadResString("QUERY_SPECIFIC_DATA",Session("s_Language"))%>'>
            <img src='/GDCRM/images/sys_tool_Search.gif' align='absmiddle' border='0'>
            <%=objKey.ReadResString("QUERY",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
        </td>

        <td nowrap><span onclick='GetLayoutView();' class='clsHref' language='jscript'
            onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
            title='<%=objKey.ReadResString("APPLY_OTHER_LAYOUT_VIEW",Session("s_Language"))%>'>
            <img src='/GDCRM/images/sys_tool_View.gif' align='absmiddle' border='0'>
            <%=objKey.ReadResString("VIEW",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
        </td>

        <%if aryPerm(4) = true then %>
             <td nowrap><span onclick='PrintReport();' class='clsHref' language='jscript'
                onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
                title='<%=objKey.ReadResString("PRINT_REPORT",Session("s_Language"))%>'>
                <img src='/GDCRM/images/sys_tool_Print.gif' align='absmiddle' border='0'>
                <%=objKey.ReadResString("PRINT",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
             </td>

             <td nowrap><span onclick='GenExcel();' class='clsHref' language='jscript'
                onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
                title='<%=objKey.ReadResString("EXPORT_TO_EXCEL_REPORT",Session("s_Language"))%>'>
                <img src='/GDCRM/images/sys_doc_excel.gif' align='absmiddle' border='0'>
                <%=objKey.ReadResString("EXPORT_EXCEL",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
            </td>
        <%end if%>

       <td nowrap id='tool_Exit'><span onclick='Exit();' class='clsHref' language='jscript' id='nv_Exit'
            onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
            title='<%=objKey.ReadResString("EXIT_TITLE",Session("s_Language"))%>'>
            <img src='/GDCRM/images/sys_tool_Exit.gif' align='absmiddle' border='0'>
            <%=objKey.ReadResString("EXIT",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
        </td>

        <td nowrap id='tool_Help'><span onclick='ShowHelp();' class='clsHref' language='jscript' id='nv_Help'
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
        <td nowrap><span onclick='MoveFirstPage();' class='clsHref' language='jscript' id='nv_First'
            onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
            title='<%=objKey.ReadResString("MOVE_TO_FIRST_PAGE",Session("s_Language"))%>'>
            <img src='/GDCRM/images/sys_tool_FirstPage.gif' align='absmiddle' border='0'>
            <%=objKey.ReadResString("FIRST_PAGE",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
        </td>

        <td nowrap><span onclick='MovePreviousPage();' class='clsHref' language='jscript' id='nv_Prev'
            onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
            title='<%=objKey.ReadResString("MOVE_TO_PREVIOUS_PAGE",Session("s_Language"))%>'>
            <img src='/GDCRM/images/sys_tool_PreviousPage.gif' align='absmiddle' border='0'>
            <%=objKey.ReadResString("PREVIOUS_PAGE",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
        </td>

        <td nowrap id='blkJumpPage' style='display:'>
            <select id='cboJumpPage' onchange='JumpPage();' language='jscript'></select>&nbsp;&nbsp;&nbsp;
        </td>

        <td nowrap><span onclick='MoveNextPage();' class='clsHref' language='jscript' id='nv_Next'
            onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
            title='<%=objKey.ReadResString("MOVE_TO_NEXT_PAGE",Session("s_Language"))%>'>
            <img src='/GDCRM/images/sys_tool_NextPage.gif' align='absmiddle' border='0'>
            <%=objKey.ReadResString("NEXT_PAGE",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
        </td>

        <td nowrap><span onclick='MoveLastPage();' class='clsHref' language='jscript' id='nv_Last'
            onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
            title='<%=objKey.ReadResString("MOVE_TO_LAST_PAGE",Session("s_Language"))%>'>
            <img src='/GDCRM/images/sys_tool_LastPage.gif' align='absmiddle' border='0'>
            <%=objKey.ReadResString("LAST_PAGE",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
        </td>

        <td nowrap><span onclick='Refresh();' class='clsHref' language='jscript'
            onmouseover='this.className="clsHrefOver";' onmouseout='this.className="clsHref";'
            title='<%=objKey.ReadResString("REFRESH_TITLE",Session("s_Language"))%>'>
            <img src='/GDCRM/images/sys_tool_Refresh.gif' align='absmiddle' border='0'>
            <%=objKey.ReadResString("REFRESH",Session("s_Language"))%></span>&nbsp;&nbsp;&nbsp;
        </td>
        <td nowrap><span class='clsHref' style='cursor:default'><%=objKey.ReadResString("PAGE_SIZE",Session("s_Language"))%></span>
            <select id='cboPageSize' onchange='SetPageSize();' language='jscript'></select>
        </td>
    </tr>
</table>
</div>
