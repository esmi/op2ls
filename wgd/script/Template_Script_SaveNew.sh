
header_script_savenew() {
cat <<-EOF
<script language='jscript.encode'>
function Save() {               //儲存
    if (g_blnChanged == false) {return;}
    if (sys_CheckAsyncCall() == false) {return;}
    if (CheckFields() != true) {return;}
	
    var aryRecord = new Array();
    var aryField = new Array();
	
    //產生欄位資料的Record陣列
    var n=0;
    var strTemp;
EOF
}

body_script_savenew() {
cat <<-EOF
    //將資料放入aryReocrd[]陣列中
    aryRecord[0]=aryField;

    //將資料陣列轉換成XML
    var strXML = sys_ArrayToXML(aryRecord);

    //將轉換好的XML載入到DOMDocument之中
    var xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
    xmlDoc.async = false;
    xmlDoc.loadXML(strXML)  ;

    if (xmlDoc.parseError.errorCode != 0) {
        alert("<%=objKey.ReadResString("FUNCTION_CALL_ERROR",Session("s_Language"),"Save()")%>");
        return;
    }
    sys_SaveNewData(xmlDoc);
}

function CheckFields() {            //欄位檢查
    var strErrMsg = "";

    //檢查不可空白的欄位
    strErrMsg += sys_CheckStringBlank("##PKEY_#","<%=objKey.ReadResString("##PKEY_#",Session("s_Language"))%>");

    //檢查Textarea欄位的長度限制
    //strErrMsg += sys_CheckStringLength("ExtNotes",255,"<%=objKey.ReadResString("REMARK",Session("s_Language"))%>");

    //*** check error message
    if (strErrMsg != "") {
        alert(strErrMsg);
        return(false);
    }
    else {
        return(true);
    }
}
EOF
}
tailer_script_savenew() {
cat <<-EOF
</script>
EOF
}
field_script_savenew() {
cat <<-EOF
    aryField[n++]=new Array("##FieldName_#",document.all['##FieldName_#'].value);
EOF
}

clearfield_script_savenew() {
cat <<-EOF
    document.all['##FieldName_#'].value= "";
EOF
}

clear_all_field_script_savenew() {
cat <<-EOF
function ClearField() {
EOF
   
    if [ ! "$KEY_TYPE". = "MULTY_KEY". ] ; then 
	clearfield_script_savenew | sed "s/##FieldName_#/$(echo $PKEY)/g"
    fi
    for fd in $(echo $FIELDS ) ; do
	FieldName=$(echo $fd | gawk -F "/" '{print $1}')
	FieldType=$(echo $fd | gawk -F "/" '{print $2}')
	if [ ! "$FieldType". = "System". ] ; then
	    clearfield_script_savenew | sed "s/##FieldName_#/$(echo $FieldName)/g"
	fi
    done

cat <<-EOF
}
EOF
}

template_script_savenew() {
    header_script_savenew

    field_script_savenew | sed "s/##FieldName_#/$(echo $PKEY)/g"
    for fd in $(echo $FIELDS ) ; do
	FieldName=$(echo $fd | gawk -F "/" '{print $1}')
        FieldType=$(echo $fd | gawk -F "/" '{print $2}')
        FieldTitle=$(echo $fd | gawk -F "/" '{print $7}')
        FieldRES=$(echo $fd | gawk -F "/" '{print $14}')
        isAddDisplay=$(echo $fd | gawk -F "/" '{print $9}')


	if [ ! "$FieldType" = "System" ] ; then
	    if [ ! "$FieldType". = "Hidden". ] ; then
		echo 1>&2 "FD:" $FieldName
		field_script_savenew | sed "s/##FieldName_#/$(echo $FieldName)/g"
	    fi
	fi
    done

    body_script_savenew | sed "s/##PKEY_#/$(echo $PKEY)/g"
    clear_all_field_script_savenew
    tailer_script_savenew
}
