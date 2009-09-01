<%
Function Sales_PrintData()
    ON ERROR RESUME NEXT
    '==================================
    '以下為外部變數
    '==================================
    'intPageSize
    'intStartPage
    'intEndPage
    'strWhereClause
    'strFilterClause
    'strOrderByClause
    'strLanguage
    'strReportID
    'strTemplateID
    '==================================

    '***************************************************************************
    '                            執行權限檢查
    '***************************************************************************
    dim aryPerm, strProgID, i, j, strErrMsg
    strProgID = "Sales"

    '程式權限檢查 0=ExecPerm 1=AddPerm 2=ModifyPerm 3=DelPerm 4=PrintPerm 5=Ext1Perm 6=Ext2Perm 7=Ext3Perm 8=DataOwnerType
    aryPerm = sys_GetProgramPermission(strProgID,Session("s_EmplID"))
    if IsArray(aryPerm) = false then
        call sys_WriteActivityLog(2,"B3AFE355-D9D9-4311-8192-48F5BE3E6DDD","Can not found program permission definition of user.")
        strErrMsg = objKey.ReadResString("CAN_NOT_FIND_USERS_PERMISSION",Session("s_Language"),Session("s_EmplID"),strProgID)
        ReportTemplate_PrintData = strErrMsg
        Exit Function
    end if

    '如果是PowerUser，則擁有所有的權限
    if Session("s_PowerUser") = true then
        redim aryPerm(8): for i = 0 to 7 : aryPerm(i)=true :next :aryPerm(8)=9
    end if

    '必須有列印的權限才可以執行
    if aryPerm(4) = false then
        call sys_WriteActivityLog(2,"F8E8FF90-296F-46FF-A3B1-B46730957224","User doesn't has permission to print data.")
        strErrMsg = objKey.ReadResString("NO_PRINT_PERMISSION",Session("s_Language"))
        ReportTemplate_PrintData = strErrMsg
        Exit Function
    end if

    if err.number <> 0 then
        Response.Write err.description & "<br>E1EA8B49-A56C-4D93-97FC-1CD5EC1F16DE"
        Response.End
    end if

    '***************************************************************************
    '                            產生報表資料集
    '***************************************************************************
    dim strSQL, rst1, strPermRestrict, strXML
    strPermRestrict = ""

    '產生資料的SQL Command
    strSQL = "SELECT TOP " & Session("s_MaxRecord") & " *  FROM dbo.fn_Data_Sales('" & strLanguage & "')"

    strWhereClause = sys_VarReplace(strWhereClause)
    strFilterClause = sys_VarReplace(strFilterClause)

    if strFilterClause <> "" then
        if strWhereClause <> "" then
            if strPermRestrict = "" then
                strSQL = strSQL & " WHERE (" & strWhereClause & ") AND (" & strFilterClause & ") "
            else
                strSQL = strSQL & " WHERE (" & strPermRestrict & ") AND (" & strFilterClause & ") AND (" & strWhereClause & ")"
            end if
        else
            if strPermRestrict = "" then
                strSQL = strSQL & " WHERE " & strFilterClause
            else
                strSQL = strSQL & " WHERE (" & strPermRestrict & ") AND (" & strFilterClause & ")"
            end if
        end if
    else
        if strWhereClause <> "" then
            if strPermRestrict = "" then
                strSQL = strSQL & " WHERE " & strWhereClause
            else
                strSQL = strSQL & " WHERE (" & strPermRestrict & ") AND (" & strWhereClause & ")"
            end if
        else
            if strPermRestrict = "" then
                'DO NOTHING
            else
                strSQL = strSQL & " WHERE " & strPermRestrict
            end if
        end if
    end if

    if strOrderByClause <> "" then
        strSQL = strSQL & " ORDER BY " & strOrderByClause
    else
        strSQL = strSQL & " ORDER BY SalesID"
    end if

    if err.number <> 0 then
        Response.Write err.description & "<br>4A90FBC4-7612-4D50-9FB6-0815F6E3B4A1"
        Response.End
    end if

    'mydebug strSQL

    set rst1 = objPublic.CreateRecordset(strSQL, Application("a_CRMConnect"))

    if err.number <> 0 then
        Response.Write err.description & "<br>AF836989-AAEE-4EE6-92E1-570BF8E1746F"
        Response.End
    end if

    rst1.PageSize = cint(intPageSize)

    if cint(intEndPage) > cint(rst1.PageCount) then
        intEndPage = cint(rst1.PageCount)
    end if

    '*******************************************************************************************
    '                                 產生報表 XMLSource
    '*******************************************************************************************
    dim intDataFormat
    intDataFormat = sys_GetReportDataFormat(strReportID)

    strXML = "<?xml version='1.0' encoding='utf-8'?><Data>"
    strXML = strXML & sys_CreateReportLabels(intDataFormat)
    select case intDataFormat
        case 0: '0= Detail Format
            strXML = strXML & GenFormat0(rst1)
        case else       'Use Format(0) as default
            Response.Write objKey.ReadResString("REPORT_NOT_SUPPORT_THIS_DATA_FORMAT",Session("s_Language"),intDataFormat) & "," & objKey.ReadResString("REPORT_CHANGE_DATA_FORMAT_OF_REPORT_ID",Session("s_Language"),strReportID) & "<br>79A241C1-CD45-406E-8216-34AF14C15290"
            Response.End
    end select
    strXML = strXML & "</Data>"

    if err.number <> 0 then
        Response.Write err.description & "<br>79A241C1-CD45-406E-8216-34AF14C15290"
        Response.End
    end if

    Sales_PrintData = strXML
