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

				<!--- set up some defaults for keys that might not exist or have value --->
				<cfset latitude = "">
				<cfset longitude = "">
				<cfset geo_type = "">
				<cfset place_id = "">
				<cfset place_full_name = "">
				<cfset image_url = "">
				<cfif isStruct(thisResult.geo)>
					<cfset latitude = thisResult.geo.coordinates[1]>
					<cfset longitude = thisResult.geo.coordinates[2]>
					<cfset geo_type = thisResult.geo.type>
				</cfif>
				<cfif isStruct(thisResult.place)>
					<cfset place_id = thisResult.place.id>
					<cfset place_full_name = thisResult.place.full_name>
				</cfif>
				<cfif structKeyExists(thisResult.entities, "media")>
					<cfset image_url = thisResult.entities.media[1].media_url_https>
				</cfif>

				<cfset init("Twitter")>
				<cfset oTwitter.insertTwitterEntry (
					scheduleId = getSchedule.scheduleId,
					searchTerm = getSchedule.searchTerm,
					Id = thisResult.id,
					id_str = thisResult.id_str,
					created_at = thisResult.created_at,
					favorite_count = thisResult.favorite_count,
					latitude = latitude,
					longitude = longitude,
					geo_type = geo_type,
					place_id = place_id,
					place_full_name = place_full_name,
					lang = thisResult.lang,
					retweet_count = thisResult.retweet_count,
					retweeted = thisResult.retweeted,
					text = thisResult.text,
					user_id = thisResult.user.id,
					image_url = image_url
				)>

				<cfset init("Users")>
				<cfset oUsers.insertTwitterUser (
					id = thisResult.user.id,
					id_str = thisResult.user.id_str,
					location = thisResult.user.location,
					name = thisResult.user.name,
					screen_name = thisResult.user.screen_name,
					url = thisResult.user.url
				)>

			</cfloop>

			<cfcatch type="any">
				<cfdump var="#cfcatch#">
			</cfcatch>

		</cftry>

	</cfloop>

</cfif>
