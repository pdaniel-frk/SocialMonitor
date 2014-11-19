<cfif not len(trim(form.uName)) or not len(trim(form.uPass))>

	<div class="alert alert-warning">
		<button type="button" class="close" data-dismiss="alert">&times;</button>
		All fields below need to be completed.
	</div>

<cfelse>

	<cftransaction>

		<!--- validate login --->
		<cfset init("Users")>
		<cfset user = oUsers.getUsers(uName=form.uName)>
		<cfif user.recordCount>
			<cfset init("Passwords", "oPasswords", "BaseComponents")>
			<cfset passwordIsValid = oPasswords.comparePassword(uPass=form.uPass,uSalt=user.uSalt,passHash=user.uPass)>
			<cfif passwordIsValid>
				<cflock scope="session" timeout="4" throwontimeout="no">
					<cfset session.loggedIn = true>
					<cfset session.customerId = user.customerId>
					<cfset session.userId = user.userId>
					<cfset session.uName = user.uName>
					<cfset session.emailAddress = user.emailAddress>
					<cfset session.accessLevel = "">
				</cflock>
				<cfset reRoute(destination="index.cfm", message="You have been signed in.")>
			<cfelse>
				<div class="alert alert-danger">
					<button type="button" class="close" data-dismiss="alert">&times;</button>
					Either the username or password you have entered is incorrect.
				</div>
			</cfif>
		<cfelse>
			<div class="alert alert-danger">
				<button type="button" class="close" data-dismiss="alert">&times;</button>
				Either the username or password you have entered is incorrect.
			</div>
		</cfif>

	</cftransaction>

</cfif>