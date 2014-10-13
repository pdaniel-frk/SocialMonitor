<cfparam name="form.scheduleId" default="">
<cfparam name="form.pageId" default="">
<cfparam name="form.pageName" default="">
<cfparam name="form.pageUrl" default="">
<cfparam name="form.userName" default="">
<cfparam name="form.pageType" default="">
<cfparam name="form.userId" default="">

<cfif len(form.pageId) and len(form.userId)>

	<cfset init("Facebook")>
	<cfset oFacebook.insertFacebookPage (
		argumentCollection = form
	)>

	<!--- <cfif structKeyExists(session, "user_pages")>
		<cfif not listFind(session.user_pages, form.pageId)>
			<cfset session.user_pages = listAppend(session.user_pages, form.pageId)>
		</cfif>
	</cfif> --->

</cfif>

<!--- <cfmail to="egrimm@mardenkane.com" from="egrimm@mardenkane.com" subject="save page called" type="html">
	<p>save page function called</p>
	<cfdump var="#form#">
</cfmail> --->