<!--- generate a clean feed by suppressing white space and debugging information. --->
<cfprocessingdirective suppresswhitespace="yes">
<cfsetting showdebugoutput="no">
<cfsetting enablecfoutputonly="true">
<cfcontent type="application/json">

<cfparam name="errorFields" default="">
<cfparam name="errorMessage" default="">
<cfparam name="success" default=false>
<cfparam name="form.firstName" default="">
<cfparam name="form.lastName" default="">
<cfparam name="form.emailAddress" default="">

<cfif not structKeyExists(form, "__token") or form.__token neq session.stamp>
	<!--- csrf attempt --->
	<cfset onRequestEnd(cgi.script_name)>
	<cfabort>
</cfif>

<cfif not len(form.firstName)>
	<cfset errorFields = listAppend(errorFields, "firstName")>
</cfif>
<cfif not len(form.lastName)>
	<cfset errorFields = listAppend(errorFields, "lastName")>
</cfif>
<cfif not isValid("email", form.emailAddress)>
	<cfset errorFields = listAppend(errorFields, "emailAddress")>
</cfif>

<cfif not len(errorFields)>
	<!--- look up username --->
	<cfset init("Users")>

	<cfset user = oUsers.getUsers(
		firstName=form.firstName,
		lastName=form.lastName,
		emailAddress=form.emailAddress
	)>

	<cfif user.recordCount>

		<cfset success = true>

		<cfset init("Mailbox")>
		<cfset oMailbox.sendForgotUsernameEmail(userId=user.userId, test=this.debugMode)>

	</cfif>

</cfif>

<cfoutput>{
	"success": #success#,
	"errorFields": "#errorFields#",
	"errorMessage": "#errorMessage#"
}</cfoutput>
</cfprocessingdirective>