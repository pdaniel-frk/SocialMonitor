<cfsetting requesttimeout="999">

<cfparam name="url.scheduleId" default="">
<cfset init("Schedules")>
<cfset getSchedule = oSchedules.getSchedules (
	service = 'Facebook',
	scheduleId = url.scheduleId,
	currentlyRunning = true
)>

<cfset init("Facebook")>

<cfif getSchedule.recordCount>

	<cfloop query="getSchedule">

		<cfset until = ''>

		<cfif len(getSchedule.searchTerm) and not len(getSchedule.monitor_page_id) and not len(getSchedule.monitor_post_id)>

			<cfset EOF = false>
			<cfset lc = 1>

			<cfloop condition="NOT EOF">

				<cfset search_result = oFacebook.searchFacebook (
					scheduleId = getSchedule.scheduleId,
					searchTerm = getSchedule.searchTerm,
					until = until,
					access_token = credentials.facebook.page_access_token,
					save_results = true
				)>

				<!--- NOTE: I SHOULD PROBABLY BE CONVERTING THESE DATES FROM GMT TO EST --->
				<cfset created_time = search_result.data[1].created_time>
				<cfset created_date_time = oFacebook.convertCreatedTimeToString(created_time, true)>
				<cfif dateCompare(created_date_time, getSchedule.startDate) LT 0>
					<cfset EOF = true>
				</cfif>

				<cfif arrayLen(search_result.data) LT 25>
					<cfset EOF = true>
				</cfif>

				<cfif not structKeyExists(search_result, "paging")>
					<cfset EOF = true>
				<cfelse>
					<cfif structKeyExists(search_result.paging, "next")>
						<!--- extract 'until' from paging.next --->
						<!--- this is a bit awkward, as 'next' (usually, sometimes, maybe always) returns earlier results --->

						<cfset theUrl = search_result.paging.next>
						<cfset theUrl = listRest(theUrl, '?')>
						<cfloop list="#theUrl#" index="u" delimiters="&">
							<cfif listFirst(u, "=") eq "until">
								<cfset until = listLast(u, "=")>
							</cfif>
						</cfloop>
					<cfelse>
						<cfset EOF = true>
					</cfif>
				</cfif>

				<cfset lc += 1>

				<cfif lc gte 100>
					<p>facebook search results exceeded page count sanity check</p>
					<cfset EOF = true>
				</cfif>

			</cfloop>

		</cfif>


		<cfif len(getSchedule.monitor_page_id) and not len(getSchedule.monitor_post_id)>

			<!--- get the page and store its deets --->
			<cfset page_result = oFacebook.getPage (
				scheduleId = getSchedule.scheduleId,
				pageId = getSchedule.monitor_page_id,
				searchTerm = getSchedule.searchTerm,
				until = until,
				access_token = credentials.facebook.page_access_token,
				save_results = true
			)>

			<!--- get feeds for the page --->
			<cfset EOF = false>
			<cfset lc = 1>

			<cfloop condition="NOT EOF">

				<cfset feed_result = oFacebook.getPageFeed (
					scheduleId = getSchedule.scheduleId,
					pageId = getSchedule.monitor_page_id,
					searchTerm = getSchedule.searchTerm,
					until = until,
					access_token = credentials.facebook.page_access_token,
					save_results = true
				)>

				<!--- <cfdump var="#feed_result#"> --->

				<cfloop from="1" to="#arrayLen(feed_result.data)#" index="i">
					<cfset thisFeed = structGet('feed_result.data[#i#]')>
					<cfif structKeyExists(thisFeed, 'message')>
						<cfif findNoCase(getSchedule.searchTerm, thisFeed.message)>
							<p><cfoutput>#getSchedule.searchTerm# found in #thisFeed.message#. Checking this object's comments</cfoutput></p>
							<!--- get comments for the feed --->
							<cfset EOC = false>
							<cfset cc = 1>
							<cfset comment_until = until>
							<cfloop condition="NOT EOC">
								<cfset comment_result = oFacebook.getComments(
									scheduleId = getSchedule.scheduleId,
									id = thisFeed.id,
									searchTerm = getSchedule.searchTerm,
									until = comment_until,
									access_token = credentials.facebook.page_access_token,
									save_results = true
								)>
								<!--- <cfif arrayLen(comment_result.data)>
									<cfdump var="#comment_result#">
								</cfif> --->
								<cfif not structKeyExists(comment_result, "paging")>
									<cfset EOC = true>
								<cfelse>
									<cfif structKeyExists(comment_result.paging, "next")>
										<!--- extract 'until' from paging.next --->
										<!--- this is a bit awkward, as 'next' (usually, sometimes, maybe always) returns earlier results --->
										<cfset theUrl = comment_result.paging.next>
										<cfset theUrl = listRest(theUrl, '?')>
										<cfloop list="#theUrl#" index="u" delimiters="&">
											<cfif listFirst(u, "=") eq "until">
												<cfset comment_until = listLast(u, "=")>
											</cfif>
										</cfloop>
									<cfelse>
										<cfset EOC = true>
									</cfif>
								</cfif>

								<cfset cc += 1>
								<cfif cc gte 100>
									<p>facebook feed -> comment exceeded page count sanity check</p>
									<cfset EOC = true>
								</cfif>
							</cfloop>

						</cfif>
					</cfif>
				</cfloop>

				<cfif not structKeyExists(feed_result, "paging")>
					<cfset EOF = true>
				<cfelse>
					<cfif structKeyExists(feed_result.paging, "next")>
						<!--- extract 'until' from paging.next --->
						<!--- this is a bit awkward, as 'next' (usually, sometimes, maybe always) returns earlier results --->
						<cfset theUrl = feed_result.paging.next>
						<cfset theUrl = listRest(theUrl, '?')>
						<cfloop list="#theUrl#" index="u" delimiters="&">
							<cfif listFirst(u, "=") eq "until">
								<cfset until = listLast(u, "=")>
							</cfif>
						</cfloop>
					<cfelse>
						<cfset EOF = true>
					</cfif>
				</cfif>

				<cfset lc += 1>

				<cfif lc gte 100>
					<p>facebook feed results exceeded page count sanity check</p>
					<cfset EOF = true>
				</cfif>

			</cfloop>

		</cfif>


		<cfif len(getSchedule.monitor_post_id)>

			<!--- get the post and store its deets --->
			<cfset post_result = oFacebook.getPost (
				scheduleId = getSchedule.scheduleId,
				postId = getSchedule.monitor_post_id,
				searchTerm = getSchedule.searchTerm,
				until = until,
				access_token = credentials.facebook.page_access_token,
				save_results = true
			)>

			<!--- get comments for the post --->
			<cfset EOC = false>
			<cfset cc = 1>
			<cfset comment_until = until>
			<cfloop condition="NOT EOC">
				<cfset comment_result = oFacebook.getComments(
					scheduleId = getSchedule.scheduleId,
					id = getSchedule.monitor_post_id,
					searchTerm = getSchedule.searchTerm,
					until = comment_until,
					access_token = credentials.facebook.page_access_token,
					save_results = true
				)>
				<!--- <cfif arrayLen(comment_result.data)>
					<cfdump var="#comment_result#">
				</cfif> --->
				<cfif not structKeyExists(comment_result, "paging")>
					<cfset EOC = true>
				<cfelse>
					<cfif structKeyExists(comment_result.paging, "next")>
						<!--- extract 'until' from paging.next --->
						<!--- this is a bit awkward, as 'next' (usually, sometimes, maybe always) returns earlier results --->
						<cfset theUrl = comment_result.paging.next>
						<cfset theUrl = listRest(theUrl, '?')>
						<cfloop list="#theUrl#" index="u" delimiters="&">
							<cfif listFirst(u, "=") eq "until">
								<cfset comment_until = listLast(u, "=")>
							</cfif>
						</cfloop>
					<cfelse>
						<cfset EOC = true>
					</cfif>
				</cfif>

				<cfset cc += 1>
				<cfif cc gte 100>
					<p>facebook post -> comments results exceeded page count sanity check</p>
					<cfset EOC = true>
				</cfif>
			</cfloop>

		</cfif>

	</cfloop>

</cfif>
