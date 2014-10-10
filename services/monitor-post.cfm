<cfif not structKeyExists(form, "__token") or form.__token neq session.stamp>
	<!--- csrf attempt --->
	<cfset onRequestEnd(cgi.script_name)>
	<cfabort>
</cfif>

<cfparam name="form.scheduleId" default="">
<cfparam name="form.name" default="">
<cfparam name="form.postId" default="">
<cfparam name="form.searchTerm" default="">
<cfparam name="form.userId" default="">
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

<cfif not len(form.scheduleId) and len(form.postId)>

	<cfset scheduleId = oSchedules.insertSchedule (
		name = form.name,
		service = 'Facebook',
		searchTerm = form.searchTerm,
		monitor_post_id = form.postId,
		startDate = form.startDate,
		endDate = form.endDate
	)>

	<!--- until the process runs and gets some results for this post, nothing will show up on the schedule --->

<cfelseif len(form.scheduleId)>

	<cfset oSchedules.updateSchedule (
		scheduleId = form.scheduleId,
		name = form.name,
		searchTerm = form.searchTerm,
		monitor_post_id = form.postId,
		startDate = form.startDate,
		endDate = form.endDate
	)>

</cfif>