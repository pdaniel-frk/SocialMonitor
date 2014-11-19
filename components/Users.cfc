<cfcomponent displayname="Users Components"  output="no">

	<cffunction name="init" output="no">

		<!--- define arguments --->
		<cfargument name="dsn" required="true" type="string">

		<!--- set variables scope --->
		<cfset variables.dsn = arguments.dsn>

		<cfreturn this>

	</cffunction>


	<cffunction name="insertUser" output="no" returntype="numeric">

		<cfargument name="customerId" required="no" default="">
		<cfargument name="firstName" required="yes" type="string">
		<cfargument name="lastName" required="yes" type="string">
		<cfargument name="emailAddress" required="yes" type="string">
		<cfargument name="uName" required="no" type="string" default="#arguments.emailAddress#">
		<cfargument name="uPass" required="yes" type="string">

		<cfquery name="userInsert" datasource="#variables.dsn#">
			if not exists (
				select 1
				from Users
				where emailAddress = <cfqueryparam value="#arguments.emailAddress#" cfsqltype="cf_sql_varchar">
			)
			begin
				insert into Users (
					customerId,
					firstName,
					lastName,
					emailAddress,
					uName,
					uPass
				)
				values (
					<cfqueryparam value="#arguments.customerId#" null="#not len(arguments.customerId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.firstName#" null="#not len(arguments.firstName)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.lastName#" null="#not len(arguments.lastName)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.emailAddress#" null="#not len(arguments.emailAddress)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.uName#" null="#not len(arguments.uName)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.uPass#" null="#not len(arguments.uPass)#" cfsqltype="cf_sql_varchar">
				)
			end

			select userId = scope_identity()
		</cfquery>

		<!--- update their password --->
		<cfset oPasswords = createObject("component", "BaseComponents.Passwords").init(variables.dsn)>
		<cfset uPass_Hashed = oPasswords.hashPassword(uPass=arguments.uPass, uSalt=getUserDetails(userId=userInsert.userId).uSalt)>

		<cfquery datasource="#variables.dsn#">
			update Users
			set uPass = <cfqueryparam value="#uPass_Hashed#" cfsqltype="cf_sql_varchar">
			where userId = <cfqueryparam value="#userInsert.userId#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfreturn userInsert.userId>

	</cffunction>


	<cffunction name="getUsers" output="no" returntype="query">

		<cfargument name="userId" required="no" default="">
		<cfargument name="customerId" required="no" default="">
		<cfargument name="firstName" required="no" default="">
		<cfargument name="lastName" required="no" default="">
		<cfargument name="emailAddress" required="no" default="">
		<cfargument name="uName" required="no" default="">

		<cfquery name="userSelect" datasource="#variables.dsn#">
			select
				u.userId,
				u.customerId,
				u.firstName,
				u.lastName,
				u.emailAddress,
				u.uName,
				u.uPass,
				u.uSalt
			from Users u
			where isdate(u.deleteDate) = 0
			<cfif len(arguments.userId)>
				and u.userId = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif len(arguments.customerId)>
				and u.customerId = <cfqueryparam value="#arguments.customerId#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif len(arguments.firstName)>
				and u.firstName = <cfqueryparam value="#arguments.firstName#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.lastName)>
				and u.lastName = <cfqueryparam value="#arguments.lastName#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.uName)>
				and u.uName = <cfqueryparam value="#arguments.uName#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.emailAddress)>
				and u.emailAddress = <cfqueryparam value="#arguments.emailAddress#" cfsqltype="cf_sql_varchar">
			</cfif>
		</cfquery>

		<cfreturn userSelect>

	</cffunction>


	<cffunction name="updateUser" output="no">

		<cfargument name="userId" required="yes">
		<cfargument name="customerId" required="no" default="">
		<cfargument name="firstName" required="no" default="">
		<cfargument name="lastName" required="no" default="">
		<cfargument name="emailAddress" required="no" default="">
		<cfargument name="uName" required="no" default="">
		<cfargument name="uPass" required="no" default="">
		<cfargument name="uSalt" required="no" default="">

		<cfquery datasource="#variables.dsn#">
			update Users
			set modifyDate = getdate()
			<cfif len(arguments.customerId)>
				, customerId = <cfqueryparam value="#arguments.customerId#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif len(arguments.firstName)>
				, firstName = <cfqueryparam value="#arguments.firstName#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.lastName)>
				, lastName = <cfqueryparam value="#arguments.lastName#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.emailAddress)>
				, emailAddress = <cfqueryparam value="#arguments.emailAddress#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.uName)>
				, uName = <cfqueryparam value="#arguments.uName#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.uPass)>
				, uPass = <cfqueryparam value="#arguments.uPass#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.uSalt)>
				, uSalt = <cfqueryparam value="#arguments.uSalt#" cfsqltype="cf_sql_varchar">
			</cfif>
			where userId = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">
		</cfquery>

	</cffunction>


	<cffunction name="deleteUser" output="no">

		<cfargument name="userId" required="no" default="">

		<cfquery datasource="#this.dsn#">
			update Users
			set deleteDate = getdate()
			where userId = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfreturn>

	</cffunction>

</cfcomponent>