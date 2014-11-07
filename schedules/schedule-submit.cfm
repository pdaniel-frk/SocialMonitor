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
		<cfset schedule = oSchedules.getSchedules (
			programId = form.programId,
			name = form.name,
			service = service
		)>
		<cfif schedule.recordCount>
			<!--- alert submitter? --->
		<cfelse>
			<!--- create the schedule --->
			<cfset oSchedules.insertSchedule (
				programId = form.programId,
				name = form.name,
				searchTerm = form.searchTerm,
				startDate = form.startDate,
				endDate = form.endDate,
				service = service
			)>
		</cfif>

	</cfloop>

	<div class="alert alert-success">
		<button type="button" class="close" data-dismiss="alert">&times;</button>
		Your schedule(s) have been created.
	</div>

	<!--- show progress bar --->
	<div class="progress progress-striped progress-success active">
		<div class="progress-bar" style="width: 100%;"></div>
	</div>

	<script type="text/javascript">
		window.setTimeout( function() {  location='index.cfm?programId=<cfoutput>#form.programId#</cfoutput>' }, 3000 );
	</script>

	<cfset onRequestEnd(cgi.script_name)>
	<cfabort>

</cfif>

<cfif listLen(errorFields)>

	<script>
		$(function(){
			$('.form-errors').fadeIn('slow');
		});
	</script>

</cfif>