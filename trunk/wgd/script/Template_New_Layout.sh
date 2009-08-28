
header_new_layout() {
cat <<-EOF
<table cellpadding=3 cellspacing=0 border=0 style='margin-left:10px;margin-top:10px'>
EOF
}

header_pkey_layout() {
if [ "$KEY_MULTY". = "". ] ; then
cat <<-EOF
<!-- PKEY: ${PKEY} -->
<tr>
    <td align='right' nowrap>
        <%=objKey.ReadResString("${PKEY}",Session("s_Language"))%>:</td>
    <td><font color='darkblue'>#</font></td>
    <td><input id='${PKEY}' name='${PKEY}' type='text' class='clsEditField' size='15' maxlength='10'
            onchange='jscript:sys_SetDataModified();'>
    </td>
</tr>
EOF
fi
}

field_new_layout() {
cat <<-EOF
<!-- FD: ${FieldTitle} -->
<tr>
    <td align='right' nowrap>
        <%=objKey.ReadResString("${FieldRES}",Session("s_Language"))%>:</td>
    <td><font color='darkblue'>#</font></td>

    <td><input id='${FieldName}' type='${FieldType}' name='${FieldName}' class='clsEditField' size='15' maxlength='10'
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

    #header_new_layout | sed "s/##PKEY_#/$(echo $PKEY)/g"
    header_new_layout 
    #header_pkey_layout

    for fd in $(echo $FIELDS ) ; do
	FieldName=$(echo $fd | gawk -F "/" '{print $1}')
        FieldType=$(echo $fd | gawk -F "/" '{print $2}')
        FieldTitle=$(echo $fd | gawk -F "/" '{print $7}')
        FieldRES=$(echo $fd | gawk -F "/" '{print $14}')
        isAddDisplay=$(echo $fd | gawk -F "/" '{print $9}')

	if [[ "$FieldRES" = "-" ]]; then
		FieldRES="$FieldName"	    
	fi

	#echo 1>&2 'FD:' $FieldName, '$FieldType:' $FieldType, 'ResName:' $FieldRES, 'isDisplay:' $isAddDisplay

	if [[ ! "$isAddDisplay". = "N". ]]; then
	    field_new_layout
	fi


	#case $FieldType in
	#    Hidden)
	#    TextBox) field_text_modify_layout | sed "s/##FieldName_#/$(echo $FieldName)/g" ;;
	#    Text) field_text_modify_layout | sed "s/##FieldName_#/$(echo $FieldName)/g" ;;
	#    Date) templatefield_date | sed "s/##FieldName_#/$(echo $FieldName)/g" ;;
	#    *) ;;
	#esac
    done

    tailer_new_layout
}
