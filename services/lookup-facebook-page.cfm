<cfparam name="url.searchTerm" default="">
<cfif len(url.searchTerm)>
	<cfset init("Facebook")>
	<cfset pages = oFacebook.getPage (
		searchTerm = url.searchTerm,
		access_token = credentials.facebook.page_access_token
	)>
	<cfoutput>#serializeJson(pages)#</cfoutput>
</cfif>