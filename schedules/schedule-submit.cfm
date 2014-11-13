<cfif not structKeyExists(form, "__token") or form.__token neq session.stamp>
	<!--- csrf attempt --->
	<cfset onRequestEnd(cgi.script_name)>
	<cfabort>
</cfif>

<cfif not len(form.programId)>
    <cfset errorFields = listAppend(errorFields, "programId")>
</cfif>
<cfif not len(form.name)>
    <cfset errorFields = listAppend(errorFields, "name")>
</cfif>
<cfif not len(form.searchTerm)>
    <cfset errorFields = listAppend(errorFields, "searchTerm")>
</cfif>
<cfif not isDate(form.startDate)>
	<cfset errorFields = listAppend(errorFields, "startDate")>
</cfif>
<cfif not len(form.service)>
    <cfset errorFields = listAppend(errorFields, "service")>
</cfif>

<cfif not listLen(errorFields)>

	<cfloop list="#form.service#" index="service">

		<!--- see if this schedule already exists --->
		<cfset init("Schedules")>

		<cfif structKeyExists(form, "scheduleId") and len(form.scheduleId)>

			<cfset oSchedules.updateSchedule (
				scheduleId = form.scheduleId,
				programId = form.programId,
				name = form.name,
				searchTerm = form.searchTerm,
				startDate = form.startDate,
				endDate = form.endDate,
				service = service
			)>

		<cfelse>

			<cfset schedule = oSchedules.getSchedules (
				programId = form.programId,
				name = form.name,
				service = service
			)>
			<cfif schedule.recordCount>
				<cfset errorFields = listAppend(errorFields, "alreadyExists")>
			<cfelse>
				<!--- create the schedule --->
				<cfset scheduleId = oSchedules.insertSchedule (
					programId = form.programId,
					name = form.name,
					searchTerm = form.searchTerm,
					startDate = form.startDate,
					endDate = form.endDate,
					service = service
				)>
			</cfif>

		</cfif>

	</cfloop>

</cfif>

<cfif listLen(errorFields)>

	<script>
		$(function(){
			<cfif listFindNoCase(errorFields, "alreadyExists")>
				$('.schedule-exists').show();
			</cfif>
			$('.form-errors').fadeIn('slow');
		});
	</script>

<cfelse>

	<cfif structKeyExists(form, "scheduleId") and len(form.scheduleId)>
		<cfset message = "Your schedule has been updated.">
	<cfelse>
		<cfset message = "Your schedule(s) have been created.">
	</cfif>

	<cfset reRoute(destination="index.cfm?programId=#form.programId#", message=message)>

</cfif>