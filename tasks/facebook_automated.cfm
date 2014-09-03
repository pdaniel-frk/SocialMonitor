<cfsetting requesttimeout="999">

<!--- get everything on the schedule --->
<cfquery name="getSchedule" datasource="#this.dsn#">
	select
		scheduleId,
		monitor_page_id,
		monitor_post_id
	from Schedules
	where service = 'Facebook'
	and isdate(deleteDate) = 0
	<cfif structKeyExists(url, "scheduleId")>
		and scheduleId = <cfqueryparam value="#url.scheduleId#" cfsqltype="cf_sql_integer">
	<cfelse>
		and isnull(startdate, getdate()-1) <= getdate()
		and isnull(endDate, getdate()+1) >= getdate()
	</cfif>
</cfquery>

<!--- the ajaxy/jquery stuff does not work when called via scheduled task, so trying a different approach (cfhttp) --->
<cfset since = ''>

<cfif getSchedule.recordCount>
	<cfloop query="getSchedule">
		<cfif len(getSchedule.monitor_page_id)>
			<cfset page_id = getSchedule.monitor_page_id>
			<cftry>
				<cfset page_result = get_page(getSchedule.scheduleId, page_id, true)>
				<cfcatch type="any">
					<h1>error parsing page_result</h1>
					<cfdump var="#page_result#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfset post_result = get_page_post(getSchedule.scheduleId, page_id, true)>
				<cfcatch type="any">
					<h1>error parsing post_result</h1>
					<!--- <cfdump var="#cfcatch#"> --->
					<cfdump var="#post_result#">
				</cfcatch>
			</cftry>
		</cfif>
		<cfif len(getSchedule.monitor_post_id)>
			<cfset post_id = getSchedule.monitor_post_id>
			<cfset page_id = getToken(post_id, 1, '_')>

			<cftry>
				<cfset page_result = get_page(getSchedule.scheduleId, page_id, true)>
				<cfcatch type="any">
					<h1>error parsing page_result</h1>
					<cfdump var="#page_result#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfset post_result = get_page_post(getSchedule.scheduleId, page_id, true)>
				<cfcatch type="any">
					<h1>error parsing post_result</h1>
					<cfdump var="#post_result#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfset comment_result = get_post_comment(getSchedule.scheduleId, post_id, true)>
				<cfcatch type="any">
					<h1>error parsing comment_result</h1>
					<cfdump var="#comment_result#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfset like_result = get_post_like(getSchedule.scheduleId, post_id, true)>
				<cfcatch type="any">
					<h1>error parsing like_result</h1>
					<cfdump var="#like_result#">
				</cfcatch>
			</cftry>
		</cfif>
	</cfloop>
</cfif>

<cffunction name="get_page">
	<cfargument name="scheduleId" default="">
	<cfargument name="page_id" required="true">
	<cfargument name="save_results" required="no" default="false">
	<cfhttp url="https://api-read.facebook.com/restserver.php" method="get" charset="utf-8">
		<cfhttpparam type="url" name="access_token" value="#credentials.facebook.page_access_token#">
		<cfhttpparam type="url" name="api_key" value="#credentials.facebook.appId#">
		<cfhttpparam type="url" name="method" value="fql.query">
		<cfhttpparam type="url" name="query" value="select page_id, name, username, type, fan_count, page_url from page where page_id = #arguments.page_id# order by fan_count desc">
		<cfhttpparam type="url" name="return_ssl_resources" value="1">
		<cfhttpparam type="url" name="format" value="json-strings">
		<cfhttpparam type="url" name="pretty" value="1">
	</cfhttp>
	<cfset page_result = deserializeJson(cfhttp.fileContent)>
	<cfif arguments.save_results>
		<cfloop from="1" to="#arrayLen(page_result)#" index="i">
			<cfset save_page(
							scheduleId = arguments.scheduleId,
							pageId = page_result[i].page_id,
							pageName = page_result[i].name,
							pageUrl = page_result[i].page_url,
							userName = page_result[i].username,
							pageType = page_result[i].type)>
		</cfloop>
	</cfif>
	<cfreturn page_result>
</cffunction>

