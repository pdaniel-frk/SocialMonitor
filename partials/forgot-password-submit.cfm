<!--- generate a clean feed by suppressing white space and debugging information. --->
<cfprocessingdirective suppresswhitespace="yes">
<cfsetting showdebugoutput="no">
<cfsetting enablecfoutputonly="true">
<cfcontent type="application/json">

<cfparam name="errorFields" default="">
<cfparam name="errorMessage" default="">
<cfparam name="success" default=false>
<cfparam name="form.uName" default="">

<cfif not structKeyExists(form, "__token") or form.__token neq session.stamp>
	<!--- csrf attempt --->
	<cfset onRequestEnd(cgi.script_name)>
	<cfabort>
</cfif>

<!--- look up user --->
<cfset init("Users")>
<cfset user = oUsers.getUsers(uName=form.uName)>
<cfif user.recordCount>
	<!--- generate token --->
	<cfset init("Passwords", "oPasswords", "BaseComponents")>
	<cfset token = oPasswords.resetPassword(userId=user.userId)>
	<!--- send to email address --->
	<cfset init("Mailbox")>
	<cfset mailSuccess = oMailbox.sendPasswordResetEmail(
		userId=user.userId,
		token=token,
		test=this.debugMode)>
	<cfset success = mailSuccess>
</cfif>

<cfoutput>{
	"success": #success#,
	"errorFields": "#errorFields#",
	"errorMessage": "#errorMessage#"
}</cfoutput>
</cfprocessingdirective>