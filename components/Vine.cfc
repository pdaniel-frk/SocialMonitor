<cfcomponent displayname="Vine Components" output="no" hint="Mostly for saving search results">

	<cffunction name="init" output="no">

		<!--- define arguments --->
		<cfargument name="dsn" required="true" type="string">

		<!--- set variables scope --->
		<cfset variables.dsn = arguments.dsn>

		<cfreturn this>

	</cffunction>


	<cffunction name="getSinceId" output="no" returntype="numeric">

		<cfreturn 0>

	</cffunction>


	<cffunction name="insetVineEntry" output="no" returntype="void">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="searchTerm" required="no" default="">
		<cfargument name="vine" required="yes" type="struct">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from VineEntries
				where postId = <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.programId)>
					and programId = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
				<cfelseif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin
				insert into VineEntries (
					programId,
					scheduleId,
					searchTerm,
					userId,
					postId,
					description,
					explicitContent,
					permalinkUrl,
					thumbnailUrl,
					videoLowUrl,
					videoUrl,
					created
				)
				values (
					<cfqueryparam value="#arguments.programId#" null="#not len(arguments.programId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.searchTerm#" null="#not len(arguments.searchTerm)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.vine.userId#" null="#not len(arguments.vine.userId)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.vine.postId#" null="#not len(arguments.vine.postId)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.vine.description#" null="#not len(arguments.vine.description)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.vine.explicitContent#" null="#not len(arguments.vine.explicitContent)#" cfsqltype="cf_sql_bit">,
					<cfqueryparam value="#arguments.vine.permalinkUrl#" null="#not len(arguments.vine.permalinkUrl)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.vine.thumbnailUrl#" null="#not len(arguments.vine.thumbnailUrl)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.vine.videoLowUrl#" null="#not len(arguments.vine.videoLowUrl)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.vine.videoUrl#" null="#not len(arguments.vine.videoUrl)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.vine.created#" null="#not len(arguments.vine.created)#" cfsqltype="cf_sql_timestamp">
				)
			end
		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="searchVine" output="no" returntype="struct">

		<cfargument name="searchTerm" required="yes" type="string">
		<cfargument name="page" required="no" default="">

		<cfhttp method="get" url="https://api.vineapp.com/timelines/tags/#arguments.searchTerm#" charset="utf-8" resolveurl="yes">
		    <cfhttpparam type="header" name="user-agent" value="com.vine.iphone/1.0.3 (unknown, iPhone OS 6.1.0, iPhone, Scale/2.000000)">
			<cfhttpparam type="header" name="accept-language" value="en, sv, fr, de, ja, nl, it, es, pt, pt-PT, da, fi, nb, ko, zh-Hans, zh-Hant, ru, pl, tr, uk, ar, hr, cs, el, he, ro, sk, th, id, ms, en-GB, ca, hu, vi, en-us;q=0.8">
			<cfhttpparam type="header" name="accept" value="*/*">
			<cfhttpparam type="header" name="accept-encoding" value="gzip">
			<cfhttpparam type="url" name="page" value="#arguments.page#">
		</cfhttp>

		<cfreturn deserializeJson(cfhttp.fileContent)>

	</cffunction>


	<cffunction name="getVineUser" returntype="struct">
		<cfargument name="userId" required="yes"><!--- userId should first be passed to the convertNum function when calling this function --->
		<cfset arguments.userId = convertNum(arguments.userId)>
		<cfhttp method="get" url="https://api.vineapp.com/users/profiles/#arguments.userId#"></cfhttp>
		<cfreturn deserializeJson(cfhttp.fileContent).data>
	</cffunction>


	<cffunction name="parseVineObject" output="no" returntype="struct">

		<cfargument name="vine" required="yes" type="struct">

		<cfset local.vine.userId = "">
		<cfset local.vine.postId = "">
		<cfset local.vine.description = "">
		<cfset local.vine.explicitContent = "">
		<cfset local.vine.permalinkUrl = "">
		<cfset local.vine.thumbnailUrl = "">
		<cfset local.vine.videoLowUrl = "">
		<cfset local.vine.videoUrl = "">
		<cfset local.vine.created = "">

		<!--- check for existence in vine object --->
		<cfif structKeyExists(arguments.vine, "userId")>
			<cfset local.vine.userId = convertNum(arguments.vine.userId)>
		</cfif>
		<cfif structKeyExists(arguments.vine, "postId")>
			<cfset local.vine.postId = convertNum(arguments.vine.postId)>
		</cfif>
		<cfif structKeyExists(arguments.vine, "description")>
			<cfset local.vine.description = arguments.vine.description>
		</cfif>
		<cfif structKeyExists(arguments.vine, "explicitContent")>
			<cfset local.vine.explicitContent = arguments.vine.explicitContent>
		</cfif>
		<cfif structKeyExists(arguments.vine, "permalinkUrl")>
			<cfset local.vine.permalinkUrl = arguments.vine.permalinkUrl>
		</cfif>
		<cfif structKeyExists(arguments.vine, "thumbnailUrl")>
			<cfset local.vine.thumbnailUrl = arguments.vine.thumbnailUrl>
		</cfif>
		<cfif structKeyExists(arguments.vine, "videoLowUrl")>
			<cfset local.vine.videoLowUrl = arguments.vine.videoLowUrl>
		</cfif>
		<cfif structKeyExists(arguments.vine, "videoUrl")>
			<cfset local.vine.videoUrl = arguments.vine.videoUrl>
		</cfif>
		<cfif structKeyExists(arguments.vine, "created")>
			<cfset created_date = getToken(arguments.vine.created, 1, 'T')>
			<cfset created_time = getToken(arguments.vine.created, 2, 'T')>
			<cfset local.vine.created = createDateTime(year(created_date), month(created_date), day(created_date), hour(created_time), minute(created_time), second(created_time))>
		</cfif>

		<cfreturn local.vine>

	</cffunction>


	<cffunction name="parseUserObject" output="no" returntype="struct">

		<cfargument name="user" required="yes" type="struct">

		<cfset local.user.userId = "">
		<cfset local.user.username = "">
		<cfset local.user.location = "">
		<cfset local.user.email = "">
		<cfset local.user.avatarUrl = "">

		<cfif structKeyExists(arguments.user, "userId")>
			<cfset local.user.userId = convertNum(arguments.user.userId)>
		</cfif>
		<cfif structKeyExists(arguments.user, "username")>
			<cfset local.user.username = arguments.user.username>
		</cfif>
		<cfif structKeyExists(arguments.user, "location")>
			<cfset local.user.location = arguments.user.location>
		</cfif>
		<cfif structKeyExists(arguments.user, "email")>
			<cfset local.user.email = arguments.user.email>
		</cfif>
		<cfif structKeyExists(arguments.user, "avatarUrl")>
			<cfset local.user.avatarUrl = arguments.user.avatarUrl>
		</cfif>

		<cfreturn local.user>

	</cffunction>


	<!--- convert the scientific notation number of the long user/post/whatever ids to the actual value --->
	<cffunction name="convertNum" returntype="string">
		<cfargument name="num" required="yes">
		<cftry>
			<cfset bigD = createObject('java', 'java.math.BigDecimal')>
			<cfreturn bigD.init(arguments.num)>
			<cfcatch type="any">
				<cfreturn arguments.num>
			</cfcatch>
		</cftry>
	</cffunction>


</cfcomponent>