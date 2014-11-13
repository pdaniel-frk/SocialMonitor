<cfif not structKeyExists(form, "__token") or form.__token neq session.stamp>
	<!--- csrf attempt --->
	<cfset onRequestEnd(cgi.script_name)>
	<cfabort>
</cfif>

<cfif not len(form.name)>
    <cfset errorFields = listAppend(errorFields, "name")>
</cfif>
<cfif not isDate(form.startDate)>
	<cfset errorFields = listAppend(errorFields, "startDate")>
</cfif>

<cfif not listLen(errorFields)>
	<cfset init("Programs")>
	<cfif not structKeyExists(form, "programId")>
		<cfset programId = oPrograms.getPrograms(name=form.name, customerId=session.customerId).Id>
		<cfif len(programId)>
			<cfset errorFields = listAppend(errorFields, "alreadyExists")>
		<cfelse>
			<cfset programId = oPrograms.insertProgram (
				customerId = session.customerId,
				userId = session.userId,
				name = form.name,
				description = form.description,
				startDate = form.startDate,
				endDate = form.endDate
			)>
			<cflocation url="#request.webRoot#schedules/add-schedule.cfm?programId=#programId#" addtoken="no">
		</cfif>
	<cfelse>
		<cfset oPrograms.updateProgram (
			programId = form.programId,
			customerId = session.customerId,
			userId = session.userId,
			name = form.name,
			description = form.description,
			startDate = form.startDate,
			endDate = form.endDate
		)>
		<cflocation url="index.cfm" addtoken="no">
	</cfif>
</cfif>

<cfif listLen(errorFields)>

	<script>
		$(function(){
			<cfif listFindNoCase(errorFields, "alreadyExists")>
				$('.program-exists').show();
			</cfif>
			$('.form-errors').fadeIn('slow');
		});
	</script>

</cfif>