<cfif not structKeyExists(form, "__token") or form.__token neq session.stamp>
	<!--- csrf attempt --->
	<cfset onRequestEnd(cgi.script_name)>
	<cfabort>
</cfif>
<cfparam name="form.scheduleId" default="">
<cfset init("Schedules")>
<cfset oSchedules.updateSchedule (
	scheduleId = form.scheduleId,
	monitor_page_id = -1
)>