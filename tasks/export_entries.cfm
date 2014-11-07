<cfprocessingdirective pageencoding="utf-8">
<cfset init("Programs")>
<cfset init("Schedules")>
<cfset init("Entries")>

<cfparam name="url.programId" default="">
<cfparam name="url.scheduleId" default="">
<cfset schedule = oSchedules.getSchedules(programId=url.programId, scheduleId=url.scheduleId)>

<cfif schedule.recordCount>

	<cfset init("POIUtility", "oReader", "BaseComponents")>
	<cfset reportColumns = "Program,Schedule,Service,EntryType,Link,Text,User,Date">
	<cfset reportColumnTypes = "varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar">
	<cfset reportColumnNames = reportColumns>
	<cfset arrSheets = arrayNew(1)>

	<cfset lc = 1>

	<cfoutput query="schedule" group="service">

		<cfset entriesQry = QueryNew(reportColumns, reportColumnTypes)>

		<cfoutput>

			<cfset entry = oEntries.getEntries (
				programId = schedule.programId,
				scheduleId = schedule.scheduleId,
				service = schedule.service
			)>

			<cfset program = oPrograms.getPrograms(scheduleId=schedule.scheduleId)>

			<cfloop query="entry">
				<cfset QueryAddRow(entriesQry)>
				<cfset QuerySetCell(entriesQry, "Program", program.name)>
				<cfset QuerySetCell(entriesQry, "Schedule", schedule.name)>
				<cfset QuerySetCell(entriesQry, "Service", schedule.service)>
				<cfset QuerySetCell(entriesQry, "EntryType", entry.entryType)>
				<cfset QuerySetCell(entriesQry, "Link", entry.link)>
				<cfset QuerySetCell(entriesQry, "Text", entry.text)>
				<cfset QuerySetCell(entriesQry, "User", "#entry.firstName# #entry.lastName# (#entry.userName#)")>
				<cfset QuerySetCell(entriesQry, "Date", "#dateFormat(entry.entryDate, 'yyyy-mm-dd')# #timeFormat(entry.entryDate, 'HH:mm')#")>
			</cfloop>

		</cfoutput>

		<cfset arrSheets[lc] = oReader.GetNewSheetStruct()>
		<cfset arrSheets[lc].SheetName = schedule.service>
		<cfset arrSheets[lc].Query = entriesQry>
		<cfset arrSheets[lc].ColumnList = reportColumns>
		<cfset arrSheets[lc].ColumnNames = reportColumnNames>

		<cfset lc += 1>

	</cfoutput>

	<!--- <cfset strFileName = "mksocialmonitor_entries_#dateFormat(now(), 'mmddyyyy')#.xls"> --->
	<!--- <cfset strFileName = createUUID() & ".xls"> --->
	<cfset strFileName = REReplaceNoCase(generateSecretKey("AES"), "[^A-Za-z0-9]", "", "ALL") & ".xls">
	<!--- <cfset strFileName = REReplaceNoCase(generateSecretKey("DES"), "[^A-Za-z0-9]", "", "ALL") & ".xls"> --->
	<!--- <cfset strFileName = REReplaceNoCase(generateSecretKey("DESEDE"), "[^A-Za-z0-9]", "", "ALL") & ".xls"> --->

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