<cfparam name="form.pageId" default="">
<cfparam name="form.pageName" default="">
<cfparam name="form.pageUrl" default="">
<cfparam name="form.userName" default="">
<cfparam name="form.pageType" default="">
<cfparam name="form.userId" default="">

<cfif len(form.pageId) and len(form.userId)>

	<cfquery datasource="#this.dsn#">
		if not exists (
			select 1
			from FacebookPages
			where page_id = <cfqueryparam value="#form.pageId#" cfsqltype="cf_sql_varchar">
		)
		begin
			insert into FacebookPages (
				page_id,
				name,
				page_url,
				username,
				type,
				addedBy
			)
			values (
				<cfqueryparam value="#form.pageId#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.pageName#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.pageUrl#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.userName#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.pageType#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.userId#" cfsqltype="cf_sql_varchar">
			)
		end
	</cfquery>
	
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