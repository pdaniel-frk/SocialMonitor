<cfsetting requesttimeout="999">

<cfparam name="url.programId" default="">
<cfparam name="url.scheduleId" default="">
<cfset init("Schedules")>
<cfset getSchedule = oSchedules.getSchedules (
	service = 'Twitter',
	programId = url.programId,
	scheduleId = url.scheduleId,
	currentlyRunning = false
)>

<cfif getSchedule.recordCount>

	<cfloop query="getSchedule">

		<cfset init("Twitter")>
		<cfset since_id = oTwitter.getSinceId (
			programId = getSchedule.programId,
			scheduleId = getSchedule.scheduleId,
			searchTerm = getSchedule.searchTerm
		)>
		<cfset q = URLEncodedFormat(getSchedule.searchTerm)>

		<cftry>

			<cfset searchResult =  application.objMonkehTweet.search(q=q, since_id=since_id, count=100)>

			<cfset searchCount = 0>

			<cfset searchCount += arrayLen(searchResult.statuses)>

			<cfloop from="1" to="#arrayLen(searchResult.statuses)#" index="ndx">

				<cfset thisResult = structGet("searchResult.statuses[#ndx#]")>
				<cfset tweet = oTwitter.parseTweetObject(tweet=thisResult)>

				<cfset init("Twitter")>
				<cfset oTwitter.insertTwitterEntry (
					programId = getSchedule.programId,
					scheduleId = getSchedule.scheduleId,
					searchTerm = getSchedule.searchTerm,
					tweet = tweet
				)>

				<cfset init("Entrants")>
				<cfset oEntrants.insertTwitterUser (
					id = tweet.user.id,
					id_str = tweet.user.id_str,
					location = tweet.user.location,
					name = tweet.user.name,
					screen_name = tweet.user.screen_name,
					url = tweet.user.url
				)>

			</cfloop>

			<cfcatch type="any">
				<cfdump var="#cfcatch#">
			</cfcatch>

		</cftry>

	</cfloop>

</cfif>
