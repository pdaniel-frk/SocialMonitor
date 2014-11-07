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
		<cfargument name="searchTerm" required="no" default="">
		<cfargument name="instagram" required="yes" type="struct">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from InstagramEntries
				where Id = <cfqueryparam value="#arguments.instagram.id#">
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
					<cfqueryparam value="#arguments.instagram.Id#" null="#not len(arguments.instagram.Id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.searchTerm#" null="#not len(arguments.searchTerm)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.instagram.caption.created_time#" null="#not len(arguments.instagram.caption.created_time)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.instagram.caption.from.full_name#" null="#not len(arguments.instagram.caption.from.full_name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.instagram.caption.from.id#" null="#not len(arguments.instagram.caption.from.id)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.instagram.caption.from.profile_picture#" null="#not len(arguments.instagram.caption.from.profile_picture)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.instagram.caption.from.username#" null="#not len(arguments.instagram.caption.from.username)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.instagram.caption.id#" null="#not len(arguments.instagram.caption.id)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.instagram.caption.text#" null="#not len(arguments.instagram.caption.text)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.instagram.created_time#" null="#not len(arguments.instagram.created_time)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.instagram.images.low_resolution.url#" null="#not len(arguments.instagram.images.low_resolution.url)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.instagram.images.standard_resolution.url#" null="#not len(arguments.instagram.images.standard_resolution.url)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.instagram.images.thumbnail.url#" null="#not len(arguments.instagram.images.thumbnail.url)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.instagram.link#" null="#not len(arguments.instagram.link)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.instagram.location.latitude#" null="#not len(arguments.instagram.location.latitude)#" cfsqltype="cf_sql_float">,
					<cfqueryparam value="#arguments.instagram.location.longitude#" null="#not len(arguments.instagram.location.longitude)#" cfsqltype="cf_sql_float">,
					<cfqueryparam value="#arguments.instagram.location.id#" null="#not len(arguments.instagram.location.id)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.instagram.tags#" null="#not len(arguments.instagram.tags)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.instagram.type#" null="#not len(arguments.instagram.type)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.instagram.user.id#" null="#not len(arguments.instagram.user.id)#" cfsqltype="cf_sql_bigint">
				)
			end
		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="parseInstagramObject" output="no" returntype="struct">

		<cfargument name="instagram" required="yes" type="struct">

		<cfset local.instagram.id = "">
		<cfset local.instagram.caption.created_time = "">
		<cfset local.instagram.caption.from.full_name = "">
		<cfset local.instagram.caption.from.id = "">
		<cfset local.instagram.caption.from.profile_picture = "">
		<cfset local.instagram.caption.from.username = "">
		<cfset local.instagram.caption.id = "">
		<cfset local.instagram.caption.text = "">
		<cfset local.instagram.created_time = "">
		<cfset local.instagram.images.low_resolution.url = "">
		<cfset local.instagram.images.standard_resolution.url = "">
		<cfset local.instagram.images.thumbnail.url = "">
		<cfset local.instagram.link = "">
		<cfset local.instagram.location.latitude = "">
		<cfset local.instagram.location.longitude = "">
		<cfset local.instagram.location.id = "">
		<cfset local.instagram.tags = "">
		<cfset local.instagram.type = "">
		<cfset local.instagram.user.id = "">
		<cfset local.instagram.user.bio = "">
		<cfset local.instagram.user.full_name = "">
		<cfset local.instagram.user.profile_picture = "">
		<cfset local.instagram.user.username = "">
		<cfset local.instagram.user.website = "">

		<cfif structKeyExists(arguments.instagram, "id")>
			<cfset local.instagram.id = arguments.instagram.id>
		</cfif>
		<cfif structKeyExists(arguments.instagram, "caption") and isStruct(arguments.instagram.caption)>
			<cfset local.instagram.caption.created_time = arguments.instagram.caption.created_time>
			<cfset local.instagram.caption.from.full_name = arguments.instagram.caption.from.full_name>
			<cfset local.instagram.caption.from.id = arguments.instagram.caption.from.id>
			<cfset local.instagram.caption.from.profile_picture = arguments.instagram.caption.from.profile_picture>
			<cfset local.instagram.caption.from.username = arguments.instagram.caption.from.username>
			<cfset local.instagram.caption.id = arguments.instagram.caption.id>
			<cfset local.instagram.caption.text = arguments.instagram.caption.text>
		</cfif>
		<cfif structKeyExists(arguments.instagram, "created_time")>
			<cfset local.instagram.created_time = arguments.instagram.created_time>
		</cfif>
		<cfif structKeyExists(arguments.instagram, "images")>
			<cfset local.instagram.images.low_resolution.url = arguments.instagram.images.low_resolution.url>
			<cfset local.instagram.images.standard_resolution.url = arguments.instagram.images.standard_resolution.url>
			<cfset local.instagram.images.thumbnail.url = arguments.instagram.images.thumbnail.url>
		</cfif>
		<cfif structKeyExists(arguments.instagram, "link")>
			<cfset local.instagram.link = arguments.instagram.link>
		</cfif>
		<cfif structKeyExists(arguments.instagram, "location") and isStruct(arguments.instagram.location)>
			<cfif structKeyExists(arguments.instagram.location, "id")>
				<cfset local.instagram.location.id = arguments.instagram.location.id>
			<cfelse>
				<cfset local.instagram.location.latitude = arguments.instagram.location.latitude>
				<cfset local.instagram.location.longitude = arguments.instagram.location.longitude>
			</cfif>
		</cfif>
		<cfif structKeyExists(arguments.instagram, "tags") and isArray(arguments.instagram.tags)>
			<cfset local.instagram.tags = arrayToList(arguments.instagram.tags)>
		</cfif>
		<cfif structKeyExists(arguments.instagram, "type")>
			<cfset local.instagram.type = arguments.instagram.type>
		</cfif>
		<cfif structKeyExists(arguments.instagram, "user")>
			<cfset local.instagram.user.id = arguments.instagram.user.id>
			<cfset local.instagram.user.bio = arguments.instagram.user.bio>
			<cfset local.instagram.user.full_name = arguments.instagram.user.full_name>
			<cfset local.instagram.user.profile_picture = arguments.instagram.user.profile_picture>
			<cfset local.instagram.user.username = arguments.instagram.user.username>
			<cfset local.instagram.user.website = arguments.instagram.user.website>
		</cfif>

		<cfreturn local.instagram>

	</cffunction>

</cfcomponent>