<cfif not structKeyExists(form, "__token") or form.__token neq session.stamp>
	<!--- csrf attempt --->
	<cfset onRequestEnd(cgi.script_name)>
	<cfabort>
</cfif>

<cfparam name="form.programId" default="">
<cfparam name="form.scheduleId" default="">
<cfparam name="form.name" default="">
<cfparam name="form.searchTerm" default="">
<cfparam name="form.startDate" default="#now()#">
<cfparam name="form.endDate" default="">
<cfparam name="form.stopMonitor" default="false">
<cfif isdate(form.endDate)>
	<cfset form.endDate = "#dateFormat(form.endDate, 'yyyy-mm-dd')# 23:59:59">
</cfif>
<cfif form.stopMonitor eq 'true'>
	<cfset form.endDate = dateAdd("d", -1, now())>
</cfif>

<cfset init("Schedules")>

<cfif not len(form.scheduleId) and len(form.searchTerm)>

	<cfset scheduleId = oSchedules.insertSchedule (
		programId = form.programId,
		name = form.name,
		service = 'Twitter',
		searchTerm = form.searchTerm,
		startDate = form.startDate,
		endDate = form.endDate
	)>

<cfelseif len(form.scheduleId)>

	<cfset oSchedules.updateSchedule (
		programId = form.programId,
		scheduleId = form.scheduleId,
		name = form.name,
		searchTerm = form.searchTerm,
		startDate = form.startDate,
		endDate = form.endDate
	)>

</cfif>
