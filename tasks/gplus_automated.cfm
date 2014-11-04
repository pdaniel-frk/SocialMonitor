<cfsetting requesttimeout="9999">

<cfparam name="url.programId" default="">
<cfparam name="url.scheduleId" default="">
<cfset init("Schedules")>
<cfset getSchedule = oSchedules.getSchedules (
	service = 'GPlus',
	programId = url.programId,
	scheduleId = url.scheduleId,
	currentlyRunning = true
)>

<cfset init("GooglePlus")>

<cfif getSchedule.recordCount>

	<cfloop query="getSchedule">

		<cfset EOF = false>
		<cfset lc = 1>
		<cfset nextPageToken = "">
		<cfset minDate = getSchedule.startDate>
		<cfset sanityCheck = 50>

		<cfloop condition="NOT EOF">

			<cfset activities = oGPlus.getActivities(
				scheduleId=getSchedule.scheduleId,
				searchTerm = form.searchTerm,
				api_key = credentials.gplus.api_key,
				nextPageToken = nextPageToken,
				save_results = true
			)>

			<cfif structKeyExists(activities, "items")>

				<cfif not arrayLen(activities.items)>
					<cfset EOF = true>
				<cfelse>

					<cfloop from="1" to="#arrayLen(activities.items)#" index="i">

						<cfset activity = structGet("activities.items[#i#]")>

						<cfif findNoCase(form.searchTerm, activity.object.content)>

							<cfset activity = oGPlus.parseActivityObject(activity)>
							<cfset user = oGPlus.getPeople (
								userId=activity.actor.id,
								api_key=credentials.gplus.api_key,
								save_results = true
							)>

							<!--- get comments --->
							<cfset EOC = false>
							<cfset nextCommentPageToken = "">
							<cfset cc = 1>
							<cfset maxResults = 500>

							<cfloop condition="NOT EOC">

								<cfset comments = oGPlus.getComments (
									activityId = activity.id,
									api_key = credentials.gplus.api_key,
									maxResults = maxResults,
									pageToken = nextCommentPageToken
								)>

								<cfif structKeyExists(comments, "items") and arrayLen(comments.items)>

									<cfloop from="1" to="#arrayLen(comments.items)#" index="ci">

										<cfif structKeyExists(comments.items[ci], "object") and findNoCase(form.searchTerm, comments.items[ci].object.content)>

											<cfset comment = oGPlus.parseCommentObject(comments.items[ci])>
											<cfset oGPlus.insertComment(scheduleId=getSchedule.scheduleId, comment=comment)>

											<!--- get this comments author --->
											<cfset user = oGPlus.getPeople (
												userId = comment.actor.id,
												api_key = credentials.gplus.api_key,
												save_results = true
											)>

										</cfif>

										<cfif dateCompare(comment.published, minDate) lt 0>
											<p>comment results too stale</p>
											<cfset EOC = true>
										</cfif>

									</cfloop>

									<cfif arrayLen(comments.items) lt maxResults>
										<!--- this may not be accurate, as results are filtered (so 500 results may only return 499, but there could be more !) --->
									</cfif>

									<cfif not structKeyExists(comments, "nextPageToken")>
										<p>no comment next page token provided</p>
										<cfset EOC = true>
									<cfelse>
										<cfset nextCommentPageToken = comments.nextPageToken>
									</cfif>

									<cfif cc gte sanityCheck>
										<p>exceeded sanitiy check for comments</p>
										<cfset EOC = true>
									</cfif>

									<cfset cc += 1>

								<cfelse>

									<p>no comments on this activity</p>
									<cfset EOC = true>

								</cfif>

							</cfloop>

							<cfif dateCompare(activity.published, minDate) lt 0>
								<p>results too stale</p>
								<cfset EOF = true>
							</cfif>

						</cfif>

					</cfloop>

				</cfif>

				<cfif not structKeyExists(activities, "nextPageToken")>
					<p>no next page token provided</p>
					<cfset EOF = true>
				<cfelse>
					<cfset nextPageToken = activities.nextPageToken>
				</cfif>

				<cfif lc gte sanityCheck>
					<p>exceeded sanitiy check for activities</p>
					<cfset EOF = true>
				</cfif>

				<cfset lc += 1>

			<cfelse>
				<p>no items in activities</p>
				<cfset EOF = true>
			</cfif>

		</cfloop>

	</cfloop>

</cfif>
