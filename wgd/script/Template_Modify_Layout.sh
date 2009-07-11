Header_modify_layout() {

cat <<-EOF
<!-- Header -->
EOF

}

pkey_modify_layout() {
cat <<-EOF

<!-- pkey_modify_layout(): PKEY Field: WhrsId -->
<table cellpadding=3 cellspacing=0 border=0 style='margin-left:10px;margin-top:10px'>
<tr>
    <td align=right nowrap>
        <%=objKey.ReadResString("##PKEY_#",Session("s_Language"))%>:</td>
    <td><%=strKeyField%></td>
    <td nowrap>
        <input id='##PKEY_#' type='text' class='clsLockField' readonly size='25'>
    </td>
</tr>
</table>
EOF
}

folder_tag_modify_layout() {
cat <<-EOF
<!-- folder_tag_modify_layout() -->
<input type='hidden' id='PermissionID' name='PermissionID'>

<table cellpadding=0 cellspacing=0 border=0 style='margin-left:10px;margin-top:10px'>
    <tr><td>
        <span id='Tab1' class='clsTab' onclick='jscript:sys_SwitchTab(1);'>
            <%=objKey.ReadResString("MASTER_DATA",Session("s_Language"))%></span>
        <span id='Tab2' class='clsTab' onclick='jscript:sys_SwitchTab(2);'>
            <%=objKey.ReadResString("SYSTEM_DATA",Session("s_Language"))%></span>
    </td></tr>
</table>
EOF
}

field_header_modify_layout() {
cat <<-EOF
<!--field_header_modify_layout(): 主要資料-->
<table id='blkTab1' cellpadding=3 cellspacing=0 border=0 style='display:none;margin-left:10px;margin-top:10px'>
<!-- begin of others Fields ..... -->
EOF
}

field_text_modify_layout() {
cat <<-EOF
<!-- FieldName: Description -->
<tr>
    <td align='right' nowrap>
        <%=objKey.ReadResString("##FieldName_#",Session("s_Language"))%></td>
    <td></td>
    <td nowrap>
        <input id='##FieldName_#' type='text' class='<%=strReadOnlyClass%>' size=15 maxlength=12 accessKey='B'
        <%=strReadOnlyTAG%>
        onchange='jscript:sys_SetDataModified();' >
    </td>
</tr>
EOF
}
field_tailer_modify_layout() {
cat <<-EOF
<!-- field_tailer_modify_layout(): end of others Fields ..... -->
</table>
EOF
}


tailer_modify_layout() {
if [ "$PRG_TYPE". = "DBL". ] ; then
cat <<-EOF
<!--tailer_modify_layout(): ${RELATED_TABLE}_Data: Related TABLE-->
<table id='blkTab7' BORDER=1 BORDERCOLOR='green' cellpadding=3 cellspacing=0 border=0 style='margin-left:10px;margin-top:10px;HEIGHT:51%;WIDTH:96%;border-collapse:collapse'>
    <tr>
        <td>
            <iframe id='${RELATED_TABLE}_Data' frameborder=no style='z-index:999;width:100%;height:100%' src=''>
            </iframe>
        </td>
    </tr>
</table>
EOF
else
cat <<-EOF
<!--tailer_modify_layout(): 系統資料-->
<table id='blkTab2' cellpadding=3 cellspacing=0 border=0 style='display:none;margin-left:10px;margin-top:10px'>
<%=sys_GenModifierTablet()%>
<%=sys_GenPermissionTablet()%>
</table>
EOF
fi

}

template_modify_layout() {

    header_modify_layout
    pkey_modify_layout | sed "s/##PKEY_#/`echo $PKEY`/g"
    folder_tag_modify_layout
    field_header_modify_layout
    for fd in $(echo $FIELDS ) ; do
	FieldName=$(echo $fd | gawk -F "/" '{print $1}')
	field_text_modify_layout | sed "s/##FieldName_#/$(echo $FieldName)/g"
    done
    field_tailer_modify_layout
    tailer_modify_layout

}
