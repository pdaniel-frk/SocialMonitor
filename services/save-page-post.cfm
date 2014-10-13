<cfparam name="form.scheduleId" default="">
<cfparam name="form.pageId" default="#getToken(form.postId, 1, '_')#">
<cfparam name="form.postId" default="">
<cfparam name="form.searchTerm" default="">
<cfparam name="form.message" default="">
<cfparam name="form.created_time" default="">
<cfparam name="form.postType" default="">
<cfparam name="form.userId" default="">

<cfif len(form.pageId) and len(form.postId) and len(form.userId)>

	<cfset init("Facebook")>
	<cfset oFacebook.insertFacebookPost (
		argumentCollection = form
	)>

</cfif>