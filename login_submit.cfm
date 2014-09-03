<cfif not len(trim(form.uName)) or not len(trim(form.uPass))>

	<div class="alert alert-warning">
		<button type="button" class="close" data-dismiss="alert">&times;</button>
		All fields below need to be completed.
	</div>

<cfelse>

	<cfset init("Logins","oLogins","BaseComponents")>
	
	<cfset loginID = oLogins.getLogins(uName=form.uName).loginID>
	
	<cfif len(trim(loginID))>
	
		<cfset loginDetail = oLogins.getLoginDetails(loginID)>

		<!--- validate the password --->
		<cfset passwordIsValid = oLogins.comparePassword(uPass=form.uPass, uSalt=loginDetail.uSalt, passHash=loginDetail.uPass)>
			
		<cfif passwordIsValid>
			
			<!--- log user in and forward to index --->
			<cfset oLogins.updateLoginDate(loginID)>
			<!--- get logintrackingid for tracking porpoises --->
			<cfset init("Tracking","oTracking","BaseComponents")>
			<cflock scope="session" timeout="7">
				<cfset session.loggedIn = true>
				<cfset session.loginTrackingID = oTracking.trackLogin(loginID = loginID)>
				<cfset session.loginID = loginID>
				<cfset session.uName = trim(form.uName)>
				<cfset session.emailAddress = loginDetail.emailAddress>
				<cfset session.accessLevel = loginDetail.accessLevel>
			</cflock>
			
			<div class="alert alert-success">
				<button type="button" class="close" data-dismiss="alert">&times;</button>
				You have been signed in.
			</div>
			
			<!--- show progress bar --->
			<div class="progress progress-striped progress-success active">
				<div class="progress-bar" style="width: 100%;"></div>
			</div>
			
			<script type="text/javascript">
				window.setTimeout( function() {  location='index.cfm' }, 3000 );
			</script>
			
			<cfset onRequestEnd(cgi.script_name)>
			<cfabort>
			
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
	
</cfif>