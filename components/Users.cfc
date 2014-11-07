<cfcomponent displayname="Entries Components"  output="no">

	<cffunction name="init" output="no">

		<!--- define arguments --->
		<cfargument name="dsn" required="true" type="string">

		<!--- set variables scope --->
		<cfset variables.dsn = arguments.dsn>

		<cfreturn this>

	</cffunction>


	<cffunction name="getUsers" output="no" returntype="query">

		<cfargument name="userId" required="no" default="">
		<cfargument name="emailAddress" required="no" default="">
		<cfargument name="firstName" required="no" default="">
		<cfargument name="lastName" required="no" default="">
		<cfargument name="userName" required="no" default="">
		<cfargument name="service" required="no" default="">

		<cfquery name="userSelect" datasource="#variables.dsn#">
			select
				userId,
				emailAddress,
				firstName,
				lastName,
				userName,
				[service]
			from uvwSelectUsers
			where 1=1
			<cfif len(arguments.userId)>
				and userId = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.emailAddress)>
				and emailAddress = <cfqueryparam value="#arguments.emailAddress#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.firstName)>
				and firstName = <cfqueryparam value="#arguments.firstName#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.lastName)>
				and lastName = <cfqueryparam value="#arguments.lastName#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.userName)>
				and userName = <cfqueryparam value="#arguments.userName#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.service)>
				and [service] = <cfqueryparam value="#arguments.service#" cfsqltype="cf_sql_varchar">
			</cfif>
		</cfquery>

		<cfreturn userSelect>

	</cffunction>


	<cffunction name="getFacebookUsers" output="no" returntype="query">

		<cfargument name="userId" required="no" default="">
		<cfargument name="emailAddress" required="no" default="">
		<cfargument name="firstName" required="no" default="">
		<cfargument name="lastName" required="no" default="">
		<cfargument name="userName" required="no" default="">

		<cfreturn getUsers (
			service = 'Facebook',
			argumentcollection = arguments
		)>

	</cffunction>


	<cffunction name="getGoogleUsers" output="no" returntype="query">

		<cfargument name="userId" required="no" default="">
		<cfargument name="emailAddress" required="no" default="">
		<cfargument name="firstName" required="no" default="">
		<cfargument name="lastName" required="no" default="">
		<cfargument name="userName" required="no" default="">

		<cfreturn getUsers (
			service = 'GPlus',
			argumentcollection = arguments
		)>

	</cffunction>


	<cffunction name="getInstagramUsers" output="no" returntype="query">

		<cfargument name="userId" required="no" default="">
		<cfargument name="emailAddress" required="no" default="">
		<cfargument name="firstName" required="no" default="">
		<cfargument name="lastName" required="no" default="">
		<cfargument name="userName" required="no" default="">

		<cfreturn getUsers (
			service = 'Instagram',
			argumentcollection = arguments
		)>

	</cffunction>


	<cffunction name="getTwitterUsers" output="no" returntype="query">

		<cfargument name="userId" required="no" default="">
		<cfargument name="emailAddress" required="no" default="">
		<cfargument name="firstName" required="no" default="">
		<cfargument name="lastName" required="no" default="">
		<cfargument name="userName" required="no" default="">

		<cfreturn getUsers (
			service = 'Twitter',
			argumentcollection = arguments
		)>

	</cffunction>


	<cffunction name="getVineUsers" output="no" returntype="query">

		<cfargument name="userId" required="no" default="">
		<cfargument name="emailAddress" required="no" default="">
		<cfargument name="firstName" required="no" default="">
		<cfargument name="lastName" required="no" default="">
		<cfargument name="userName" required="no" default="">

		<cfreturn getUsers (
			service = 'Vine',
			argumentcollection = arguments
		)>

	</cffunction>


	<cffunction name="insertFacebookUser" output="no" returntype="void">

		<cfargument name="user_id" required="yes">
		<cfargument name="email" required="no" default="">
		<cfargument name="first_name" required="no" default="">
		<cfargument name="last_name" required="no" default="">
		<cfargument name="username" required="no" default="">
		<cfargument name="timezone" required="no" default="">
		<cfargument name="locale" required="no" default="">
		<cfargument name="profile_url" required="no" default="">
		<cfargument name="birthday_date" required="no" default="">
		<cfargument name="userId" required="no" default="">

		<cfquery datasource="#variables.dsn#">
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
					<cfqueryparam value="#arguments.userId#" null="#not len(arguments.userId)#" cfsqltype="cf_sql_varchar">
				)
			end
		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="insertInstagramUser" output="no" returntype="void">

		<cfargument name="user_id" required="no" default="">
		<cfargument name="bio" required="no" default="">
		<cfargument name="full_name" required="no" default="">
		<cfargument name="profile_picture" required="no" default="">
		<cfargument name="username" required="no" default="">
		<cfargument name="website" required="no" default="">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from InstagramUsers
				where [user_id] = <cfqueryparam value="#arguments.user_id#">
			)
			begin
				insert into InstagramUsers (
					[user_id],
					[bio],
					[full_name],
					[profile_picture],
					[username],
					[website]
				)
				values (
					<cfqueryparam value="#arguments.user_id#" null="#not len(arguments.user_id)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.bio#" null="#not len(arguments.bio)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.full_name#" null="#not len(arguments.full_name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.profile_picture#" null="#not len(arguments.profile_picture)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.username#" null="#not len(arguments.username)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.website#" null="#not len(arguments.website)#" cfsqltype="cf_sql_varchar">
				)
			end
		</cfquery>


		<cfreturn>

	</cffunction>


	<cffunction name="insertTwitterUser" output="no" returntype="void">

		<cfargument name="id" required="no" default="">
		<cfargument name="id_str" required="no" default="">
		<cfargument name="location" required="no" default="">
		<cfargument name="name" required="no" default="">
		<cfargument name="screen_name" required="no" default="">
		<cfargument name="url" required="no" default="">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from TwitterUsers
				where [user.id] = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_bigint">
			)
			begin
				insert into TwitterUsers (
					[user.id],
					[user.id_str],
					[user.location],
					[user.name],
					[user.screen_name],
					[user.url]
				)
				values (
					<cfqueryparam value="#arguments.id#" null="#not len(arguments.id)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.id_str#" null="#not len(arguments.id_str)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.location#" null="#not len(arguments.location)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.name#" null="#not len(arguments.name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.screen_name#" null="#not len(arguments.screen_name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.url#" null="#not len(arguments.url)#" cfsqltype="cf_sql_varchar">
				)
			end
		</cfquery>

		<cfreturn>
	</cffunction>


	<cffunction name="insertVineUser" output="no" returntype="void">
		<cfreturn>
	</cffunction>


	<cffunction name="insertGoogleUser" output="no" returntype="void">
		<cfreturn>
	</cffunction>

</cfcomponent>