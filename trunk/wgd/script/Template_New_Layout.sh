
header_new_layout() {
cat <<-EOF
<table cellpadding=3 cellspacing=0 border=0 style='margin-left:10px;margin-top:10px'>
<!-- PKEY: ##PKEY_# -->
<tr>
    <td align='right' nowrap>
        <%=objKey.ReadResString("##PKEY_#",Session("s_Language"))%>:</td>
    <td><font color='darkblue'>#</font></td>
    <td><input id='##PKEY_#' name='##PKEY_#' type='text' class='clsEditField' size='15' maxlength='10'
            onchange='jscript:sys_SetDataModified();'>
    </td>
</tr>
EOF

}


tailer_new_layout() {
cat <<-EOF
</table>
EOF
}

template_new_layout() {

    header_new_layout | sed "s/##PKEY_#/$(echo $PKEY)/g"

    for fd in $(echo $FIELDS ) ; do
	FieldName=$(echo $fd | gawk -F "/" '{print $1}')
        FieldType=$(echo $fd | gawk -F "/" '{print $2}')
	case $FieldType in
	    text) field_text_modify_layout | sed "s/##FieldName_#/$(echo $FieldName)/g" ;;
	    date) templatefield_date | sed "s/##FieldName_#/$(echo $FieldName)/g" ;;
	    *) ;;
	esac
    done

    tailer_new_layout
}
