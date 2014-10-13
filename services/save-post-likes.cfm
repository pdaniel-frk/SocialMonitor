<cfparam name="form.scheduleId" default="">
<cfparam name="form.pageId" default="#getToken(form.postId, 1, '_')#">
<cfparam name="form.postId" default="">
<cfparam name="form.user_id" default=""><!--- facebook user id of likee --->
<cfparam name="form.userId" default=""><!--- user id of logged-in user adding these records --->

<cfif len(form.pageId) and len(form.postId) and len(form.user_id) and len(form.userId)>

	<cfset init("Facebook")>
	<cfset oFacebook.insertFacebookPostLike (
		argumentCollection = form
	)>

</cfif>