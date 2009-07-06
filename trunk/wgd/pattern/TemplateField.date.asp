
<!-- FieldName: ##FieldName_# -->
<tr>
    <td align='right' nowrap>
        <%=objKey.ReadResString("##FieldName_#",Session("s_Language"))%>[B]:</td>
    <td></td>
    <td nowrap>
        <input id='##FieldName_#' type='text' class='<%=strReadOnlyClass%>' size=15 maxlength=12 accessKey='B'
        <%=strReadOnlyTAG%>
        onchange='jscript:sys_CheckDateField("##FieldName_#");sys_SetDataModified();' >
        <!-- Select Button -->
        <button class='clsIconButton' language='jscript'
            onmouseover='this.className="clsIconButtonOver";' onmouseout='this.className="clsIconButton";'
            title='<%=objKey.ReadResString("CHOICE_DATE",Session("s_Language"))%>'
            onclick='sys_ChoiceDate("##FieldName_#",document.all["##FieldName_"].value,"");' <%=strHideButton%> >
            <img src='/GDCRM/images/sys_tool_day31b.gif' border=0 align=absmiddle>
        </button>
    </td>
</tr>
