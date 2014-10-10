<cfcomponent displayname="Entries Components"  output="no">

	<cffunction name="init" output="no">

		<!--- define arguments --->
		<cfargument name="dsn" required="true" type="string">

		<!--- set variables scope --->
		<cfset variables.dsn = arguments.dsn>

		<cfreturn this>

	</cffunction>


	<cffunction name="getEntries" output="no" returntype="query">

		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="service" required="no" default="">
		<cfargument name="entryType" required="no" default="">
		<cfargument name="userId" required="no" default="">
		<cfargument name="entryDay" required="no" default="">

		<cfquery name="getEntries" datasource="#variables.dsn#">
			select
				scheduleId,
				[service],
				entryType,
				entryId,
				userId,
				[text],
				link,
				emailAddress,
				firstName,
				lastName,
				userName,
				entryDate,
				entryDay,
				rowNumber
			from uvwSelectEntries
			where 1=1
			<cfif len(arguments.scheduleId)>
				and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif len(arguments.service)>
				and [service] = <cfqueryparam value="#arguments.service#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.entryType)>
				and entryType = <cfqueryparam value="#arguments.entryType#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.userId)>
				and userId = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.entryDay)>
				and entryDay = <cfqueryparam value="#arguments.entryDay#" cfsqltype="cf_sql_timestamp">
			</cfif>
		</cfquery>

		<cfreturn getEntries>

	</cffunction>


	<cffunction name="getFacebookEntries" output="no" returntype="query">

		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="entryType" required="no" default="">
		<cfargument name="userId" required="no" default="">
		<cfargument name="entryDay" required="no" default="">

		<cfreturn getEntries (
			service = 'Facebook',
			argumentcollection = arguments
		)>
	</cffunction>


	<cffunction name="getTwitterEntries" output="no" returntype="query">

		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="entryType" required="no" default="">
		<cfargument name="userId" required="no" default="">
		<cfargument name="entryDay" required="no" default="">

		<cfreturn getEntries (
			service = 'Twitter',
			argumentcollection = arguments
		)>
	</cffunction>


	<cffunction name="getInstagramEntries" output="no" returntype="query">

		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="entryType" required="no" default="">
		<cfargument name="userId" required="no" default="">
		<cfargument name="entryDay" required="no" default="">

		<cfreturn getEntries (
			service = 'Instagram',
			argumentcollection = arguments
		)>
	</cffunction>


	<cffunction name="getVineEntries" output="no" returntype="query">

		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="entryType" required="no" default="">
		<cfargument name="userId" required="no" default="">
		<cfargument name="entryDay" required="no" default="">

		<cfreturn getEntries (
			service = 'Vine',
			argumentcollection = arguments
		)>
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

</cfcomponent>