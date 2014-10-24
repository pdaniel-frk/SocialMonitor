<cfset init("Schedules")>
<cfset init("Entries")>

<cfparam name="url.scheduleId" default="">
<cfset getSchedules = oSchedules.getSchedules(scheduleId=url.scheduleId)>

<h1 class="page-header">
	Collected Entries<cfif len(url.scheduleId)> for <cfoutput>#getSchedules.name#</cfoutput></cfif>
	<span class="pull-right">
		<button class="btn btn-default btn-sm download-entries" data-scheduleid="<cfoutput>#url.scheduleId#</cfoutput>" data-service="" data-toggle="tooltip" data-placement="bottom" title="Download collected entries">
			<span class="glyphicon glyphicon-download-alt"></span>
		</button>
	</span>
</h1>

<div class="table-responsive no-copy">

	<table class="table table-striped" style="font-family:Arial;font-size:12px;">

		<thead>
			<tr>
				<th>#</th>
				<th>Schedule</th>
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
					scheduleId=getSchedules.scheduleId,
					service=getSchedules.service
				)>

				<cfif getEntries.recordCount>
					<cfloop query="getEntries">
						<cfoutput>
							<tr>
								<td>#lc#</td>
								<td>#getSchedules.name#</td>
								<td>#getSchedules.service#</td>
								<td>
									<cfif len(getEntries.link)>
										<a href="#getEntries.link#" target="_blank">
									</cfif>
									#getEntries.entryType#</a>
								</td>
								<td>#getEntries.text#</td>
								<td>#getEntries.firstName# #getEntries.lastName# (#getEntries.userName#)</td>
								<td>#dateFormat(getEntries.entryDate, 'yyyy-mm-dd')# #timeFormat(getEntries.entryDate, 'HH:mm')#</td>
							</tr>
						</cfoutput>
						<cfset lc += 1>
						<cfif lc gte 25>
							<tr><td colspan="7" class="text-center">Results clipped. <a href="">Click here</a> to upgrade your subscription.</td></tr>
							<cfbreak>
							<cfset onRequestEnd(cgi.script_name)>
							<cfabort>
						</cfif>
					</cfloop>
				<cfelse>
					<tr><td colspan="7" class="text-center">No entries found.</td></tr>
				</cfif>
			</cfloop>

		</tbody>

	</table>

</div>