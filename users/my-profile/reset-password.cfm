<!--- validate url parameters --->
<cfparam name="url.email" default="">
<cfparam name="url.token" default="">

<cfif not isValid("email", url.email) or not len(url.token)>

	<!--- missing or invalid url params --->
	<cfset reRoute(destination="#request.webRoot#", message="Sorry, you seem to have arrived at this location in error.")>

<cfelse>

	<cfset init("Passwords", "oPasswords", "BaseComponents")>
	<cfset passwordResetId = oPasswords.lookupToken(token=url.token)>
	<cfif passwordResetId gt 0>
		<!--- get user associated with token --->
		<cfset userId = oPasswords.getTokenDetails(passwordResetId=passwordResetId).userId>
		<cfset init("Users")>
		<cfset user = oUsers.getUsers(userId=userId)>
		<cfif user.emailAddress neq url.email>
			<!--- token associated with different user --->
			<cfset reRoute(destination="#request.webRoot#", message="Sorry, you seem to have arrived at this location in error.")>
		</cfif>
	<cfelse>
		<!--- invalid token --->
		<cfset reRoute(destination="#request.webRoot#", message="Sorry, you seem to have arrived at this location in error.")>
	</cfif>

</cfif>

<h1 class="page-header">
	Reset Your Password
</h1>

<div class="row" style="margin-bottom:1em;">
	<div class="col-xs-12">
		<p class="large">Please fill out the following form to update your password.</p>
	</div>
</div>

<cfparam name="form.uName" default="">
<cfparam name="form.new_uPass" default="">
<cfparam name="form.new_uPass_Confirm" default="">

<cfparam name="errorFields" default="">

<cfif structKeyExists(form, "__token")>
	<cfinclude template="reset-password-submit.cfm">
</cfif>

<div class="row" style="margin-bottom:1em;">

	<div class="col-xs-12">

		<cfoutput>

			<form class="form form-horizontal" name="passwordResetForm" method="post" novalidate>

			<div class="alert alert-danger form-errors" <cfif not listLen(errorFields)>style="display:none;"</cfif>>
				<button type="button" class="close" data-dismiss="alert">&times;</button>
				<div class="invalid-fields form-error">
					All highlighted fields below need to be completed.
				</div>
				<div class="invalid-username form-error" style="display:none;">
					The Username you entered is incorrect.
				</div>
				<div class="password-match form-error" style="display:none;">
					The New Password and New Password Confirmation you entered do not match.
				</div>
			</div>

				<div class="form-group <cfif findNoCase('uName', errorFields)>has-error</cfif>">
					<label for="uName" class="col-xs-2 control-label">Username</label>
					<div class="col-xs-6">
						<input type="text" name="uName" id="uName" class="form-control" maxlength="50" required value="#HTMLEditFormat(form.uName)#">
					</div>
				</div>

				<div class="form-group <cfif findNoCase('new_uPass', errorFields)>has-error</cfif>">
					<label for="new_uPass" class="col-xs-2 control-label">New Password</label>
					<div class="col-xs-6">
						<input type="password" name="new_uPass" id="new_uPass" class="form-control" required>
					</div>
				</div>

				<div class="form-group <cfif findNoCase('new_uPass_Confirm', errorFields)>has-error</cfif>">
					<label for="new_uPass_Confirm" class="col-xs-2 control-label">Confirm New Password</label>
					<div class="col-xs-6">
						<input type="password" name="new_uPass_Confirm" id="new_uPass_Confirm" class="form-control" required>
					</div>
				</div>

				<div class="form-group">
					<div class="col-xs-6 col-xs-offset-2">
						<input type="submit" class="btn btn-lg btn-primary" value="Submit">
					</div>
				</div>

				<input type="hidden" name="__token" value="#session.stamp#">

			</form>

		</cfoutput>

	</div>

</div>