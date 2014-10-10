<cfprocessingdirective pageencoding="utf-8">
<cfset init("Schedules")>
<cfset init("Entries")>

<cfparam name="url.scheduleId" default="">
<cfset getSchedules = oSchedules.getSchedules(scheduleId=url.scheduleId)>

<cfif getSchedules.recordCount>

	<cfset init("POIUtility", "oReader", "BaseComponents")>
	<cfset reportColumns = "Schedule,Service,EntryType,Link,Text,User,Date">
	<cfset reportColumnTypes = "varchar,varchar,varchar,varchar,varchar,varchar,varchar">
	<cfset reportColumnNames = reportColumns>
	<cfset arrSheets = arrayNew(1)>

	<cfset lc = 1>

	<cfoutput query="getSchedules" group="service">

		<cfset entriesQry = QueryNew(reportColumns, reportColumnTypes)>

		<cfoutput>

			<cfset getEntries = oEntries.getEntries (
				scheduleId=getSchedules.scheduleId,
				service=getSchedules.service
			)>

			<cfloop query="getEntries">
				<cfset QueryAddRow(entriesQry)>
				<cfset QuerySetCell(entriesQry, "Schedule", getSchedules.name)>
				<cfset QuerySetCell(entriesQry, "Service", getSchedules.service)>
				<cfset QuerySetCell(entriesQry, "EntryType", getEntries.entryType)>
				<cfset QuerySetCell(entriesQry, "Link", getEntries.link)>
				<cfset QuerySetCell(entriesQry, "Text", getEntries.text)>
				<cfset QuerySetCell(entriesQry, "User", "#getEntries.firstName# #getEntries.lastName# (#getEntries.userName#)")>
				<cfset QuerySetCell(entriesQry, "Date", "#dateFormat(getEntries.entryDate, 'yyyy-mm-dd')# #timeFormat(getEntries.entryDate, 'HH:mm')#")>
			</cfloop>

		</cfoutput>

		<cfset arrSheets[lc] = oReader.GetNewSheetStruct()>
		<cfset arrSheets[lc].SheetName = getSchedules.service>
		<cfset arrSheets[lc].Query = entriesQry>
		<cfset arrSheets[lc].ColumnList = reportColumns>
		<cfset arrSheets[lc].ColumnNames = reportColumnNames>

		<cfset lc += 1>

	</cfoutput>

	<!--- <cfset strFileName = "mksocialmonitor_entries_#dateFormat(now(), 'mmddyyyy')#.xls"> --->
	<cfset strFileName = createUUID() & ".xls">

	<cfif not directoryExists(expandPath('files'))>
		<cfdirectory action="create" directory="#expandPath('files')#">
	</cfif>

	<cfset oReader.WriteExcel(
		FilePath = expandPath('files\#strFileName#'),
		Sheets = arrSheets,
		HeaderCSS = "font-weight:bold;"
	)>

	<cfheader name="Content-Disposition" value="inline; filename=#strFileName#">
	<cfcontent type="application/msexcel" file="#expandPath('files\#strFileName#')#" deletefile="true">

</cfif>