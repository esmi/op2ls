
header_script_savemodify() {
cat <<-EOF
<script language='jscript.encode'>

<!-- header_script_savemodify() -->

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

tailer_script_savemodify() {
cat <<-EOF

//<!-- tailer_script_savemodify() -->

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
    sys_SaveModifiedData(xmlDoc);
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
</script>
EOF
}

field_script_savemodify() {
cat <<-EOF
    aryField[n++]=new Array("##FieldName_#",document.all['##FieldName_#'].value);
EOF
}

template_script_savemodify() {
    header_script_savemodify
    echo '//<!-- field_script_savemodify(): $PKEY -->'
    field_script_savemodify | sed "s/##FieldName_#/$(echo $PKEY)/g"
    echo '//<!-- field_script_savemodify(): $FIELDS -->'
    for fd in $(echo $FIELDS ) ; do
	FieldName=$(echo $fd | gawk -F "/" '{print $1}')
	field_script_savemodify | sed "s/##FieldName_#/$(echo $FieldName)/g"
    done

    tailer_script_savemodify | sed "s/##PKEY_#/$(echo $PKEY)/g"

}
