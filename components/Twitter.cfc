<cfcomponent displayname="Twitter Components" output="no" hint="Mostly for saving search results">

	<cffunction name="init" output="no">

		<!--- define arguments --->
		<cfargument name="dsn" required="true" type="string">

		<!--- set variables scope --->
		<cfset variables.dsn = arguments.dsn>

		<cfreturn this>

	</cffunction>


	<cffunction name="getSinceId" output="no" returntype="numeric">

		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="searchTerm" required="no" default="">

		<cfquery name="getSinceId" datasource="#variables.dsn#">
			select max(cast(id_str as bigint)) as since_id
			from TwitterEntries
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


	<cffunction name="insertTwitterEntry" output="no" returntype="void">

		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="searchTerm" required="no" default="">
		<cfargument name="Id" required="no" default="">
		<cfargument name="id_str" required="no" default="">
		<cfargument name="created_at" required="no" default="">
		<cfargument name="latitude" required="no" default="">
		<cfargument name="longitude" required="no" default="">
		<cfargument name="geo_type" required="no" default="">
		<cfargument name="lang" required="no" default="">
		<cfargument name="text" required="no" default="">
		<cfargument name="user_id" required="no" default="">
		<cfargument name="image_url" required="no" default="">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from TwitterEntries
				where id_str = <cfqueryparam value="#arguments.id_str#" cfsqltype="cf_sql_varchar">
				and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
			)
			begin
				insert into TwitterEntries (
					[scheduleId],
					[searchTerm],
					[Id],
					[id_str],
					[created_at],
					[geo.coordinates.latitude],
					[geo.coordinates.longitude],
					[geo.coordinates.type],
					[lang],
					[text],
					[user.id],
					[media.media_url_https]
				)
				values (
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.searchTerm#" null="#not len(arguments.searchTerm)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.Id#" null="#not len(arguments.Id)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.id_str#" null="#not len(arguments.id_str)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.created_at#" null="#not len(arguments.created_at)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.latitude#" null="#not len(arguments.latitude)#" cfsqltype="cf_sql_float">,
					<cfqueryparam value="#arguments.longitude#" null="#not len(arguments.longitude)#" cfsqltype="cf_sql_float">,
					<cfqueryparam value="#arguments.geo_type#" null="#not len(arguments.geo_type)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.lang#" null="#not len(arguments.lang)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.text#" null="#not len(arguments.text)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user_id#" null="#not len(arguments.user_id)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.image_url#" null="#not len(arguments.image_url)#" cfsqltype="cf_sql_varchar">
				)
			end
		</cfquery>

		<cfreturn>

	</cffunction>


</cfcomponent>