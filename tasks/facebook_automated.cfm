<cfsetting requesttimeout="9999">

<cfparam name="url.programId" default="">
<cfparam name="url.scheduleId" default="">
<cfset init("Schedules")>
<cfset getSchedule = oSchedules.getSchedules (
	service = 'Facebook',
	programId = url.programId,
	scheduleId = url.scheduleId,
	currentlyRunning = true
)>

<cfset init("Facebook")>

<cfif getSchedule.recordCount>

	<cfloop query="getSchedule">

		<!--- isnt this functionally the same as no 'until,' though? --->
		<cfset until = dateDiff('s', '1970-01-01', dateConvert('local2utc', now()))>
		<cfset since = oFacebook.getSince(getSchedule.scheduleId)>
		<cfparam name="url.sanityCheck" default=100>

		<!--- blind search, always --->
		<cfif len(getSchedule.searchTerm)>

			<p>blind search</p><cfabort>

			<cfset EOF = false>
			<cfset lc = 1>

			<cfloop condition="NOT EOF">

				<cfset search_result = oFacebook.searchFacebook (
					programId = getSchedule.programId,
					scheduleId = getSchedule.scheduleId,
					searchTerm = getSchedule.searchTerm,
					until = until,
					since = since,
					access_token = credentials.facebook.page_access_token,
					save_results = true
				)>

				<!--- <p><cfoutput>search #lc#</cfoutput></p> --->

				<cfif not structKeyExists(search_result, 'data')>
					<cfset EOF = true>
				<cfelse>
					<cfif not arrayLen(search_result.data)>
						<cfset EOF = true>
					<cfelse>
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

						<cfif lc gt val(url.sanityCheck)>
							<p>facebook search results exceeded page count sanity check</p>
							<cfset EOF = true>
						</cfif>

					</cfif>

				</cfif>

			</cfloop>

		</cfif>

		<!--- 'until' may be modified by the above block, so make sure its reset here, dawg! --->
		<cfset until = dateDiff('s', '1970-01-01', dateConvert('local2utc', now()))>

		<!--- search page (feeds, feed -> comments) for searchTerm --->
		<cfif len(getSchedule.searchTerm) and len(getSchedule.monitor_page_id)><!--- and not len(getSchedule.monitor_post_id) --->

			<p>search page for term</p><cfabort>

			<!--- get the page and store its deets --->
			<cfset page_result = oFacebook.getPage (
				programId = getSchedule.programId,
				scheduleId = getSchedule.scheduleId,
				pageId = getSchedule.monitor_page_id,
				searchTerm = getSchedule.searchTerm,
				until = until,
				since = since,
				access_token = credentials.facebook.page_access_token,
				save_results = true
			)>

			<!--- get feeds for the page --->
			<cfset EOF = false>
			<cfset lc = 1>

			<cfloop condition="NOT EOF">

				<!--- <p><cfoutput>feed #lc#</cfoutput></p> --->

				<cfset feed_result = oFacebook.getPageFeed (
					programId = getSchedule.programId,
					scheduleId = getSchedule.scheduleId,
					pageId = getSchedule.monitor_page_id,
					searchTerm = getSchedule.searchTerm,
					until = until,
					since = since,
					access_token = credentials.facebook.page_access_token,
					save_results = true
				)>

				<!--- <cfdump var="#feed_result#"><cfabort> --->

				<cfif structKeyExists(feed_result, "data") and arrayLen(feed_result.data)>

					<cfloop from="1" to="#arrayLen(feed_result.data)#" index="i">
						<cfset thisFeed = structGet('feed_result.data[#i#]')>
						<cfif structKeyExists(thisFeed, 'message')>
							<cfif findNoCase(getSchedule.searchTerm, thisFeed.message)>
								<!--- <p><cfoutput>#getSchedule.searchTerm# found in #thisFeed.message#. Checking this object's comments</cfoutput></p> --->
								<!--- get comments for the feed --->
								<cfset EOC = false>
								<cfset cc = 1>
								<cfset comment_until = until>
								<cfloop condition="NOT EOC">

									<!--- <p><cfoutput>feed comment #cc#</cfoutput></p> --->

									<cfset comment_result = oFacebook.getComments(
										programId = getSchedule.programId,
										scheduleId = getSchedule.scheduleId,
										id = thisFeed.id,
										searchTerm = getSchedule.searchTerm,
										until = comment_until,
										since = since,
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
									<cfif cc gt val(url.sanityCheck)>
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

					<cfif lc gt val(url.sanityCheck)>
						<p>facebook feed results exceeded page count sanity check</p>
						<cfset EOF = true>
					</cfif>

				<cfelse>
					<cfset EOF = true>
				</cfif>

			</cfloop>

		</cfif>

		<!--- search a certain post for comments (if no searchTerm is provided, gather all comments) --->
		<cfif len(getSchedule.monitor_post_id)>

			<!--- get the post and store its deets --->
			<cfset post_result = oFacebook.getPost (
				programId = getSchedule.programId,
				scheduleId = getSchedule.scheduleId,
				postId = getSchedule.monitor_post_id,
				searchTerm = getSchedule.searchTerm,
				access_token = credentials.facebook.page_access_token,
				save_results = true
			)>

			<!--- get comments for the post --->
			<cfset EOC = false>
			<cfset cc = 1>
			<cfset cp = 1>
			<cfset after = getSchedule.cursor_after>
			<cfloop condition="NOT EOC">

				<p><cfoutput>comment page #cp#</cfoutput></p>
				<p><cfoutput>after = #after#</cfoutput></p>

				<cfset comment_result = oFacebook.getComments(
					programId = getSchedule.programId,
					scheduleId = getSchedule.scheduleId,
					id = getSchedule.monitor_post_id,
					searchTerm = getSchedule.searchTerm,
					since = since,
					after = after,
					access_token = credentials.facebook.page_access_token,
					save_results = true
				)>

				<!--- results returned in chronological order now, so you could check timestamp of FIRST and LAST record in set --->

				<!--- <p><cfoutput>since = #since#</cfoutput></p>
				<p><cfoutput>first created_time = #comment_result.data[1].created_time#</cfoutput></p>
				<p><cfoutput>last created_time = #comment_result.data[arrayLen(comment_result.data)].created_time#</cfoutput></p>
				<cfdump var="#oFacebook.parseCommentObject(comment_result.data[1])#"><!--- parsing this will convert create_time from readable (but not usable) timestamp to unix seconds timestamp, but DOES NOT adjust for timezone --->
				<cfabort> --->

				<!--- note that FB changed the name or these cursors at some point... --->
				<cfif structKeyExists(comment_result, 'data') and arrayLen(comment_result.data)>
					<!--- <cfif arrayLen(comment_result.data)>
						<cfdump var="#comment_result#">
					</cfif> --->
					<cfif not structKeyExists(comment_result, "paging")>
						<cfset EOC = true>
					<cfelse>
						<cfif structKeyExists(comment_result.paging, "next")>
							<!--- extract 'after' from paging.next --->
							<!--- this is a bit awkward, as 'next' (usually, sometimes, maybe always) returns earlier results --->
							<cfset theUrl = comment_result.paging.next>
							<cfset theUrl = listRest(theUrl, '?')>
							<cfloop list="#theUrl#" index="u" delimiters="&">
								<cfif listFirst(u, "=") eq "after">
									<cfset after = listLast(u, "=")>
									<!--- store cursor in database so next iteration can start here --->
									<cfquery datasource="#this.dsn#">
										update Schedules
										set cursor_after = <cfqueryparam value="#after#" cfsqltype="cf_sql_varchar">
										where scheduleId = <cfqueryparam value="#getSchedule.scheduleId#" cfsqltype="cf_sql_integer">
									</cfquery>
								</cfif>
							</cfloop>
							<cfset cp += 1>
						<cfelse>
							<cfset EOC = true>
						</cfif>
					</cfif>

					<cfset cc += 1>
					<cfif cp gt val(url.sanityCheck)>
						<p>facebook post -> comments results exceeded page count sanity check</p>
						<cfset EOC = true>
					</cfif>

				<cfelse>
					<cfset EOC = true>
				</cfif>

			</cfloop>

		</cfif>

	</cfloop>

</cfif>
