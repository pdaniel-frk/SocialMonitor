<cfparam name="url.scheduleId" default="">

<cfquery name="getSchedules" datasource="#this.dsn#">
	select
		s.scheduleId,
		s.name,
		s.[service],
		s.monitor_page_id,
		s.monitor_post_id,
		s.searchTerm,
		s.startDate,
		s.endDate
	from Schedules s
	where isdate(s.deleteDate) = 0
	<cfif len(url.scheduleId)>
		and s.scheduleId = <cfqueryparam value="#val(url.scheduleId)#" cfsqltype="cf_sql_integer">
	</cfif>
	order by
		s.service,
		s.startDate,
		s.endDate
</cfquery>

<div class="table-responsive">

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

			<cfoutput query="getSchedules" group="service">

				<cfoutput>

					<cfif service eq "Facebook">

						<cfquery name="getEntries" datasource="#this.dsn#">
							select e.text,
								dateadd(s, e.time, '1970-01-01') as entryDate,
								u.*
							from FacebookPostComments e
							inner join uvwSelectFacebookUsers u on e.fromid = u.user_id
							where e.scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer">
						</cfquery>

						<cfloop query="getEntries">

							<tr>
								<td>#lc#</td>
								<td>#getSchedules.name#</td>
								<td>#getSchedules.service#</td>
								<td>Comment</td>
								<td>#getEntries.text#</td>
								<td>#getEntries.first_name# #getEntries.last_name# (#getEntries.username#)</td>
								<td>#dateFormat(getEntries.entryDate, 'yyyy-mm-dd')# #timeFormat(getEntries.entryDate, 'HH:mm')#</td>
							</tr>

							<cfset lc += 1>

						</cfloop>

						<cfquery name="getEntries" datasource="#this.dsn#">
							select u.*
								<!--- either dont know or not storing date of 'like' --->
							from FacebookPostLikes e
							inner join uvwSelectFacebookUsers u on e.user_id = u.user_id
							where e.scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer">
						</cfquery>

						<cfloop query="getEntries">

							<tr>
								<td>#lc#</td>
								<td>#getSchedules.name#</td>
								<td>#getSchedules.service#</td>
								<td>Like</td>
								<td></td>
								<td>#getEntries.first_name# #getEntries.last_name# (#getEntries.username#)</td>
								<td></td>
							</tr>

							<cfset lc += 1>

						</cfloop>

					</cfif>

					<cfif service eq "Twitter">

						<cfquery name="getEntries" datasource="#this.dsn#">
							select e.text,
								<!--- e.created_at as entryDate, --->
								dateAdd(hh, -4, cast(substring(e.created_at, 5, 6) + ' ' + right(e.created_at, 4) + ' ' + substring(e.created_at, 12, 8) as datetime)) as entryDate,
								u.*
							from TwitterEntries e
							inner join uvwSelectTwitterUsers u on e.[user.id] = u.user_id
							where e.scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer">
						</cfquery>

						<cfloop query="getEntries">

							<tr>
								<td>#lc#</td>
								<td>#getSchedules.name#</td>
								<td>#getSchedules.service#</td>
								<td>Tweet</td>
								<td>#getEntries.text#</td>
								<td>#getEntries.first_name# #getEntries.last_name# (#getEntries.username#)</td>
								<td>#dateFormat(getEntries.entryDate, 'yyyy-mm-dd')# #timeFormat(getEntries.entryDate, 'HH:mm')#</td>
							</tr>

							<cfset lc += 1>

						</cfloop>

					</cfif>

					<cfif service eq "Instagram">

						<cfquery name="getEntries" datasource="#this.dsn#">
							select e.[caption.text] as text,
								e.link,
								dateAdd(s, e.created_time, '1970-01-01') as entryDate,
								u.*
							from InstagramEntries e
							inner join uvwSelectInstagramUsers u on e.[user.id] = u.user_id
							where e.scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer">
						</cfquery>

						<cfloop query="getEntries">

							<tr>
								<td>#lc#</td>
								<td>#getSchedules.name#</td>
								<td>#getSchedules.service#</td>
								<td><a href="#getEntries.link#" target="_blank">Photo</a></td>
								<td>#getEntries.text#</td>
								<td>#getEntries.first_name# #getEntries.last_name# (#getEntries.username#)</td>
								<td>#getEntries.entryDate#</td>
							</tr>

							<cfset lc += 1>

						</cfloop>

					</cfif>

					<cfif service eq "Vine">

						<cfquery name="getEntries" datasource="#this.dsn#">
							select e.[description] as text,
								e.permaLinkUrl,
								e.created as entryDate,
								u.*
							from VineEntries e
							inner join uvwSelectVineUsers u on e.userId = u.user_id
							where e.scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer">
						</cfquery>

						<cfloop query="getEntries">

							<tr>
								<td>#lc#</td>
								<td>#getSchedules.name#</td>
								<td>#getSchedules.service#</td>
								<td><a href="#getEntries.permaLinkUrl#" target="_blank">Video</a></td>
								<td>#getEntries.text#</td>
								<td>#getEntries.first_name# #getEntries.last_name# (#getEntries.username#)</td>
								<td>#getEntries.entryDate#</td>
							</tr>

							<cfset lc += 1>

						</cfloop>

					</cfif>

				</cfoutput>

			</cfoutput>

		</tbody>

	</table>

</div>