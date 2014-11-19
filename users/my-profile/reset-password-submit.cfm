<!--- <p>validating form fields for content, format</p> --->
<cfif not len(form.uName)>
	<cfset errorFields = listAppend(errorFields, "uName")>
<cfelse>
	<!--- make sure the username is actually associated with the email --->
	<cfif form.uName neq user.uName>
		<cfset errorFields = listAppend(errorFields, "uName")>
		<cfset errorFields = listAppend(errorFields, "invalidUsername")>
	</cfif>
</cfif>

<cfif not len(form.new_uPass)>
	<cfset errorFields = listAppend(errorFields, "new_uPass")>
</cfif>

<cfif not len(form.new_uPass_Confirm)>
	<cfset errorFields = listAppend(errorFields, "new_uPass_Confirm")>
</cfif>

<cfif len(form.new_uPass) and len(form.new_uPass_Confirm)>

	<!--- do they match? --->
	<cfif form.new_uPass neq form.new_uPass_Confirm>
		<cfset errorFields = listAppend(errorFields, "new_uPass")>
		<cfset errorFields = listAppend(errorFields, "new_uPass_Confirm")>
		<cfset errorFields = listAppend(errorFields, "passwordMatchFailed")>
	</cfif>

</cfif>

<cfif not len(errorFields)>

	<cftry>

		<cftransaction>

			<cfset init("Users")>
			<cfset init("Passwords", "oPasswords", "BaseComponents")>
			<cfset newSalt = oPasswords.generateSalt()>
			<cfset newPassword = oPasswords.hashPassword(uPass=form.new_uPass, uSalt=newSalt)>
			<cfset oUsers.updateUser(
				userId = userId,
				uSalt = newSalt,
				uPass = newPassword
			)>

			<!--- consume the password reset token --->
			<cfset oPasswords.useToken(passwordResetId=passwordResetId)>

		</cftransaction>

		<cfcatch type="any">
			<div class="alert alert-danger">
				<h4>Error!</h4>
				<p>I'm sorry, but something has gone terribly awry.</p>
				<p>A system administrator has been notified. Please try your request again later.</p>
			</div>

			<cfif this.debugMode>
				<div class="alert alert-warning">
					<cfoutput>#handleErrors(cfcatch, true)#</cfoutput>
				</div>
			</cfif>
			<cfset onError(cfcatch)>
			<!--- <cfset onRequestEnd(cgi.script_name)> --->
			<cfabort>
		</cfcatch>

	</cftry>

</cfif>

<!--- check again! --->
<cfif len(errorFields)>

	<script>
		$(function(){
			<cfif listFindNoCase(errorFields, "invalidUsername")>
				$('.invalid-username').show();
			</cfif>
			<cfif listFindNoCase(errorFields, "passwordMatchFailed")>
				$('.password-match').show();
			</cfif>
			$('.form-errors').fadeIn('slow');
		});
	</script>

<cfelse>

	<cfset reRoute(destination="#request.webRoot#", message="Your password has been reset. Please login.")>

</cfif>