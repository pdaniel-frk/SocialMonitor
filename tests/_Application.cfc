<cfcomponent output="true" extends="SocialMonitor.Application"><!--- need a mapping for this to work, yosef! --->


	<!--- onRequest --->
	<cffunction name="onRequest" access="public" output="yes">

		<cfargument name="template" required="yes" type="string">


		<cfif not structKeyExists(session, "loggedIn")>
			<cfset session.loggedIn = false>
		</cfif>

		<cfif isDefined("form.upass")
			and len(trim(form.upass))
			and hash(form.upass, 'SHA-1') eq "CAE355B615B61313E7A2D42D0C650F705DC3D94E"><!--- please --->

			<cflock scope="session" type="exclusive" timeout="4">
				<cfset session.loggedIn = true>
			</cflock>

		</cfif>

		<cfif not session.loggedIn>

			<p class="lead">Please enter the password to access this feature.</p>
			<form class="form-inline" method="post">
				<input type="password" name="upass" id="upass" placeholder="Some type of secret phrase">
				<input type="submit" value="Sign In" class="btn btn-primary">
			</form>

		<cfelse>

			<cfinclude template="#arguments.template#">

		</cfif>

	</cffunction>


</cfcomponent>