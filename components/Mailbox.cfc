<cfcomponent output="false">

	<cffunction name="init" output="no">

		<!--- define arguments --->
		<cfargument name="dsn" required="true" type="string">
		<cfargument name="custServEmail" required="no" default="pickacardanycard@mkpromosource.com">

		<!--- set variables scope --->
		<cfset variables.dsn = arguments.dsn>
		<cfset variables.custServEmail = arguments.custServEmail>

		<cfreturn this>
	</cffunction>


	<cffunction name="checkUnsubscribers" output="no" returntype="boolean">
		<cfargument name="emailAddress" required="yes" type="string">
		<cfquery name="check" datasource="#variables.dsn#">
			select 1
			from UnsubscribeLog
			where emailAddress = <cfqueryparam value="#arguments.emailAddress#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn check.recordCount gt 0>
	</cffunction>


	<cffunction name="sendRegistrationConfirmationEmail" output="no" returntype="boolean">

		<cfargument name="userId" required="yes" type="numeric">
		<cfargument name="trainingModuleName" required="no" type="string" default="Pick a Card... Any Card">
		<cfargument name="test" required="no" type="boolean" default=false>

		<cfset oUsers = createObject("component", "Users").init(variables.dsn)>
		<cfset oUsers = createObject("component", "Users").init(variables.dsn)>
		<cfset userDetails = oUsers.getUserDetails(userId=arguments.userId)>

		<cfif not userDetails.recordCount>
			<cfreturn false>
		<cfelse>
			<cfset arguments.emailAddress = userDetails.emailAddress>
			<cfset arguments.firstName = userDetails.firstName>
			<cfset arguments.lastName = userDetails.lastName>
			<cfset arguments.uName = userDetails.uName>
		</cfif>

		<!--- check against unsubscribe table --->
		<cfif checkUnsubscribers(emailAddress = arguments.emailAddress)>
			<cfreturn false>
		</cfif>

		<cfset emailTo = arguments.emailAddress>
		<cfset emailFrom = variables.custServEmail>
		<cfif arguments.test>
			<cfset emailTo = "egrimm@mardenkane.com">
			<cfset emailFrom = "egrimm@mardenkane.com">
		</cfif>

		<cfmail to="#emailTo#" from="#emailFrom#" subject="Your #arguments.trainingModuleName# Registration" type="html">
			<cfinclude template="mail_header.cfm">
			<p>Hello #arguments.firstName# #arguments.lastName#.</p>
			<p>Thank you for registering to access the #arguments.trainingModuleName# promotion training module.  You will find interesting product details, useful training information and exciting prize information there.  <a href="#request.siteUrl#">Click here</a> to get started!</p>
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
				'RegistrationConfirmationEmail'
			)
		</cfquery>
		<cfreturn true>

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


	<cffunction name="sendContactUsEmail" output="no" returntype="boolean">

		<cfargument name="contactUsLogId" required="yes" type="numeric">
		<cfargument name="trainingModuleName" required="no" type="string" default="Pick a Card... Any Card">
		<cfargument name="test" required="no" type="boolean" default=false>

		<cfset oContact = createObject("component", "Contact").init(variables.dsn)>
		<cfset contactDetails = oContact.getContactUsLogDetails(contactUsLogId=contactUsLogId)>

		<cfif not contactDetails.recordCount>
			<cfreturn false>
		</cfif>

		<cfset emailTo = variables.custServEmail>
		<cfset emailFrom = contactDetails.emailAddress>
		<cfif arguments.test>
			<cfset emailTo = "egrimm@mardenkane.com">
			<cfset emailFrom = "egrimm@mardenkane.com">
		</cfif>

		<cfmail to="#emailTo#" from="#emailFrom#" subject="A #arguments.trainingModuleName# Inquiry Has Been Received" type="html">
			<cfinclude template="mail_header.cfm">
			<p>Hello Customer Service Team!</p>
			<p>A user submitted the following query using the Contact Us feature of the site:</p>
			<hr>
			<p style="padding-left:1em;font-family:Courier, monospace;">
				#HTMLEditFormat(contactDetails.firstName)# #HTMLEditFormat(contactDetails.lastName)#<br>
				#HTMLEditFormat(contactDetails.phoneNumber)#<br>
				#HTMLEditFormat(contactDetails.emailAddress)#<br>
			</p>
			<p style="padding-left:1em;font-family:Courier, monospace;">#HTMLEditFormat(contactDetails.contactQuery)#</p>
			<hr>
			<p>Sent at #dateformat(now(), 'mm/dd/yyyy')# #timeformat(now(), 'hh:mmTT')#</p>
			<cfinclude template="mail_footer.cfm">
		</cfmail>

		<!--- insert record into email history table --->
		<cfquery datasource="#variables.dsn#">
			insert into EmailHistory (
				contactUsLogId,
				emailAddress,
				emailType
			)
			values (
				<cfqueryparam value="#contactDetails.contactUsLogId#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#contactDetails.emailAddress#" cfsqltype="cf_sql_varchar">,
				'ContactUsEmail'
			)
		</cfquery>

		<cfreturn true>

	</cffunction>

</cfcomponent>
