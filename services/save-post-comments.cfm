<cfparam name="form.pageId" default="#getToken(form.postId, 1, '_')#">
<cfparam name="form.postId" default="">
<cfparam name="form.fromId" default="">
<cfparam name="form.postFBId" default="">
<cfparam name="form.id" default="">
<cfparam name="form.commentText" default="">
<cfparam name="form.commentTime" default="">
<cfparam name="form.userId" default="">

<cfif len(form.pageId) and len(form.postId) and len(form.fromId) and len(form.userId)>
	
	<cfquery datasource="#this.dsn#">
		if not exists (
			select 1
			from FacebookPostComments
			where post_fbid = <cfqueryparam value="#form.postFBId#" cfsqltype="cf_sql_varchar">
		)
		begin
			insert into FacebookPostComments (
				page_id,
				post_id,
				[text],
				id,
				post_fbid,
				fromid,
				[time],
				addedBy
			)
			values (
				<cfqueryparam value="#form.pageId#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.postId#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.commentText#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.id#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.postFBId#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.fromId#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.commentTime#" cfsqltype="cf_sql_bigint">,
				<cfqueryparam value="#form.userId#" cfsqltype="cf_sql_varchar">
			)
		end
	</cfquery>
	
</cfif>