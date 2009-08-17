
<!-- FieldName: ##FieldName_# -->
<tr>
    <td align='right' nowrap>
        <%=objKey.ReadResString("##FieldName_#",Session("s_Language"))%>[B]:</td>
    <td></td>
    <td nowrap>
        <input id='##FieldName_#' type='text' class='<%=strReadOnlyClass%>' size=15 maxlength=12 accessKey='B'
        <%=strReadOnlyTAG%>
        onchange='jscript:sys_CheckDateField("##FieldName_#");sys_SetDataModified();' >
    </td>
</tr>
