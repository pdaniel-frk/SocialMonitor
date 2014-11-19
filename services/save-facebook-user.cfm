<!--- i dont think this page is called from anywhere currently (2014-10-10) --->
<cfparam name="form.user_id" default="">
<cfparam name="form.email" default="">
<cfparam name="form.first_name" default="">
<cfparam name="form.last_name" default="">
<cfparam name="form.username" default="">
<cfparam name="form.timezone" default="">
<cfparam name="form.locale" default="">
<cfparam name="form.profile_url" default="">
<cfparam name="form.birthday_date" default="">
<cfparam name="form.userId" default="">

<cfif len(form.user_id) and len(form.userID)>

	<cfset init("Entrants")>
	<cfset oEntrants.insertFacebookUser(
		argumentCollection = form
	)>

</cfif>