
header_new_layout() {
cat <<EOF
<!--'Code Generated by: "$BASH_SOURCE" -->
<table cellpadding=3 cellspacing=0 border=0 style='margin-left:10px;margin-top:10px'>
EOF
}

header_pkey_layout() {
if [ "$KEY_MULTY". = "". ] ; then
cat <<EOF
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
cat <<EOF
<!-- FD: ${FieldTitle} -->
<tr>
    <td align='right' nowrap>
        <%=objKey.ReadResString("${FieldRES}",Session("s_Language"))%>:</td>
    <td><font color='darkblue'>#</font></td>

    <td>
    <!-- td nowrap colspan=4 -->
EOF

if [ "$IsOpenWIN". = "Y". ]; then
    if [ "$ResOpenWIN". = "Date". ]; then
cat <<EOF
    <input id='${FieldName}' type='${FieldType}' class='clsEditField' size=10 maxlength=10 accessKey='D'
        onchange='jscript:sys_Check${ResOpenWIN}Field("${FieldName}");sys_SetDataModified();' >
    <button class='clsIconButton' style='height:18px;width:18px' language='jscript'
        onmouseover='this.className="clsIconButtonOver";' onmouseout='this.className="clsIconButton";'
        title='<%=objKey.ReadResString("CHOICE_$(echo ${ResOpenWIN}|tr [:lower:] [:upper:])", Session("s_Language"))%>'
	onclick='sys_Choice${ResOpenWIN}("${FieldName}",document.all["${FieldName}"].value);' <%=strHideButton%> >
	<img src='/GDCRM/images/sys_tool_day31b.gif' border=0 align=absmiddle>
    </button>
EOF
    else
cat <<EOF
    <input id='${FieldName}' type='${FieldType}' class='clsEditField' size=10 maxlength=10 accessKey='D'
        onchange='jscript:sys_Check${ResOpenWIN}ID(true,"${FieldName}","${AltField}","");sys_SetDataModified();' >
    <button class='clsIconButton' style='height:18px;width:18px' language='jscript'
        onmouseover='this.className="clsIconButtonOver";' onmouseout='this.className="clsIconButton";'
        title='<%=objKey.ReadResString("CHOICE_$(echo ${ResOpenWIN}|tr [:lower:] [:upper:])", Session("s_Language"))%>'
        onclick='sys_Choice${ResOpenWIN}("${FieldName}","${AltField}","");'>
        <img src='/GDCRM/images/sys_tool_Dept.gif' border=0 align=absmiddle>
    </button>
    <!-- Display Field -->
    <input id='${AltField}' type='text' class='clsLockField' readonly size=25>
EOF
    fi
else
    if [ "$IsOpenWIN". = "P". ]; then
cat <<EOF
    <select id='${FieldName}' name='${FieldName}' <%=strReadOnlyTAG2%> onchange='jscript:sys_SetDataModified();'>
EOF

	for opt in $(echo $ResString | sed 's/-/ /g') ; do
	    optid=$(echo $opt | gawk -F ':' '{print $1}')
	    optval=$(echo $opt | gawk -F ':' '{print $2}')
	    optstr=$(echo $opt | gawk -F ':' '{print $3}')
cat <<EOF
	<option id='${optid}' value='${optval}'>${optstr}
EOF
	done
cat <<EOF
	</select>
EOF
    else
cat <<EOF
    <input id='${FieldName}' type='${FieldType}' name='${FieldName}' class='clsEditField' 
	size='15' maxlength='10' onchange='jscript:sys_SetDataModified();'>
EOF
    fi
fi

cat <<EOF
    </td>
</tr>
EOF

}

tailer_new_layout() {
cat <<EOF
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
	IsOpenWIN=$(echo $fd | gawk -F "/" '{print $16}')
	ResString=$(echo $fd | gawk -F "/" '{print $17}')
	#ResOpenWIN=$(echo $ResString | gawk -F "/" '{print $17}'| sed 's/:.*$//g')
	ResOpenWIN=$(echo $ResString | sed 's/:.*$//g')
	AltField=$(echo $fd | gawk -F "/" '{print $18}')
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