End Function

Function GenFormat0(rst1)
    ON ERROR RESUME NEXT
    '==================================
    '以下為外部變數
    '==================================
    'intPageSize
    'intStartPage
    'intEndPage
    'strLanguage
    '==================================

    '***產生報表所需的資料，使用Detail模式。
	dim strXML,i,j, strPageXML, strRecordXML
	strXML = "<Recordsets>"
	strXML = strXML & "<Recordset name='rs1' range='Y' master=''>"
	strXML = strXML & " <FieldDefine>"
	strXML = strXML & "  <Field name=""SalesID"" type=""Varchar""  />"
	strXML = strXML & "  <Field name=""SalesName"" type=""Varchar"" />"
	strXML = strXML & "  <Field name=""DutyDate"" type=""Varchar"" />"
	strXML = strXML & "  <Field name=""IsActive"" type=""Varchar"" />"
	strXML = strXML & "  <Field name=""IsAudit"" type=""Varchar"" />"
	strXML = strXML & "  <Field name=""ExtNotes"" type=""Varchar"" />"
	strXML = strXML & "  <Field name=""chkflag"" type=""Varchar"" />"
	strXML = strXML & " </FieldDefine>"
	strXML = strXML & " <Records>"

	if intStartPage > rst1.PageCount then intStartPage = rst1.PageCount
	if intEndPage > rst1.PageCount then	intEndPage = rst1.PageCount

	if rst1.PageCount = 0 then
    	' DO NOTHING
	else
	    for i = intStartPage to intEndPage
	        rst1.AbsolutePage = i
	        strPageXML=""
	        for j = 1 to intPageSize
	            if rst1.EOF = true then
	                exit for
	            end if
	            '產生資料錄
	            strRecordXML = "<Record>"
	            strRecordXML = strRecordXML & "<SalesID>" & sys_XMLEncode(rst1("SalesID").value) & "</SalesID>"
	            strRecordXML = strRecordXML & "<SalesName>" & sys_XMLEncode(rst1("SalesName").value) & "</SalesName>"
	            strRecordXML = strRecordXML & "<DutyDate>" & sys_XMLEncode(rst1("DutyDate").value) & "</DutyDate>"
	            if rst1("IsActive").value = true then
	                strRecordXML = strRecordXML & "<IsActive>Y</IsActive>"
	            else
	                strRecordXML = strRecordXML & "<IsActive>N</IsActive>"
	            end if
	 	        if rst1("IsAudit").value = true then
	                strRecordXML = strRecordXML & "<IsAudit>Y</IsAudit>"
	            else
	                strRecordXML = strRecordXML & "<IsAudit>N</IsAudit>"
	            end if

				strRecordXML = strRecordXML & "<ExtNotes>" & sys_XMLEncode(rst1("ExtNotes").value) & "</ExtNotes>"
	            strRecordXML = strRecordXML & "<chkflag>" & sys_XMLEncode(rst1("chkflag").value) & "</chkflag>"
	            strRecordXML = strRecordXML & "</Record>"

		   strPageXML = strPageXML & strRecordXML

	            if err.number <> 0 then
	                Response.Write err.description & "<br>19578CAD-4591-4E3F-BAEE-C3B1B1A8BD2F"
	                Response.End
	            end if

	            '移動到下一筆
	            rst1.MoveNext
	        next
                 strXML = strXML & strPageXML
	    next
	end if
    strXML = strXML & " </Records>"
    strXML = strXML & "</Recordset>"
    strXML = strXML & "</Recordsets>"

    if err.number <> 0 then
        Response.Write err.description & "<br>B43978BA-6F02-4E06-B660-83F19BA24F32"
        Response.End
    end if
    GenFormat0 = strXML
End Function
%>
