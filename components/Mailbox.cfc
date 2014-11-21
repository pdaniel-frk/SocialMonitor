<cfcomponent output="false">

	<cffunction name="init" output="no">

		<!--- define arguments --->
		<cfargument name="dsn" required="true" type="string">
		<cfargument name="custServEmail" required="no" default="mksocialmonitor@mardenkane.com">

		<!--- set variables scope --->
		<cfset variables.dsn = arguments.dsn>
		<cfset variables.custServEmail = arguments.custServEmail>

		<cfreturn this>
	</cffunction>


	<cffunction name="sendForgotUsernameEmail" output="no" returntype="boolean">

		<cfargument name="userId" required="yes" type="numeric">
		<cfargument name="test" required="no" type="boolean" default=false>

		<cfset oUsers = createObject("component", "Users").init(variables.dsn)>
		<cfset user = oUsers.getUsers(userId=arguments.userId)>

		<cfif not user.recordCount>
			<cfreturn false>
		<cfelse>
			<cfset arguments.emailAddress = user.emailAddress>
			<cfset arguments.firstName = user.firstName>
			<cfset arguments.lastName = user.lastName>
			<cfset arguments.uName = user.uName>
		</cfif>

		<cfset emailTo = arguments.emailAddress>
		<cfset emailFrom = variables.custServEmail>
		<cfif arguments.test>
			<cfset emailTo = "egrimm@mardenkane.com">
			<cfset emailFrom = "egrimm@mardenkane.com">
		</cfif>

		<cfmail to="#emailTo#" from="#emailFrom#" subject="Your MK Social Monitor Username" type="html">
			<cfinclude template="mail_header.cfm">

			<p>Hello #arguments.firstName# #arguments.lastName#.</p>
			<p>Your username is #arguments.uName#.</p>

			<cfinclude template="mail_footer.cfm">
		</cfmail>

		<!--- insert record into email history table --->
		<cfquery datasource="#variables.dsn#">
			insert into EmailHistory (
				userId,
				emailAddress,
				emailType
			)
			values (
				<cfqueryparam value="#arguments.userId#" null="#not len(arguments.userId)#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#arguments.emailAddress#" cfsqltype="cf_sql_varchar">,
				'ForgotUsernameEmail'
			)
		</cfquery>
		<cfreturn true>

	</cffunction>


	<cffunction name="sendPasswordResetEmail" output="no" returntype="boolean">

		<cfargument name="userId" required="yes" type="numeric">
		<cfargument name="token" required="yes" type="string">
		<cfargument name="test" required="no" type="boolean" default=false>

		<cfset oUsers = createObject("component", "Users").init(variables.dsn)>
		<cfset user = oUsers.getUsers(userId=arguments.userId)>

		<cfif not user.recordCount>
			<cfreturn false>
		<cfelse>
			<cfset arguments.emailAddress = user.emailAddress>
			<cfset arguments.firstName = user.firstName>
			<cfset arguments.lastName = user.lastName>
			<cfset arguments.uName = user.uName>
		</cfif>

		<cfset emailTo = arguments.emailAddress>
		<cfset emailFrom = variables.custServEmail>
		<cfif arguments.test>
			<cfset emailTo = "egrimm@mardenkane.com">
			<cfset emailFrom = "egrimm@mardenkane.com">
		</cfif>

		<cfmail to="#emailTo#" from="#emailFrom#" subject="Reset Your MK Social Monitor Password" type="html">
			<cfinclude template="mail_header.cfm">

			<p>Hello #arguments.firstName# #arguments.lastName#.</p>

			<p>You may reset your password by following the link below:</p>

			<p><a href="#request.siteUrl#users/my-profile/reset-password.cfm?email=#arguments.emailaddress#&token=#arguments.token#&s=1">#request.siteUrl#my-profile/reset-password.cfm?email=#arguments.emailaddress#&token=#arguments.token#&s=1</a></p>

			<p>If you did not reset your password, please disregard this message.</p>

			<cfinclude template="mail_footer.cfm">
		</cfmail>


		<!--- insert record into email history table --->
		<cfquery datasource="#variables.dsn#">
			insert into EmailHistory (
				userId,
				emailAddress,
				emailType
			)
			values (
				<cfqueryparam value="#arguments.userId#" null="#not len(arguments.userId)#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#arguments.emailAddress#" cfsqltype="cf_sql_varchar">,
				'PasswordResetEmail'
			)
		</cfquery>
		<cfreturn true>

	</cffunction>


</cfcomponent>
