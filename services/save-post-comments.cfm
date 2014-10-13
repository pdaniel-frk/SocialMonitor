<cfparam name="form.scheduleId" default="">
<cfparam name="form.pageId" default="#getToken(form.postId, 1, '_')#">
<cfparam name="form.postId" default="">
<cfparam name="form.fromId" default="">
<cfparam name="form.postFBId" default="">
<cfparam name="form.id" default="">
<cfparam name="form.commentText" default="">
<cfparam name="form.commentTime" default="">
<cfparam name="form.userId" default="">

<cfif len(form.pageId) and len(form.postId) and len(form.fromId) and len(form.userId)>

	<cfset init("Facebook")>
	<cfset oFacebook.insertFacebookPostComment (
		argumentCollection = form
	)>

</cfif>