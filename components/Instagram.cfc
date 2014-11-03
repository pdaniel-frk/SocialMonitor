<cfcomponent displayname="Instagram Components" output="no" hint="Mostly for saving Instagram search results">

	<cffunction name="init" output="no">

		<!--- define arguments --->
		<cfargument name="dsn" required="true" type="string">

		<!--- set variables scope --->
		<cfset variables.dsn = arguments.dsn>

		<cfreturn this>

	</cffunction>


	<cffunction name="getSinceId" output="no" returntype="numeric">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="searchTerm" required="no" default="">

		<cfquery name="getSinceId" datasource="#variables.dsn#">
			select coalesce(
				max(created_time)*1000,
				cast(abs(dateDiff(s, dateadd(dd, datediff(dd, 0, getdate())-7, 0), '1970-01-01')) as bigint)*1000
			) as since_id
			from InstagramEntries
			where 1=1
			<cfif len(arguments.scheduleId)>
				and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif len(arguments.searchTerm)>
				and searchTerm = <cfqueryparam value="#arguments.searchTerm#" cfsqltype="cf_sql_varchar">
			</cfif>
		</cfquery>

		<cfreturn getSinceId.since_id>

	</cffunction>


	<cffunction name="insertInstagramEntry" output="no" returntype="void">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="Id" required="no" default="">
		<cfargument name="searchTerm" required="no" default="">
		<cfargument name="caption_created_time" required="no" default="">
		<cfargument name="from_full_name" required="no" default="">
		<cfargument name="from_id" required="no" default="">
		<cfargument name="from_profile_picture" required="no" default="">
		<cfargument name="from_username" required="no" default="">
		<cfargument name="caption_id" required="no" default="">
		<cfargument name="caption_text" required="no" default="">
		<cfargument name="created_time" required="no" default="">
		<cfargument name="low_resolution_url" required="no" default="">
		<cfargument name="standard_resolution_url" required="no" default="">
		<cfargument name="thumbnail_url" required="no" default="">
		<cfargument name="link" required="no" default="">
		<cfargument name="latitude" required="no" default="">
		<cfargument name="longitude" required="no" default="">
		<cfargument name="location_id" required="no" default="">
		<cfargument name="tags" required="no" default="">
		<cfargument name="type" required="no" default="">
		<cfargument name="user_id" required="no" default="">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from InstagramEntries
				where Id = <cfqueryparam value="#arguments.id#">
				<cfif len(arguments.programId)>
					and programId = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
				<cfelseif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin
				insert into InstagramEntries (
					programId,
					[scheduleId],
					[Id],
					[SearchTerm],
					[caption.created_time],
					[caption.from.full_name],
					[caption.from.id],
					[caption.from.profile_picture],
					[caption.from.username],
					[caption.id],
					[caption.text],
					[created_time],
					[images.low_resolution.url],
					[images.standard_resolution.url],
					[images.thumbnail.url],
					[link],
					[location.latitude],
					[location.longitude],
					[location.id],
					[tags],
					[type],
					[user.id]
				)
				values (
					<cfqueryparam value="#arguments.programId#" null="#not len(arguments.programId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.Id#" null="#not len(arguments.Id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.searchTerm#" null="#not len(arguments.searchTerm)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.caption_created_time#" null="#not len(arguments.caption_created_time)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.from_full_name#" null="#not len(arguments.from_full_name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.from_id#" null="#not len(arguments.from_id)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.from_profile_picture#" null="#not len(arguments.from_profile_picture)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.from_username#" null="#not len(arguments.from_username)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.caption_id#" null="#not len(arguments.caption_id)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.caption_text#" null="#not len(arguments.caption_text)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.created_time#" null="#not len(arguments.created_time)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.low_resolution_url#" null="#not len(arguments.low_resolution_url)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.standard_resolution_url#" null="#not len(arguments.standard_resolution_url)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.thumbnail_url#" null="#not len(arguments.thumbnail_url)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.link#" null="#not len(arguments.link)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.latitude#" null="#not len(arguments.latitude)#" cfsqltype="cf_sql_float">,
					<cfqueryparam value="#arguments.longitude#" null="#not len(arguments.longitude)#" cfsqltype="cf_sql_float">,
					<cfqueryparam value="#arguments.location_id#" null="#not len(arguments.location_id)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.tags#" null="#not len(arguments.tags)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.type#" null="#not len(arguments.type)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user_id#" null="#not len(arguments.user_id)#" cfsqltype="cf_sql_bigint">
				)
			end
		</cfquery>

		<cfreturn>

	</cffunction>

</cfcomponent>