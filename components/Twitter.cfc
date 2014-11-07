<cfcomponent displayname="Twitter Components" output="no" hint="Mostly for saving search results">

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
			select coalesce(max(cast(id_str as bigint)), 0) as since_id
			from TwitterEntries
			where 1=1
			<cfif len(arguments.programId)>
				and programId = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
			</cfif>
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

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="searchTerm" required="no" default="">
		<cfargument name="tweet" required="yes" type="struct">

		<cfif arguments.tweet.retweeted eq "NO">
			<cfset arguments.tweet.retweeted = 0>
		</cfif>
		<cfif arguments.tweet.retweeted eq "YES">
			<cfset arguments.tweet.retweeted = 1>
		</cfif>

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from TwitterEntries
				where id_str = <cfqueryparam value="#arguments.tweet.id_str#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.programId)>
					and programId = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
				<cfelseif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin
				insert into TwitterEntries (
					programId,
					[scheduleId],
					[searchTerm],
					[Id],
					[id_str],
					[created_at],
					[favorite_count],
					[geo.coordinates.latitude],
					[geo.coordinates.longitude],
					[geo.type],
					[place.id],
					[place.full_name],
					[lang],
					[retweet_count],
					[retweeted],
					[text],
					[user.id],
					[media.media_url_https]
				)
				values (
					<cfqueryparam value="#arguments.programId#" null="#not len(arguments.programId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.searchTerm#" null="#not len(arguments.searchTerm)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.tweet.id#" null="#not len(arguments.tweet.id)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.tweet.id_str#" null="#not len(arguments.tweet.id_str)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.tweet.created_at#" null="#not len(arguments.tweet.created_at)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.tweet.favorite_count#" null="#not len(arguments.tweet.favorite_count)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.tweet.geo.coordinates.latitude#" null="#not len(arguments.tweet.geo.coordinates.latitude)#" cfsqltype="cf_sql_float">,
					<cfqueryparam value="#arguments.tweet.geo.coordinates.longitude#" null="#not len(arguments.tweet.geo.coordinates.longitude)#" cfsqltype="cf_sql_float">,
					<cfqueryparam value="#arguments.tweet.geo.type#" null="#not len(arguments.tweet.geo.type)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.tweet.place.id#" null="#not len(arguments.tweet.place.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.tweet.place.full_name#" null="#not len(arguments.tweet.place.full_name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.tweet.lang#" null="#not len(arguments.tweet.lang)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.tweet.retweet_count#" null="#not len(arguments.tweet.retweet_count)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.tweet.retweeted#" null="#not len(arguments.tweet.retweeted)#" cfsqltype="cf_sql_bit">,
					<cfqueryparam value="#arguments.tweet.text#" null="#not len(arguments.tweet.text)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.tweet.user.id#" null="#not len(arguments.tweet.user.id)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.tweet.media.media_url_https#" null="#not len(arguments.tweet.media.media_url_https)#" cfsqltype="cf_sql_varchar">
				)
			end

			else

			begin

				update TwitterEntries
				set [favorite_count] = <cfqueryparam value="#arguments.tweet.favorite_count#" null="#not len(arguments.tweet.favorite_count)#" cfsqltype="cf_sql_integer">,
					[retweet_count] = <cfqueryparam value="#arguments.tweet.retweet_count#" null="#not len(arguments.tweet.retweet_count)#" cfsqltype="cf_sql_integer">,
					[retweeted] = <cfqueryparam value="#arguments.tweet.retweeted#" null="#not len(arguments.tweet.retweeted)#" cfsqltype="cf_sql_bit">
				where id_str = <cfqueryparam value="#arguments.tweet.id_str#" cfsqltype="cf_sql_varchar">

			end
		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="parseTweetObject" output="no" returntype="struct">

		<cfargument name="tweet" required="yes" type="struct">

		<cfset local.tweet.id = "">
		<cfset local.tweet.id_str = "">
		<cfset local.tweet.created_at = "">
		<cfset local.tweet.geo.coordinates.latitude = "">
		<cfset local.tweet.geo.coordinates.longitude = "">
		<cfset local.tweet.geo.type = "">
		<cfset local.tweet.lang = "">
		<cfset local.tweet.text = "">
		<cfset local.tweet.user.id = "">
		<cfset local.tweet.user.id_str = "">
		<cfset local.tweet.user.location = "">
		<cfset local.tweet.user.name = "">
		<cfset local.tweet.user.screen_name = "">
		<cfset local.tweet.user.url = "">
		<cfset local.tweet.media.media_url_https = "">
		<cfset local.tweet.favorite_count = "">
		<cfset local.tweet.retweet_count = "">
		<cfset local.tweet.retweeted = "">
		<cfset local.tweet.place.id = "">
		<cfset local.tweet.place.full_name = "">

		<!--- check for existence in tweet object --->
		<cfif structKeyExists(arguments.tweet, "id")>
			<cfset local.tweet.id = arguments.tweet.id>
		</cfif>
		<cfif structKeyExists(arguments.tweet, "id_str")>
			<cfset local.tweet.id_str = arguments.tweet.id_str>
		</cfif>
		<cfif structKeyExists(arguments.tweet, "created_at")>
			<cfset local.tweet.created_at = arguments.tweet.created_at>
		</cfif>
		<cfif structKeyExists(arguments.tweet, "geo") and isStruct(arguments.tweet.geo)>
			<cfset local.tweet.geo.coordinates.latitude = arguments.tweet.geo.coordinates[1]>
			<cfset local.tweet.geo.coordinates.longitude = arguments.tweet.geo.coordinates[2]>
			<cfif structKeyExists(arguments.tweet.geo, "type")>
				<cfset local.tweet.geo.type = arguments.tweet.geo.type>
			</cfif>
		</cfif>
		<cfif structKeyExists(arguments.tweet, "lang")>
			<cfset local.tweet.lang = arguments.tweet.lang>
		</cfif>
		<cfif structKeyExists(arguments.tweet, "text")>
			<cfset local.tweet.text = arguments.tweet.text>
		</cfif>
		<cfif structKeyExists(arguments.tweet, "user")>
			<cfset local.tweet.user.id = arguments.tweet.user.id>
			<cfset local.tweet.user.id_str = arguments.tweet.user.id_str>
			<cfset local.tweet.user.location = arguments.tweet.user.location>
			<cfset local.tweet.user.name = arguments.tweet.user.name>
			<cfset local.tweet.user.screen_name = arguments.tweet.user.screen_name>
			<cfset local.tweet.user.url = arguments.tweet.user.url>
		</cfif>
		<cfif structKeyExists(arguments.tweet, "entities") and structKeyExists(arguments.tweet.entities, "media")>
			<cfset local.tweet.media.media_url_https = arguments.tweet.entities.media[1].media_url_https>
		</cfif>
		<cfif structKeyExists(arguments.tweet, "favorite_count")>
			<cfset local.tweet.favorite_count = arguments.tweet.favorite_count>
		</cfif>
		<cfif structKeyExists(arguments.tweet, "retweet_count")>
			<cfset local.tweet.retweet_count = arguments.tweet.retweet_count>
		</cfif>
		<cfif structKeyExists(arguments.tweet, "retweeted")>
			<cfset local.tweet.retweeted = arguments.tweet.retweeted>
		</cfif>
		<cfif structKeyExists(arguments.tweet, "place") and isStruct(arguments.tweet.place)>
			<cfset local.tweet.place.id = arguments.tweet.place.id>
			<cfset local.tweet.place.full_name = arguments.tweet.place.full_name>
		</cfif>

		<cfreturn local.tweet>

	</cffunction>


</cfcomponent>