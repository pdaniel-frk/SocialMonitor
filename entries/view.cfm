<cfset init("Programs")>
<cfset init("Schedules")>
<cfset init("Entries")>

<cfparam name="url.programId" default="">
<cfparam name="url.scheduleId" default="">
<cfset getPrograms = oPrograms.getPrograms(programId=url.programId)>
<cfset getSchedules = oSchedules.getSchedules(programId=url.programId, scheduleId=url.scheduleId)>

<h1 class="page-header">
	Collected Entries<cfif len(url.programId)> for <cfoutput>#getPrograms.name#</cfoutput></cfif>
	<span class="pull-right">
		<button class="btn btn-default btn-sm download-entries" data-programid="<cfoutput>#url.programId#</cfoutput>" data-scheduleid="<cfoutput>#url.scheduleId#</cfoutput>" data-service="" data-toggle="tooltip" data-placement="bottom" title="Download collected entries">
			<span class="glyphicon glyphicon-download-alt"></span>
		</button>
	</span>
</h1>

<div class="table-responsive"><!---  no-copy --->

	<table class="table table-striped" style="font-family:Arial;font-size:12px;">

		<thead>
			<tr>
				<th>#</th>
				<th>Program</th>
				<!--- <th>Schedule</th> --->
				<th>Service</th>
				<th>Entry Type</th>
				<th>Text</th>
				<th>User</th>
				<th>Date</th>
			</tr>
		</thead>

		<tbody>

			<cfset lc = 1>
			<cfloop query="getSchedules">
				<cfset getEntries = oEntries.getEntries (
					scheduleId = getSchedules.scheduleId,
					service = getSchedules.service
				)>

				<cfset programName = oPrograms.getPrograms(programId=getSchedules.programId).name>

				<cfif getEntries.recordCount>
					<cfloop query="getEntries">
						<cfoutput>
							<tr>
								<td>#lc#</td>
								<td><a href="#request.webRoot#schedules/?programId=#programId#">#programName#</a></td>
								<!--- <td>#getSchedules.name#</td> --->
								<td>#getSchedules.service#</td>
								<td>
									<cfif len(getEntries.link)>
										<a href="#getEntries.link#" target="_blank">
									</cfif>
									#getEntries.entryType#</a>
								</td>
								<td>#getEntries.text#</td>
								<td>
									<cfif len(getEntries.name)>#getEntries.name#<cfelse>#getEntries.firstName# #getEntries.lastName#</cfif> (#getEntries.userName#)
								</td>
								<td>#dateFormat(getEntries.entryDate, 'yyyy-mm-dd')# #timeFormat(getEntries.entryDate, 'HH:mm')#</td>
							</tr>
						</cfoutput>
						<cfset lc += 1>
						<!--- for future concern --->
						<!--- <cfif lc gte 25>
							<tr><td colspan="7" class="text-center">Results clipped. <a href="">Click here</a> to upgrade your subscription.</td></tr>
							<cfbreak>
							<cfset onRequestEnd(cgi.script_name)>
							<cfabort>
						</cfif> --->
					</cfloop>
				<cfelse>
					<tr><td colspan="7" class="text-center">No entries found.</td></tr>
				</cfif>
			</cfloop>

		</tbody>

	</table>

</div>