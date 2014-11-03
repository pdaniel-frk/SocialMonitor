<cfcomponent displayname="Facebook Components" output="no" hint="Mostly for saving FB search results">

	<cffunction name="init" output="no">

		<!--- define arguments --->
		<cfargument name="dsn" required="true" type="string">

		<!--- set variables scope --->
		<cfset variables.dsn = arguments.dsn>
		<!--- <cfset variables.api_url = "https://graph.facebook.com/v2.1/"> --->
		<cfset variables.api_url = "https://graph.facebook.com/v2.2/">
		<!--- note this version will be completely deprecated on or about 2015-04-01 --->
		<cfset variables.legacy_api_url = "https://graph.facebook.com/v1.0/">
		<cfset variables.unversioned_api_url = "https://graph.facebook.com/">

		<!--- some usefuls --->
		<!--- https://developers.facebook.com/docs/graph-api/using-graph-api/v2.1#paging --->

		<cfreturn this>

	</cffunction>


	<cffunction name="getPage" output="no">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="pageId" required="no" default="">
		<cfargument name="searchTerm" required="no" default="">
		<cfargument name="until" required="no" default="">
		<cfargument name="since" required="no" default="">
		<cfargument name="limit" required="no" default=25>
		<cfargument name="access_token" required="no" default="">
		<cfargument name="save_results" required="no" default=false>

		<cfif len(arguments.pageId)>

			<cfhttp url="#variables.api_url##arguments.pageId#" method="get" charset="utf-8">
				<cfhttpparam type="url" name="access_token" value="#arguments.access_token#">
				<cfhttpparam type="url" name="until" value="#arguments.until#">
				<cfhttpparam type="url" name="since" value="#arguments.since#">
				<cfhttpparam type="url" name="limit" value="#arguments.limit#">
				<cfhttpparam type="url" name="fields" value="id,category,checkins,description,likes,link,name,username">
			</cfhttp>

			<cfset page_result = deserializeJson(cfhttp.fileContent)>

			<cfif arguments.save_results>

				<cfif not structKeyExists(page_result, 'error')>

					<cfset page = parsePageObject(page_result)>

					<cfset insertFacebookPage (
						programId = arguments.programId,
						scheduleId = arguments.scheduleId,
						page = page
					)>

				</cfif>

			</cfif>

		<cfelseif len(arguments.searchTerm)>

			<cfhttp url="#variables.api_url#search/" method="get" charset="utf-8">
				<cfhttpparam type="url" name="access_token" value="#arguments.access_token#">
				<cfhttpparam type="url" name="q" value="#arguments.searchTerm#">
				<cfhttpparam type="url" name="until" value="#arguments.until#">
				<cfhttpparam type="url" name="since" value="#arguments.since#">
				<cfhttpparam type="url" name="limit" value="#arguments.limit#">
				<cfhttpparam type="url" name="type" value="page">
				<cfhttpparam type="url" name="fields" value="id,category,checkins,description,likes,link,name,username">
			</cfhttp>

			<cfset page_result = deserializeJson(cfhttp.fileContent)>

			<cfif arguments.save_results>

				<cfif not structKeyExists(page_result, 'error')>

					<cfloop from="1" to="#arrayLen(page_result.data)#" index="i">

						<cfset page = parsePageObject(page_result.data[i])>

						<cfset insertFacebookPage (
							programId = arguments.programId,
							scheduleId = arguments.scheduleId,
							page = page
						)>

					</cfloop>

				</cfif>

			</cfif>

		<cfelse>
			<cfreturn "{}">
		</cfif>

		<cftry>

			<cfreturn page_result>

			<cfcatch type="any">
				<cfreturn '{"error": true}'>
			</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="getPageName" output="no">

		<cfargument name="pageId" required="yes">
		<cfargument name="access_token" required="no" default="">

		<cfhttp url="#variables.api_url##arguments.pageId#" method="get" charset="utf-8">
			<cfhttpparam type="url" name="access_token" value="#arguments.access_token#">
			<cfhttpparam type="url" name="fields" value="name">
		</cfhttp>

		<cftry>

			<cfreturn deserializeJson(cfhttp.fileContent).name>

			<cfcatch type="any">
				<cfreturn "">
			</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="getPageFeed" output="yes">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="pageId" required="yes">
		<cfargument name="searchTerm" required="no" default="">
		<cfargument name="until" required="no" default="">
		<cfargument name="since" required="no" default="">
		<cfargument name="limit" required="no" default=25>
		<cfargument name="access_token" required="no" default="">
		<cfargument name="save_results" required="no" default=false>

		<cfhttp url="#variables.api_url##arguments.pageId#/feed" method="get" charset="utf-8">
			<cfhttpparam type="url" name="access_token" value="#arguments.access_token#">
			<cfhttpparam type="url" name="until" value="#arguments.until#">
			<cfhttpparam type="url" name="since" value="#arguments.since#">
			<cfhttpparam type="url" name="limit" value="#arguments.limit#">
			<cfhttpparam type="url" name="fields" value="id,from,message,type,status_type,object_id,created_time,shares,likes">
		</cfhttp>

		<cftry>

			<cfset feed_result = deserializeJson(cfhttp.fileContent)>

			<cfif arguments.save_results and len(arguments.searchTerm) and structKeyExists(feed_result, "data")>
				<!--- save feed results that have a message includeing the search term --->
				<cfloop from="1" to="#arrayLen(feed_result.data)#" index="i">
					<cfset thisFeed = structGet('feed_result.data[#i#]')>
					<cfif structKeyExists(thisFeed, 'message')>
						<cfif findNoCase(arguments.searchTerm, thisFeed.message)>

							<cfset feed = parsePageFeedObject(thisFeed)>

							<cfset insertFacebookPageFeed (
								programId = arguments.programId,
								scheduleId = arguments.scheduleId,
								pageId = arguments.pageId,
								feed = feed
							)>

							<cfset getUser (
								id = feed.from.id,
								access_token = arguments.access_token,
								save_results = arguments.save_results
							)>

						</cfif>
					</cfif>
				</cfloop>
			</cfif>

			<cfreturn feed_result>

			<cfcatch type="any">
				<cfdump var="#cfcatch#">
				<cfreturn '{"error": true}'>
			</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="getPost" output="yes">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="postId" required="yes">
		<cfargument name="until" required="no" default="">
		<cfargument name="since" required="no" default="">
		<cfargument name="limit" required="no" default=25>
		<cfargument name="access_token" required="no" default="">
		<cfargument name="save_results" required="no" default=false>

		<cfhttp url="#variables.api_url##arguments.postId#" method="get" charset="utf-8">
			<cfhttpparam type="url" name="access_token" value="#arguments.access_token#">
			<cfhttpparam type="url" name="until" value="#arguments.until#">
			<cfhttpparam type="url" name="since" value="#arguments.since#">
			<cfhttpparam type="url" name="limit" value="#arguments.limit#">
			<cfhttpparam type="url" name="fields" value="id,from,message,type,status_type,object_id,created_time,shares,likes">
		</cfhttp>

		<cftry>

			<cfset post_result = deserializeJson(cfhttp.fileContent)>

			<cfif arguments.save_results>

				<cfif not structKeyExists(post_result, 'error')>

					<cfset post = parsePostObject(post_result)>

					<!--- get likes for this post --->
					<cfset postLikes = getLikes (
						id = post.id,
						access_token = arguments.access_token
					)>
					<cfif structKeyExists(postLikes, "summary") and structKeyExists(postLikes.summary, "total_count")>
						<cfset post.likes.count = postLikes.summary.total_count>
					</cfif>

					<cfset insertFacebookPost (
						programId = arguments.programId,
						scheduleId = arguments.scheduleId,
						post = post
					)>

					<cfset getUser (
						id = post.from.id,
						access_token = arguments.access_token,
						save_results = arguments.save_results
					)>

				</cfif>

			</cfif>

			<cfreturn post_result>

			<cfcatch type="any">
				<cfdump var="#cfcatch#">
				<cfreturn '{"error": true}'>
			</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="getComments" output="yes">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="searchTerm" required="no" default="">
		<cfargument name="id" required="yes">
		<cfargument name="until" required="no" default="">
		<cfargument name="since" required="no" default="">
		<cfargument name="limit" required="no" default=25>
		<cfargument name="access_token" required="no" default="">
		<cfargument name="save_results" required="no" default=false>

		<cfhttp url="#variables.api_url##arguments.id#/comments" method="get" charset="utf-8">
			<cfhttpparam type="url" name="access_token" value="#arguments.access_token#">
			<cfhttpparam type="url" name="until" value="#arguments.until#">
			<cfhttpparam type="url" name="since" value="#arguments.since#">
			<cfhttpparam type="url" name="limit" value="#arguments.limit#">
			<cfhttpparam type="url" name="fields" value="id,from,message,created_time,like_count">
		</cfhttp>

		<cftry>

			<cfset comment_result = deserializeJson(cfhttp.fileContent)>

			<cfif arguments.save_results and structKeyExists(comment_result, "data")><!---  and len(arguments.searchTerm) --->
				<!--- save feed results that have a message includeing the search term --->
				<cfloop from="1" to="#arrayLen(comment_result.data)#" index="i">
					<cfset thisComment = structGet('comment_result.data[#i#]')>
					<cfif structKeyExists(thisComment, 'message')>
						<cfif not len(arguments.searchTerm) or findNoCase(arguments.searchTerm, thisComment.message)>

							<cfset comment = parseCommentObject(thisComment)>

							<cfset insertFacebookPostComment (
								programId = arguments.programId,
								scheduleId = arguments.scheduleId,
								comment = comment
							)>

							<cfset getUser (
								id = comment.from.id,
								access_token = arguments.access_token,
								save_results = arguments.save_results
							)>

						</cfif>
					</cfif>
				</cfloop>
			</cfif>

			<cfreturn comment_result>

			<cfcatch type="any">
				<cfdump var="#cfcatch#">
				<cfreturn '{"error": true}'>
			</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="getUser" output="yes">

		<cfargument name="Id" required="yes">
		<cfargument name="access_token" required="no" default="">
		<cfargument name="save_results" required="no" default=false>

		<cfhttp url="#variables.legacy_api_url##arguments.Id#" method="get" charset="utf-8">
			<cfhttpparam type="url" name="access_token" value="#arguments.access_token#">
		</cfhttp>

		<cftry>

			<cfset user_result = deserializeJson(cfhttp.fileContent)>

			<cfif arguments.save_results>

				<cfset user = parseUserObject(user_result)>

				<cfset insertFacebookUser (
					user = user
				)>

			</cfif>

			<cfreturn user_result>

			<cfcatch type="any">
				<cfdump var="#cfcatch#">
				<cfreturn '{"error": true}'>
			</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="getLikes" output="no">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="id" required="yes">
		<cfargument name="until" required="no" default="">
		<cfargument name="since" required="no" default="">
		<cfargument name="limit" required="no" default=25>
		<cfargument name="access_token" required="no" default="">
		<cfargument name="save_results" required="no" default=false>

		<!--- their documentation for v2.2 SAYS that a total_count field will be returned, but so far, this is UNTRUE! --->
		<!--- https://developers.facebook.com/docs/graph-api/reference/v2.2/object/likes --->
		<cfhttp url="#variables.api_url##arguments.id#/likes" method="get" charset="utf-8">
			<cfhttpparam type="url" name="access_token" value="#arguments.access_token#">
			<cfhttpparam type="url" name="until" value="#arguments.until#">
			<cfhttpparam type="url" name="since" value="#arguments.since#">
			<cfhttpparam type="url" name="limit" value="#arguments.limit#">
			<cfhttpparam type="url" name="summary" value="1">
			<cfhttpparam type="url" name="fields" value="id,name">
		</cfhttp>

		<cftry>

			<cfreturn deserializeJson(cfhttp.fileContent)>

			<cfcatch type="any">
				<cfreturn '{"error": true}'>
			</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="searchFacebook" output="yes">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="searchTerm" required="yes">
		<cfargument name="until" required="no" default="">
		<cfargument name="since" required="no" default="">
		<cfargument name="limit" required="no" default=25>
		<cfargument name="access_token" required="no" default="">
		<cfargument name="save_results" required="no" default=false>

		<!--- note this uses a different api version, as current versions return (#11) Post search has been deprecated --->
		<!--- https://graph.facebook.com/ --->
		<cfhttp method="get" url="#variables.unversioned_api_url#search">
			<cfhttpparam type="url" name="q" value="#arguments.searchTerm#">
			<cfhttpparam type="url" name="access_token" value="#arguments.access_token#">
			<cfhttpparam type="url" name="type" value="post">
			<cfhttpparam type="url" name="until" value="#arguments.until#">
			<cfhttpparam type="url" name="since" value="#arguments.since#">
			<cfhttpparam type="url" name="limit" value="#arguments.limit#">
			<cfhttpparam type="url" name="fields" value="id,from,story,picture,link,message,name,caption,type,status_type,object_id,created_time">
		</cfhttp>

		<cftry>

			<cfset search_result = deserializeJson(cfhttp.fileContent)>

			<cfif arguments.save_results>

				<cfif structKeyExists(search_result, 'data')>

					<cfloop from="1" to="#arrayLen(search_result.data)#" index="i">

						<cfset thisResult = structGet('search_result.data[#i#]')>

						<cfset thisResult = parseSearchObject(thisResult)>

						<cfset insertFacebookSearchResult (
							programId = arguments.programId,
							scheduleId = arguments.scheduleId,
							search = thisResult
						)>

						<cfset getUser (
							id = thisResult.from.id,
							access_token = arguments.access_token,
							save_results = arguments.save_results
						)>

					</cfloop>

				</cfif>

			</cfif>

			<cfreturn search_result>

			<cfcatch type="any">
				<cfdump var="#thisResult#">
				<cfdump var="#cfcatch#">
				<cfreturn '{"error": true}'>
			</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="getSince" output="no" returntype="numeric">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="searchTerm" required="no" default="">

		<cfquery name="getSince" datasource="#variables.dsn#">
			select coalesce(
				datediff(s, '1970-01-01', max(entryDate)),
				<cfif len(arguments.programId)>
					(
						select datediff(s, '1970-01-01', startDate)
						from Programs
						where Id = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
					)
				<cfelseif len(arguments.scheduleId)>
					(
						select datediff(s, '1970-01-01', startDate)
						from Schedules
						where scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
					)
				<cfelse>
					0
				</cfif>
			) as since
			from uvwSelectFacebookEntries
			where 1=1
			<cfif len(arguments.scheduleId)>
				and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif len(arguments.searchTerm)>
				and searchTerm = <cfqueryparam value="#arguments.searchTerm#" cfsqltype="cf_sql_varchar">
			</cfif>
		</cfquery>

		<cfreturn getSince.since>

	</cffunction>


	<cffunction name="insertFacebookPostComment" output="no" returntype="void">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" default="">
		<cfargument name="comment" required="yes" type="struct">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from FacebookComments
				where id = <cfqueryparam value="#arguments.comment.id#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.programId)>
					and programId = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
				<cfelseif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin

				insert into FacebookComments (
					programId,
					scheduleId,
					id,
					[from.id],
					[from.name],
					message,
					created_time,
					like_count,
					comment_count
				)
				values (
					<cfqueryparam value="#arguments.programId#" null="#not len(arguments.programId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.comment.id#" null="#not len(arguments.comment.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.comment.from.id#" null="#not len(arguments.comment.from.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.comment.from.name#" null="#not len(arguments.comment.from.name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.comment.message#" null="#not len(arguments.comment.message)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.comment.created_time#" null="#not len(arguments.comment.created_time)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.comment.like_count#" null="#not len(arguments.comment.like_count)#" cfsqltype="cf_sql_int">,
					<cfqueryparam value="#arguments.comment.comment_count#" null="#not len(arguments.comment.comment_count)#" cfsqltype="cf_sql_int">
				)

			end

		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="insertFacebookLike" output="no" returntype="void">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" default="">
		<cfargument name="pageId" default="#getToken(arguments.postId, 1, '_')#">
		<cfargument name="postId" default="">
		<cfargument name="id" default="">
		<cfargument name="name" default="">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from FacebookLikes
				where post_id = <cfqueryparam value="#arguments.postId#" cfsqltype="cf_sql_varchar">
				and user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.programId)>
					and programId = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
				<cfelseif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin
				insert into FacebookLikes (
					programId,
					scheduleId,
					pageId,
					postId,
					id,
					name
				)
				values (
					<cfqueryparam value="#arguments.programId#" null="#not len(arguments.programId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.pageId#" null="#not len(arguments.pageId)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.postId#" null="#not len(arguments.postId)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.id#" null="#not len(arguments.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.name#" null="#not len(arguments.name)#" cfsqltype="cf_sql_varchar">
				)
			end
		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="insertFacebookSearchResult" output="no" returntype="void">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" default="">
		<cfargument name="search" required="yes" type="struct">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from FacebookSearches
				where id = <cfqueryparam value="#arguments.search.id#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.programId)>
					and programId = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
				<cfelseif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin

				insert into FacebookSearches (
					programId,
					scheduleId,
					id,
					[from.id],
					[from.name],
					message,
					story,
					picture,
					link,
					name,
					caption,
					type,
					status_type,
					object_id,
					created_time
				)
				values (
					<cfqueryparam value="#arguments.programId#" null="#not len(arguments.programId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.search.id#" null="#not len(arguments.search.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.search.from.id#" null="#not len(arguments.search.from.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.search.from.name#" null="#not len(arguments.search.from.name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.search.message#" null="#not len(arguments.search.message)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.search.story#" null="#not len(arguments.search.story)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.search.picture#" null="#not len(arguments.search.picture)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.search.link#" null="#not len(arguments.search.link)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.search.name#" null="#not len(arguments.search.name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.search.caption#" null="#not len(arguments.search.caption)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.search.type#" null="#not len(arguments.search.type)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.search.status_type#" null="#not len(arguments.search.status_type)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.search.object_id#" null="#not len(arguments.search.object_id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.search.created_time#" null="#not len(arguments.search.created_time)#" cfsqltype="cf_sql_bigint">
				)

			end

		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="insertFacebookPage" output="no" returntype="void">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" default="">
		<cfargument name="page" required="yes" type="struct">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from FacebookPages
				where id = <cfqueryparam value="#arguments.page.id#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.programId)>
					and programId = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
				<cfelseif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin

				insert into FacebookPages (
					programId,
					scheduleId,
					id,
					category,
					checkins,
					description,
					likes,
					link,
					name,
					username
				)
				values (
					<cfqueryparam value="#arguments.programId#" null="#not len(arguments.programId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.page.id#" null="#not len(arguments.page.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.page.category#" null="#not len(arguments.page.category)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.page.checkins#" null="#not len(arguments.page.checkins)#" cfsqltype="cf_sql_int">,
					<cfqueryparam value="#arguments.page.description#" null="#not len(arguments.page.description)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.page.likes#" null="#not len(arguments.page.likes)#" cfsqltype="cf_sql_int">,
					<cfqueryparam value="#arguments.page.link#" null="#not len(arguments.page.link)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.page.name#" null="#not len(arguments.page.name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.page.username#" null="#not len(arguments.page.username)#" cfsqltype="cf_sql_varchar">
				)

			end

			else
				begin

					update FacebookPages
					set modifyDate = getdate(),
					checkins = <cfqueryparam value="#arguments.page.checkins#" null="#not len(arguments.page.checkins)#" cfsqltype="cf_sql_int">,
					likes = <cfqueryparam value="#arguments.page.likes#" null="#not len(arguments.page.likes)#" cfsqltype="cf_sql_int">
					where id = <cfqueryparam value="#arguments.page.id#" cfsqltype="cf_sql_varchar">

				end

		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="insertFacebookPageFeed" output="no" returntype="void">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" default="">
		<cfargument name="pageId" default="">
		<cfargument name="feed" required="yes" type="struct">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from FacebookPageFeeds
				where id = <cfqueryparam value="#arguments.feed.id#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.programId)>
					and programId = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
				<cfelseif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin

				insert into FacebookPageFeeds (
					programId,
					scheduleId,
					pageId,
					id,
					[from.name],
					[from.id],
					message,
					type,
					link,
					name,
					caption,
					created_time
				)
				values (
					<cfqueryparam value="#arguments.programId#" null="#not len(arguments.programId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.pageId#" null="#not len(arguments.pageId)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.feed.id#" null="#not len(arguments.feed.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.feed.from.name#" null="#not len(arguments.feed.from.name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.feed.from.id#" null="#not len(arguments.feed.from.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.feed.message#" null="#not len(arguments.feed.message)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.feed.type#" null="#not len(arguments.feed.type)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.feed.link#" null="#not len(arguments.feed.link)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.feed.name#" null="#not len(arguments.feed.name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.feed.caption#" null="#not len(arguments.feed.caption)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.feed.created_time#" null="#not len(arguments.feed.created_time)#" cfsqltype="cf_sql_bigint">
				)

			end

		</cfquery>

	</cffunction>


	<cffunction name="insertFacebookPost" output="yes" returntype="void">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" default="">
		<cfargument name="pageId" default="">
		<cfargument name="post" required="yes" type="struct">

		<cfif not len(arguments.pageId)>
			<cfset arguments.pageId = getToken(arguments.post.id, 1, '_')>
		</cfif>

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from FacebookPosts
				where id = <cfqueryparam value="#arguments.post.id#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.programId)>
					and programId = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
				<cfelseif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin

				insert into FacebookPosts (
					programId,
					scheduleId,
					pageId,
					id,
					[from.name],
					[from.id],
					message,
					type,
					status_type,
					object_id,
					created_time,
					[shares.count],
					[likes.count]
				)
				values (
					<cfqueryparam value="#arguments.programId#" null="#not len(arguments.programId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.pageId#" null="#not len(arguments.pageId)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.post.id#" null="#not len(arguments.post.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.post.from.name#" null="#not len(arguments.post.from.name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.post.from.id#" null="#not len(arguments.post.from.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.post.message#" null="#not len(arguments.post.message)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.post.type#" null="#not len(arguments.post.type)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.post.status_type#" null="#not len(arguments.post.status_type)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.post.object_id#" null="#not len(arguments.post.object_id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.post.created_time#" null="#not len(arguments.post.created_time)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.post.shares.count#" null="#not len(arguments.post.shares.count)#" cfsqltype="cf_sql_int">,
					<cfqueryparam value="#arguments.post.likes.count#" null="#not len(arguments.post.likes.count)#" cfsqltype="cf_sql_int">
				)

			end

			else

				begin

					update FacebookPosts
					set modifyDate = getdate(),
					[shares.count] = <cfqueryparam value="#arguments.post.shares.count#" null="#not len(arguments.post.shares.count)#" cfsqltype="cf_sql_int">,
					[likes.count] = <cfqueryparam value="#arguments.post.likes.count#" null="#not len(arguments.post.likes.count)#" cfsqltype="cf_sql_int">
					where id = <cfqueryparam value="#arguments.post.id#" null="#not len(arguments.post.id)#" cfsqltype="cf_sql_varchar">

				end

		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="insertFacebookUser" output="no" returntype="void">

		<cfargument name="user" required="yes" type="struct">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from FacebookUsers
				where id = <cfqueryparam value="#arguments.user.id#" cfsqltype="cf_sql_varchar">
			)
			begin

				insert into FacebookUsers (
					id,
					[age_range.min],
					[age_range.max],
					birthday,
					email,
					first_name,
					gender,
					last_name,
					link,
					locale,
					middle_name,
					name,
					timezone,
					username
				)
				values (
					<cfqueryparam value="#arguments.user.id#" null="#not len(arguments.user.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user.age_range.min#" null="#not len(arguments.user.age_range.min)#" cfsqltype="cf_sql_int">,
					<cfqueryparam value="#arguments.user.age_range.max#" null="#not len(arguments.user.age_range.max)#" cfsqltype="cf_sql_int">,
					<cfqueryparam value="#arguments.user.birthday#" null="#not len(arguments.user.birthday)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user.email#" null="#not len(arguments.user.email)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user.first_name#" null="#not len(arguments.user.first_name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user.gender#" null="#not len(arguments.user.gender)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user.last_name#" null="#not len(arguments.user.last_name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user.link#" null="#not len(arguments.user.link)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user.locale#" null="#not len(arguments.user.locale)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user.middle_name#" null="#not len(arguments.user.middle_name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user.name#" null="#not len(arguments.user.name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user.timezone#" null="#not len(arguments.user.timezone)#" cfsqltype="cf_sql_int">,
					<cfqueryparam value="#arguments.user.username#" null="#not len(arguments.user.username)#" cfsqltype="cf_sql_varchar">
				)

			end

			else

				begin

					update FacebookUsers
					set username = <cfqueryparam value="#arguments.user.username#" null="#not len(arguments.user.username)#" cfsqltype="cf_sql_varchar">
					where id = <cfqueryparam value="#arguments.user.id#" cfsqltype="cf_sql_varchar">

				end

		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="parseSearchObject" output="yes" returntype="struct">

		<cfargument name="search" required="yes" type="struct">

		<!--- set up defaults --->
		<cfset local.search.id = "">
		<cfset local.search.from.id = "">
		<cfset local.search.from.name = "">
		<cfset local.search.message = "">
		<cfset local.search.story = "">
		<cfset local.search.picture = "">
		<cfset local.search.link = "">
		<cfset local.search.name = "">
		<cfset local.search.caption = "">
		<cfset local.search.type = "">
		<cfset local.search.status_type = "">
		<cfset local.search.object_id = "">
		<cfset local.search.created_time = "">

		<!--- check for existence in search object --->
		<cfif structKeyExists(arguments.search, "id")>
			<cfset local.search.id = arguments.search.id>
		</cfif>
		<cfif structKeyExists(arguments.search, "from")>
			<cfset local.search.from.id = arguments.search.from.id>
			<cfset local.search.from.name = arguments.search.from.name>
		</cfif>
		<cfif structKeyExists(arguments.search, "message")>
			<cfset local.search.message = arguments.search.message>
		</cfif>
		<cfif structKeyExists(arguments.search, "story")>
			<cfset local.search.story = arguments.search.story>
		</cfif>
		<cfif structKeyExists(arguments.search, "picture")>
			<cfset local.search.picture = arguments.search.picture>
		</cfif>
		<cfif structKeyExists(arguments.search, "link")>
			<cfset local.search.link = arguments.search.link>
		</cfif>
		<cfif structKeyExists(arguments.search, "name")>
			<cfset local.search.name = arguments.search.name>
		</cfif>
		<cfif structKeyExists(arguments.search, "caption")>
			<cfset local.search.caption = arguments.search.caption>
		</cfif>
		<cfif structKeyExists(arguments.search, "type")>
			<cfset local.search.type = arguments.search.type>
		</cfif>
		<cfif structKeyExists(arguments.search, "status_type")>
			<cfset local.search.status_type = arguments.search.status_type>
		</cfif>
		<cfif structKeyExists(arguments.search, "object_id")>
			<cfset local.search.object_id = arguments.search.object_id>
		</cfif>
		<cfif structKeyExists(search, "created_time")>
			<cfset myTime = convertCreatedTimeToBigint(arguments.search.created_time)>
			<cfset local.search.created_time = myTime>
		</cfif>

		<cfreturn local.search>

	</cffunction>


	<cffunction name="parseUserObject" output="yes" returntype="struct">

		<cfargument name="user" required="yes" type="struct">

		<!--- set up defaults --->
		<cfset local.user.id = "">
		<cfset local.user.age_range.min = "">
		<cfset local.user.age_range.max = "">
		<cfset local.user.birthday = "">
		<cfset local.user.email = "">
		<cfset local.user.first_name = "">
		<cfset local.user.gender = "">
		<cfset local.user.last_name = "">
		<cfset local.user.link = "">
		<cfset local.user.locale = "">
		<cfset local.user.middle_name = "">
		<cfset local.user.name = "">
		<cfset local.user.timezone = "">
		<cfset local.user.username = "">

		<!--- check for existence in user object --->
		<cfif structKeyExists(arguments.user, "id")>
			<cfset local.user.id = arguments.user.id>
		</cfif>
		<cfif structKeyExists(arguments.user, "age_range") and structKeyExists(arguments.user.age_range, "min")>
			<cfset local.user.age_range.min = arguments.user.age_range.min>
		</cfif>
		<cfif structKeyExists(arguments.user, "age_range") and structKeyExists(arguments.user.age_range, "max")>
			<cfset local.user.age_range.max = arguments.user.age_range.max>
		</cfif>
		<cfif structKeyExists(arguments.user, "birthday")>
			<cfset local.user.birthday = arguments.user.birthday>
		</cfif>
		<cfif structKeyExists(arguments.user, "email")>
			<cfset local.user.email = arguments.user.email>
		</cfif>
		<cfif structKeyExists(arguments.user, "first_name")>
			<cfset local.user.first_name = arguments.user.first_name>
		</cfif>
		<cfif structKeyExists(arguments.user, "gender")>
			<cfset local.user.gender = arguments.user.gender>
		</cfif>
		<cfif structKeyExists(arguments.user, "last_name")>
			<cfset local.user.last_name = arguments.user.last_name>
		</cfif>
		<cfif structKeyExists(arguments.user, "link")>
			<cfset local.user.link = arguments.user.link>
		</cfif>
		<cfif structKeyExists(arguments.user, "locale")>
			<cfset local.user.locale = arguments.user.locale>
		</cfif>
		<cfif structKeyExists(arguments.user, "middle_name")>
			<cfset local.user.middle_name = arguments.user.middle_name>
		</cfif>
		<cfif structKeyExists(arguments.user, "name")>
			<cfset local.user.name = arguments.user.name>
		</cfif>
		<cfif structKeyExists(arguments.user, "timezone")>
			<cfset local.user.timezone = arguments.user.timezone>
		</cfif>
		<cfif structKeyExists(arguments.user, "username")>
			<cfset local.user.username = arguments.user.username>
		</cfif>

		<cfreturn local.user>

	</cffunction>


	<cffunction name="parsePostObject" output="yes" returntype="struct">

		<cfargument name="post" required="yes" type="struct">

		<!--- set up defaults --->
		<cfset local.post.id = "">
		<cfset local.post.from.name = "">
		<cfset local.post.from.id = "">
		<cfset local.post.message = "">
		<cfset local.post.type = "">
		<cfset local.post.status_type = "">
		<cfset local.post.object_id = "">
		<cfset local.post.created_time = "">
		<cfset local.post.shares.count = "">
		<cfset local.post.likes.count = "">

		<!--- check for existence in post object --->
		<cfif structKeyExists(arguments.post, "id")>
			<cfset local.post.id = arguments.post.id>
		</cfif>
		<cfif structKeyExists(arguments.post, "from")>
			<cfset local.post.from.name = arguments.post.from.name>
			<cfset local.post.from.id = arguments.post.from.id>
		</cfif>
		<cfif structKeyExists(arguments.post, "message")>
			<cfset local.post.message = arguments.post.message>
		</cfif>
		<cfif structKeyExists(arguments.post, "type")>
			<cfset local.post.type = arguments.post.type>
		</cfif>
		<cfif structKeyExists(arguments.post, "status_type")>
			<cfset local.post.status_type = arguments.post.status_type>
		</cfif>
		<cfif structKeyExists(arguments.post, "object_id")>
			<cfset local.post.object_id = arguments.post.object_id>
		</cfif>
		<cfif structKeyExists(arguments.post, "created_time")>
			<cfset myTime = convertCreatedTimeToBigint(arguments.post.created_time)>
			<cfset local.post.created_time = myTime>
		</cfif>
		<cfif structKeyExists(arguments.post, "shares") and structKeyExists(arguments.post.shares, "count")>
			<cfset local.post.shares.count = arguments.post.shares.count>
		</cfif>
		<cfif structKeyExists(arguments.post, "likes")>
			<cfset local.post.likes.count = arrayLen(arguments.post.likes.data)>
		</cfif>

		<cfreturn local.post>

	</cffunction>


	<cffunction name="parsePageFeedObject" output="yes" returntype="struct">

		<cfargument name="pageFeed" required="yes" type="struct">

		<!--- set up defaults --->
		<cfset local.pageFeed.id = "">
		<cfset local.pageFeed.from.name = "">
		<cfset local.pageFeed.from.id = "">
		<cfset local.pageFeed.message = "">
		<cfset local.pageFeed.type = "">
		<cfset local.pageFeed.link = "">
		<cfset local.pageFeed.name = "">
		<cfset local.pageFeed.caption = "">
		<cfset local.pageFeed.created_time = "">

		<!--- check for existence in pageFeed object --->
		<cfif structKeyExists(arguments.pageFeed, "id")>
			<cfset local.pageFeed.id = arguments.pageFeed.id>
		</cfif>
		<cfif structKeyExists(arguments.pageFeed, "from")>
			<cfset local.pageFeed.from.name = arguments.pageFeed.from.name>
			<cfset local.pageFeed.from.id = arguments.pageFeed.from.id>
		</cfif>
		<cfif structKeyExists(arguments.pageFeed, "message")>
			<cfset local.pageFeed.message = arguments.pageFeed.message>
		</cfif>
		<cfif structKeyExists(arguments.pageFeed, "type")>
			<cfset local.pageFeed.type = arguments.pageFeed.type>
		</cfif>
		<cfif structKeyExists(arguments.pageFeed, "link")>
			<cfset local.pageFeed.link = arguments.pageFeed.link>
		</cfif>
		<cfif structKeyExists(arguments.pageFeed, "name")>
			<cfset local.pageFeed.name = arguments.pageFeed.name>
		</cfif>
		<cfif structKeyExists(arguments.pageFeed, "caption")>
			<cfset local.pageFeed.caption = arguments.pageFeed.caption>
		</cfif>
		<cfif structKeyExists(arguments.pageFeed, "created_time")>
			<cfset myTime = convertCreatedTimeToBigint(arguments.pageFeed.created_time)>
			<cfset local.pageFeed.created_time = myTime>
		</cfif>

		<cfreturn local.pageFeed>

	</cffunction>


	<cffunction name="parsePageObject" output="yes" returntype="struct">

		<cfargument name="page" required="yes" type="struct">

		<!--- set up defaults --->
		<cfset local.page.id = "">
		<cfset local.page.category = "">
		<cfset local.page.checkins = "">
		<cfset local.page.description = "">
		<cfset local.page.likes = "">
		<cfset local.page.link = "">
		<cfset local.page.name = "">
		<cfset local.page.username = "">

		<!--- check for existence in page object --->
		<cfif structKeyExists(arguments.page, "id")>
			<cfset local.page.id = arguments.page.id>
		</cfif>
		<cfif structKeyExists(arguments.page, "category")>
			<cfset local.page.category = arguments.page.category>
		</cfif>
		<cfif structKeyExists(arguments.page, "checkins")>
			<cfset local.page.checkins = arguments.page.checkins>
		</cfif>
		<cfif structKeyExists(arguments.page, "description")>
			<cfset local.page.description = arguments.page.description>
		</cfif>
		<cfif structKeyExists(arguments.page, "likes")>
			<cfset local.page.likes = arguments.page.likes>
		</cfif>
		<cfif structKeyExists(arguments.page, "link")>
			<cfset local.page.link = arguments.page.link>
		</cfif>
		<cfif structKeyExists(arguments.page, "name")>
			<cfset local.page.name = arguments.page.name>
		</cfif>
		<cfif structKeyExists(arguments.page, "username")>
			<cfset local.page.username = arguments.page.username>
		</cfif>

		<cfreturn local.page>

	</cffunction>


	<cffunction name="parseCommentObject" output="yes" returntype="struct">

		<cfargument name="comment" required="yes" type="struct">

		<!--- set up defaults --->
		<cfset local.comment.id = "">
		<cfset local.comment.from.id = "">
		<cfset local.comment.from.name = "">
		<cfset local.comment.message = "">
		<cfset local.comment.created_time = "">
		<cfset local.comment.like_count = "">
		<cfset local.comment.comment_count = "">

		<!--- check for existence in comment object --->
		<cfif structKeyExists(arguments.comment, "id")>
			<cfset local.comment.id = arguments.comment.id>
		</cfif>
		<cfif structKeyExists(arguments.comment, "from")>
			<cfset local.comment.from.name = arguments.comment.from.name>
			<cfset local.comment.from.id = arguments.comment.from.id>
		</cfif>
		<cfif structKeyExists(arguments.comment, "message")>
			<cfset local.comment.message = arguments.comment.message>
		</cfif>
		<cfif structKeyExists(arguments.comment, "created_time")>
			<cfset myTime = convertCreatedTimeToBigint(arguments.comment.created_time)>
			<cfset local.comment.created_time = myTime>
		</cfif>
		<cfif structKeyExists(arguments.comment, "like_count")>
			<cfset local.comment.like_count = arguments.comment.like_count>
		</cfif>
		<cfif structKeyExists(arguments.comment, "comment_count")>
			<cfset local.comment.comment_count = arguments.comment.comment_count>
		</cfif>

		<cfreturn local.comment>

	</cffunction>


	<cffunction name="convertCreatedTimeToBigint" output="no" returntype="numeric">
		<cfargument name="created_time" required="yes" type="string">
		<!--- I take a FB created_time (either as a string () or as a bigint()) and return the bigint representation for consistency --->
		<cfif findNoCase('T', arguments.created_time)>
			<cfset created_date = listFirst(arguments.created_time, 'T')>
			<cfset created_time = listLast(listFirst(arguments.created_time, '+'), 'T')>
			<cfset created_date_time = createDateTime(year(created_date), month(created_date), day(created_date), hour(created_time), minute(created_time), second(created_time))>
			<cfreturn dateDiff('s', '1970-01-01', created_date_time)>
		</cfif>
		<cfreturn arguments.created_time>
	</cffunction>


	<cffunction name="convertCreatedTimeToString" output="no" returntype="string">
		<cfargument name="created_time" required="yes" type="string">
		<cfargument name="toLocalTime" required="no" default=false>
		<cfset created_time = convertCreatedTimeToBigint(arguments.created_time)>
		<cfset created_date_time = dateAdd('s', created_time, '1970-01-01')>
		<cfif toLocalTime>
			<cfset created_date_time = dateConvert('utc2local', created_date_time)>
		</cfif>
		<cfreturn "#dateFormat(created_date_time, 'yyyy-mm-dd')# #timeFormat(created_date_time, 'HH:mm:ss')#">
	</cffunction>


</cfcomponent>