<cfcomponent displayname="Facebook Components" output="no" hint="Mostly for saving FB search results">

	<cffunction name="init" output="no">

		<!--- define arguments --->
		<cfargument name="dsn" required="true" type="string">

		<!--- set variables scope --->
		<cfset variables.dsn = arguments.dsn>

		<cfreturn this>

	</cffunction>


	<cffunction name="insertFacebookPostComment" output="no" returntype="void">

		<cfargument name="scheduleId" default="">
		<cfargument name="pageId" default="#getToken(arguments.postId, 1, '_')#">
		<cfargument name="postId" default="">
		<cfargument name="fromId" default="">
		<cfargument name="postFBId" default="">
		<cfargument name="id" default="">
		<cfargument name="commentText" default="">
		<cfargument name="commentTime" default="">
		<cfargument name="userId" default="">

		<cfquery datasource="#variables.dsn#">
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

		<cfreturn>

	</cffunction>


	<cffunction name="insertFacebookPostLike" output="no" returntype="void">

		<cfargument name="scheduleId" default="">
		<cfargument name="pageId" default="#getToken(arguments.postId, 1, '_')#">
		<cfargument name="postId" default="">
		<cfargument name="user_id" default="">
		<cfargument name="userId" default="">

		<cfquery datasource="#variables.dsn#">
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

		<cfreturn>

	</cffunction>


	<cffunction name="insertFacebookSearchResult" output="no" returntype="void">

		<cfargument name="scheduleId" default="">
		<cfargument name="search_id" default="">
		<cfargument name="object_id" default="">
		<cfargument name="name" default="">
		<cfargument name="resultUrl" default="">
		<cfargument name="caption" default="">
		<cfargument name="message" default="">
		<cfargument name="description" default="">
		<cfargument name="created_time" default="">
		<cfargument name="user_id" default="">
		<cfargument name="type" default="">
		<cfargument name="userId" default="">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from FacebookSearches
				where search_id = <cfqueryparam value="#arguments.search_id#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin
				insert into FacebookSearches (
					scheduleId,
					search_id,
					[object_id],
					name,
					result_url,
					caption,
					message,
					description,
					created_time,
					[user_id],
					[type],
					addedBy
				)
				values (
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.search_id#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.object_id#" null="#not len(arguments.object_id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.name#" null="#not len(arguments.name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.result_url#" null="#not len(arguments.result_url)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.caption#" null="#not len(arguments.caption)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.message#" null="#not len(arguments.message)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.description#" null="#not len(arguments.description)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.created_time#" null="#not len(arguments.created_time)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user_id#" null="#not len(arguments.user_id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.type#" null="#not len(arguments.type)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_varchar">
				)
			end
		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="insertFacebookPage" output="no" returntype="void">

		<cfargument name="scheduleId" default="">
		<cfargument name="pageId" default="">
		<cfargument name="searchTerm" default="">
		<cfargument name="pageName" default="">
		<cfargument name="pageUrl" default="">
		<cfargument name="userName" default="">
		<cfargument name="pageType" default="">
		<cfargument name="userId" default="">

		<cfquery datasource="#variables.dsn#">
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

		<cfreturn>

	</cffunction>


	<cffunction name="insertFacebookPost" output="no" returntype="void">

		<cfargument name="scheduleId" default="">
		<cfargument name="pageId" default="">
		<cfargument name="postId" default="">
		<cfargument name="searchTerm" default="">
		<cfargument name="message" default="">
		<cfargument name="created_time" default="">
		<cfargument name="postType" default="">
		<cfargument name="userId" default="">

		<cfquery datasource="#variables.dsn#">
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

		<cfreturn>

	</cffunction>


</cfcomponent>