<cfsetting requesttimeout="9999">

<cfquery name="getUsers" datasource="#this.dsn#">
	select id
	from FacebookUsers
	where username is null
</cfquery>

<cfif getUsers.recordCount>

	<cfset init("Facebook")>

	<cfloop query="getUsers">

		<cfset oFacebook.getUser(
			Id = getUsers.id,
			access_token = credentials.facebook.page_access_token,
			save_results = true
		)>

	</cfloop>

</cfif>