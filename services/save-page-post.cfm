<cfparam name="form.pageId" default="#getToken(form.postId, 1, '_')#">
<cfparam name="form.postId" default="">
<cfparam name="form.message" default="">
<cfparam name="form.created_time" default="">
<cfparam name="form.postType" default="">
<cfparam name="form.userId" default="">

<cfif len(form.pageId) and len(form.postId) and len(form.userId)>
	
	<cfquery datasource="#this.dsn#">
		if not exists (
			select 1
			from FacebookPagePosts
			where post_id = <cfqueryparam value="#form.postId#" cfsqltype="cf_sql_varchar">
		)
		begin
			insert into FacebookPagePosts (
				page_id,
				post_id,
				message,
				created_time,
				type,
				addedBy
			)
			values (
				<cfqueryparam value="#form.pageId#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.postId#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.message#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.created_time#" cfsqltype="cf_sql_bigint">,
				<cfqueryparam value="#form.postType#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.userId#" cfsqltype="cf_sql_varchar">
			)
		end
	</cfquery>
	
</cfif>