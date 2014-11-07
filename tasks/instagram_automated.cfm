<cfsetting requesttimeout="999">

<cfparam name="url.programId" default="">
<cfparam name="url.scheduleId" default="">
<cfset init("Schedules")>
<cfset getSchedule = oSchedules.getSchedules (
	service = 'Instagram',
	programId = url.programId,
	scheduleId = url.scheduleId,
	currentlyRunning = true
)>

<cfif getSchedule.recordCount>

	<cfloop query="getSchedule">

		<cfset getSchedule.searchTerm = replace(getSchedule.searchTerm, '##', '', 'All')><!--- using # or %23 leads to a 404; --->
		<!--- with no since_id, it'll crawl back FOREVER, so give it something reasonable as a minimum' --->
		<!--- <cfset since_id = "1405036800000"> ---><!--- select cast(abs(dateDiff(s, '2014-07-11', '1970-01-01')) as bigint)*1000 --->

		<cfset init("Instagram")>
		<cfset since_id = oInstagram.getSinceId (
			scheduleId = getSchedule.scheduleId,
			searchTerm = getSchedule.searchTerm
		)>

		<cfset min_tag_id = "#since_id#">
		<cfset max_tag_id = "">
		<cfset EOF = false>
		<cfset sanityCheck = 10>
		<cfset loopCount = 0>
		<cfset searchCount = 0>
		<cfset counter = 1>

		<cfloop condition="NOT EOF">

			<!--- the call will return up to 20(30?) of the most recently-tagged items, so we may need to work backward until were at or before the min_tag_id parameter --->
			<cfhttp method="get" url="https://api.instagram.com/v1/tags/#getSchedule.searchTerm#/media/recent?client_id=#credentials.instagram.client_id#&min_tag_id=#min_tag_id#&max_tag_id=#max_tag_id#&count=50"></cfhttp>
			<cfset result = deserializeJson(cfhttp.fileContent)>

			<cfif not structKeyExists(result, "error")>

				<cfif arrayLen(result.data)>

					<cfloop from="1" to="#arrayLen(result.data)#" index="ndx">

						<cftry>

							<cfset thisResult = structGet("result.data[#ndx#]")>
							<cfset instagram = oInstagram.parseInstagramObject(instagram=thisResult)>

							<cfset oInstagram.insertInstagramEntry (
								programId = getSchedule.programId,
								scheduleId = getSchedule.scheduleId,
								instagram = instagram
							)>

							<cfset init("Users")>
							<cfset oUsers.insertInstagramUser (
								user_id = instagram.user.id,
								bio = instagram.user.bio,
								full_name = instagram.user.full_name,
								profile_picture = instagram.user.profile_picture,
								username = instagram.user.username,
								website = instagram.user.website
							)>

							<cfcatch type="any">
								<cfdump var="#cfcatch#">
								<cfdump var="#result.data[ndx]#">
								<cfabort>
							</cfcatch>

						</cftry>

						<cfset counter += 1>

					</cfloop>

					<cfset loopCount += 1>
					<cfif loopCount gte sanityCheck>
						<cfset EOF = true>

						<div class="alert alert-warning">
							 <button type="button" class="close" data-dismiss="alert">&times;</button>
							 <cfoutput>Loop count exceeded sanity check for term #getSchedule.searchTerm#</cfoutput>
						</div>
					</cfif>

					<cfif structKeyExists(result.pagination, "next_max_id")>

						<cfset max_tag_id = result.pagination['next_max_id']>

						<cfif numberFormat(max_tag_id) LTE numberFormat(min_tag_id)>

							<cfset EOF = true>

						</cfif>

					<cfelse>

						<cfset EOF = true>

					</cfif>

				<cfelse>

					<cfset EOF = true>

				</cfif><!--- </cfif arrayLen(result.data)> --->

			<cfelse>

				<!--- handle errors as you see fit --->
				<cfdump var="#result#">
				<cfset EOF = true>

			</cfif><!--- </cfif not structKeyExists(result, "error")> --->

		</cfloop><!--- </cfloop condition="NOT EOF"> --->

	</cfloop>

</cfif>