<cffunction name="save_page">
	<cfargument name="scheduleId" default="">
	<cfargument name="pageId" default="">
	<cfargument name="pageName" default="">
	<cfargument name="pageUrl" default="">
	<cfargument name="userName" default="">
	<cfargument name="pageType" default="">
	<cfargument name="userId" default="#this.uid#">

	<cfif len(arguments.pageId) and len(arguments.userId)>

		<cfquery datasource="#this.dsn#">
			if not exists (
				select 1
				from FacebookPages
				where page_id = <cfqueryparam value="#arguments.pageId#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin
				insert into FacebookPages (
					scheduleId,
					page_id,
					name,
					page_url,
					username,
					type,
					addedBy
				)
				values (
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.pageId#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.pageName#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.pageUrl#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.userName#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.pageType#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_varchar">
				)
			end
		</cfquery>
	</cfif>
	<cfreturn>
</cffunction>

<cffunction name="get_page_post">
	<cfargument name="scheduleId" default="">
	<cfargument name="page_id" required="true">
	<cfargument name="save_results" required="no" default="false">
	<!--- get most recent comment in the db --->
	<cfquery name="getTime" datasource="#this.dsn#">
		select max([created_time]) as [time]
		from FacebookPagePosts
		where page_id = <cfqueryparam value="#arguments.page_id#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<cfset qry = "select post_id, message, created_time, type, share_count, comment_info.comment_count, like_info.like_count from stream where source_id = #arguments.page_id# and actor_id = #arguments.page_id#">
	<cfif getTime.recordCount and len(getTime.time)>
		<cfset qry &= " and created_time > #getTime.time#">
	</cfif>
	<cfhttp url="https://api-read.facebook.com/restserver.php" method="get" charset="utf-8">
		<cfhttpparam type="url" name="access_token" value="#credentials.facebook.page_access_token#">
		<cfhttpparam type="url" name="api_key" value="#credentials.facebook.appId#">
		<cfhttpparam type="url" name="method" value="fql.query">
		<cfhttpparam type="url" name="query" value="#qry#">
		<cfhttpparam type="url" name="return_ssl_resources" value="1">
		<cfhttpparam type="url" name="format" value="json-strings">
		<cfhttpparam type="url" name="pretty" value="1">
	</cfhttp>
	<cfset post_result = deserializeJson(cfhttp.fileContent)>
	<cfif arguments.save_results>
		<cfloop from="1" to="#arrayLen(post_result)#" index="i">
			<cfset save_page_post(
							scheduleId = arguments.scheduleId,
							pageId = arguments.page_id,
							postId = post_result[i].post_id,
							message = post_result[i].message,
							created_time = post_result[i].created_time,
							postType = post_result[i].type)>
		</cfloop>
	</cfif>
	<cfreturn post_result>
</cffunction>

<cffunction name="save_page_post">
	<cfargument name="scheduleId" default="">
	<cfargument name="pageId" default="">
	<cfargument name="postId" default="">
	<cfargument name="message" default="">
	<cfargument name="created_time" default="">
	<cfargument name="postType" default="">
	<cfargument name="userId" default="#this.uid#">
	<cfif len(arguments.pageId) and len(arguments.postId) and len(arguments.userId)>
		<cfquery datasource="#this.dsn#">
			if not exists (
				select 1
				from FacebookPagePosts
				where post_id = <cfqueryparam value="#arguments.postId#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin
				insert into FacebookPagePosts (
					scheduleId,
					page_id,
					post_id,
					message,
					created_time,
					type,
					addedBy
				)
				values (
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.pageId#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.postId#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.message#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.created_time#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.postType#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_varchar">
				)
			end
		</cfquery>
	</cfif>
	<cfreturn>
</cffunction>

<cffunction name="get_post_comment">
	<cfargument name="scheduleId" default="">
	<cfargument name="post_id" required="true">
	<cfargument name="save_results" required="no" default="false">
	<!--- get most recent comment in the db --->
	<cfquery name="getTime" datasource="#this.dsn#">
		select max([time]) as [time]
		from FacebookPostComments
		where post_id = <cfqueryparam value="#arguments.post_id#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<cfset qry = "select text, id, post_fbid, fromid, time from comment where post_id = '#arguments.post_id#'">
	<cfif getTime.recordCount and len(getTime.time)>
		<cfset qry &= " and time > #getTime.time#">
	</cfif>
	<cfset qry &= " limit 1000">
	<cfhttp url="https://api-read.facebook.com/restserver.php" method="get" charset="utf-8">
		<cfhttpparam type="url" name="access_token" value="#credentials.facebook.page_access_token#">
		<cfhttpparam type="url" name="api_key" value="#credentials.facebook.appId#">
		<cfhttpparam type="url" name="method" value="fql.query">
		<cfhttpparam type="url" name="query" value="#qry#">
		<cfhttpparam type="url" name="return_ssl_resources" value="1">
		<cfhttpparam type="url" name="format" value="json-strings">
		<cfhttpparam type="url" name="pretty" value="1">
	</cfhttp>
	<cfset comment_result = deserializeJson(cfhttp.fileContent)>
	<cfif arguments.save_results>
		<cfloop from="1" to="#arrayLen(comment_result)#" index="i">
			<cfset save_post_comment(
							scheduleId = arguments.scheduleId,
							pageId = getToken(arguments.post_id, 1, '_'),
							postId = arguments.post_id,
							fromId = comment_result[i].fromid,
							postFBId = comment_result[i].post_fbid,
							id = comment_result[i].id,
							commentText = comment_result[i].text,
							commentTime = comment_result[i].time)>
			<cfset get_user(comment_result[i].fromid, true)>
		</cfloop>
	</cfif>
	<cfreturn comment_result>
</cffunction>

<cffunction name="save_post_comment">
	<cfargument name="scheduleId" default="">
	<cfargument name="pageId" default="#getToken(arguments.postId, 1, '_')#">
	<cfargument name="postId" default="">
	<cfargument name="fromId" default="">
	<cfargument name="postFBId" default="">
	<cfargument name="id" default="">
	<cfargument name="commentText" default="">
	<cfargument name="commentTime" default="">
	<cfargument name="userId" default="#this.uid#">
	<cfif len(arguments.pageId) and len(arguments.postId) and len(arguments.fromId) and len(arguments.userId)>
		<cfquery datasource="#this.dsn#">
			if not exists (
				select 1
				from FacebookPostComments
				where post_fbid = <cfqueryparam value="#arguments.postFBId#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin
				insert into FacebookPostComments (
					scheduleId,
					page_id,
					post_id,
					[text],
					id,
					post_fbid,
					fromid,
					[time],
					addedBy
				)
				values (
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.pageId#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.postId#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.commentText#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.postFBId#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.fromId#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.commentTime#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_varchar">
				)
			end
		</cfquery>
	</cfif>
	<cfreturn>
</cffunction>

<cffunction name="get_post_like">
	<cfargument name="scheduleId" default="">
	<cfargument name="post_id" required="true">
	<cfargument name="save_results" required="no" default="false">
	<cfhttp url="https://api-read.facebook.com/restserver.php" method="get" charset="utf-8">
		<cfhttpparam type="url" name="access_token" value="#credentials.facebook.page_access_token#">
		<cfhttpparam type="url" name="api_key" value="#credentials.facebook.appId#">
		<cfhttpparam type="url" name="method" value="fql.query">
		<cfhttpparam type="url" name="query" value="select user_id from like where post_id = '#arguments.post_id#' limit 1000">
		<cfhttpparam type="url" name="return_ssl_resources" value="1">
		<cfhttpparam type="url" name="format" value="json-strings">
		<cfhttpparam type="url" name="pretty" value="1">
	</cfhttp>
	<cfset like_result = deserializeJson(cfhttp.fileContent)>
	<cfif arguments.save_results>
		<cfloop from="1" to="#arrayLen(like_result)#" index="i">
			<cfset save_post_like(
							scheduleId = arguments.scheduleId,
							pageId = getToken(arguments.post_id, 1, '_'),
							postId = arguments.post_id,
							user_id = like_result[i].user_id)>
			<cfset get_user(like_result[i].user_id, true)>
		</cfloop>
	</cfif>
	<cfreturn like_result>
</cffunction>

<cffunction name="save_post_like">
	<cfargument name="scheduleId" default="">
	<cfargument name="pageId" default="#getToken(arguments.postId, 1, '_')#">
	<cfargument name="postId" default="">
	<cfargument name="user_id" default="">
	<cfargument name="userId" default="#this.uid#">
	<cfif len(arguments.pageId) and len(arguments.postId) and len(arguments.user_id) and len(arguments.userId)>
		<cfquery datasource="#this.dsn#">
			if not exists (
				select 1
				from FacebookPostLikes
				where post_id = <cfqueryparam value="#arguments.postId#" cfsqltype="cf_sql_varchar">
				and user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin
				insert into FacebookPostLikes (
					scheduleId,
					page_id,
					post_id,
					[user_id],
					addedBy
				)
				values (
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.pageId#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.postId#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_varchar">
				)
			end
		</cfquery>
	</cfif>
	<cfreturn>
</cffunction>

<cffunction name="get_user">
	<cfargument name="user_id" required="true">
	<cfargument name="save_results" required="no" default="false">
	<cfhttp url="https://api-read.facebook.com/restserver.php" method="get" charset="utf-8">
		<cfhttpparam type="url" name="access_token" value="#credentials.facebook.page_access_token#">
		<cfhttpparam type="url" name="api_key" value="#credentials.facebook.appId#">
		<cfhttpparam type="url" name="method" value="fql.query">
		<cfhttpparam type="url" name="query" value="select email, first_name, last_name, name, username, uid, timezone, locale, profile_url, age_range, birthday_date from user where uid = #arguments.user_id#">
		<cfhttpparam type="url" name="return_ssl_resources" value="1">
		<cfhttpparam type="url" name="format" value="json-strings">
		<cfhttpparam type="url" name="pretty" value="1">
	</cfhttp>
	<cfset user_result = deserializeJson(cfhttp.fileContent)>
	<cfif arguments.save_results>
		<cfloop from="1" to="#arrayLen(user_result)#" index="i">
			<cfset save_user(
							user_id = user_result[i].uid,
							email = user_result[i].email,
							first_name = user_result[i].first_name,
							last_name = user_result[i].last_name,
							username = user_result[i].username,
							timezone = user_result[i].timezone,
							locale = user_result[i].locale,
							profile_url = user_result[i].profile_url,
							birthday_date = user_result[i].birthday_date)>
		</cfloop>
	</cfif>
	<cfreturn user_result>
</cffunction>

<cffunction name="save_user">
	<cfargument name="user_id" default="">
	<cfargument name="email" default="">
	<cfargument name="first_name" default="">
	<cfargument name="last_name" default="">
	<cfargument name="username" default="">
	<cfargument name="timezone" default="">
	<cfargument name="locale" default="">
	<cfargument name="profile_url" default="">
	<cfargument name="birthday_date" default="">
	<cfargument name="userId" default="#this.uid#">
	<cfif len(arguments.user_id) and len(arguments.userId)>
		<cfquery datasource="#this.dsn#">
			if not exists (
				select 1
				from FacebookUsers
				where user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">
			)
			begin
				insert into FacebookUsers (
					user_id,
					email,
					first_name,
					last_name,
					username,
					timezone,
					locale,
					profile_url,
					birthday_date,
					addedBy
				)
				values (
					<cfqueryparam value="#arguments.user_id#" null="#not len(arguments.user_id) or compareNoCase(arguments.user_id, 'null') eq 0#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.email#" null="#not len(arguments.email) or compareNoCase(arguments.email, 'null') eq 0#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.first_name#" null="#not len(arguments.first_name) or compareNoCase(arguments.first_name, 'null') eq 0#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.last_name#" null="#not len(arguments.last_name) or compareNoCase(arguments.last_name, 'null') eq 0#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.username#" null="#not len(arguments.username) or compareNoCase(arguments.username, 'null') eq 0#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.timezone#" null="#not len(arguments.timezone) or compareNoCase(arguments.timezone, 'null') eq 0#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.locale#" null="#not len(arguments.locale) or compareNoCase(arguments.locale, 'null') eq 0#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.profile_url#" null="#not len(arguments.profile_url) or compareNoCase(arguments.profile_url, 'null') eq 0#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.birthday_date#" null="#not len(arguments.birthday_date) or not isdate(arguments.birthday_date) or compareNoCase(arguments.birthday_date, 'null') eq 0#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_varchar">
				)
			end
		</cfquery>
	</cfif>
	<cfreturn>
</cffunction>
