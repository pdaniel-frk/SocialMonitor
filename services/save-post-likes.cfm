<cfparam name="form.pageId" default="#getToken(form.postId, 1, '_')#">
<cfparam name="form.postId" default="">
<cfparam name="form.user_id" default=""><!--- facebook user id of likee --->
<cfparam name="form.userId" default=""><!--- user id of logged-in user adding these records --->

<cfif len(form.pageId) and len(form.postId) and len(form.user_id) and len(form.userId)>
	
	<cfquery datasource="#this.dsn#">
		if not exists (
			select 1
			from FacebookPostLikes
			where post_id = <cfqueryparam value="#form.postId#" cfsqltype="cf_sql_varchar">
			and user_id = <cfqueryparam value="#form.user_id#" cfsqltype="cf_sql_varchar">
		)
		begin
			insert into FacebookPostLikes (
				page_id,
				post_id,
				[user_id],
				addedBy
			)
			values (
				<cfqueryparam value="#form.pageId#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.postId#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.user_id#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.userId#" cfsqltype="cf_sql_varchar">
			)
		end
	</cfquery>
	
</cfif>