header_modify_layout() {
cat <<-EOF
<!-- Header -->
EOF
}

pkey_modify_layout() {
cat <<-EOF

<!-- pkey_modify_layout(): PKEY Field: ##PKEY_# -->
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
if [ ! "$TABCOUNT". = "0". ] ; then
cat <<-EOF
<!-- Folder_Tag_modify_layout() -->
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
fi
}

field_header_modify_layout() {
if [ ! "$TABCOUNT". = "0". ] ; then
cat <<-EOF
<!--field_header_modify_layout(): 主要資料-->
<table id='blkTab1' cellpadding=3 cellspacing=0 border=0 style='display:none;margin-left:10px;margin-top:10px'>
<!-- begin of others Fields ..... -->
EOF
fi
}

field_text_modify_layout() {
cat <<-EOF
<!-- FieldName: ##FieldName_# -->
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

field_body_count() {
if [ "$PRG_TYPE". = "DBL". ] ; then
cat <<-EOF
<!-- Hide cnt -->
<input id=cnt type=text>
EOF
fi
}

field_tailer_modify_layout() {
if [ ! "$TABCOUNT". = "0". ] ; then
cat <<-EOF
<!-- field_tailer_modify_layout(): end of others Fields ..... --></table>
EOF
fi
}


tailer_modify_layout() {
if [ "$PRG_TYPE". = "DBL". ] ; then
    # ${RELATED_TABLE} --> $(__related_table)
cat <<-EOF
<!--$(__related_table)_Data: Related TABLE, tailer_modify_layout(): -->
<table id='blkTab7' BORDER=1 BORDERCOLOR='green' cellpadding=3 cellspacing=0 border=0 style='margin-left:10px;margin-top:10px;HEIGHT:51%;WIDTH:96%;border-collapse:collapse'>
    <tr>
        <td>
            <iframe id='$(__related_table)_Data' frameborder=no style='z-index:999;width:100%;height:100%' src=''>
            </iframe>
        </td>
    </tr>
</table>
EOF
else
    if [ ! "$TABCOUNT". = "0". ] ; then
cat <<-EOF
<!--tailer_modify_layout(): 系統資料-->
<table id='blkTab2' cellpadding=3 cellspacing=0 border=0 style='display:none;margin-left:10px;margin-top:10px'>
<%=sys_GenModifierTablet()%>
<%=sys_GenPermissionTablet()%>
</table>
EOF
    fi
fi

}

template_modify_layout() {

    header_modify_layout
    if [ "$KEY_MULTY". = "". ] ; then
	pkey_modify_layout | sed "s/##PKEY_#/`echo $PKEY`/g"
    fi
    folder_tag_modify_layout
    field_header_modify_layout
    for fd in $(echo $FIELDS ) ; do
	FieldName=$(echo $fd | gawk -F "/" '{print $1}')
	FieldInputType=$(echo $fd | gawk -F "/" '{print $2}')
	if [ ! "$FieldInputType". = "System". ] ; then
	    field_text_modify_layout | sed "s/##FieldName_#/$(echo $FieldName)/g"
	fi
    done
    field_body_count
    field_tailer_modify_layout
    tailer_modify_layout

}
