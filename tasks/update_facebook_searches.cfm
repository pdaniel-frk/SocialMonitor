<cfquery name="getSearchIds" datasource="#this.dsn#">
	select search_id
	from FacebookSearches
</cfquery>

<cfloop query="getSearchIds">
	<!--- get object details --->
	<cfhttp url="https://graph.facebook.com/v2.1/#getSearchIds.search_id#" method="get" charset="utf-8">
		<cfhttpparam type="url" name="access_token" value="#credentials.facebook.page_access_token#">
	</cfhttp>
	<cftry>
		<cfset result = deserializeJson(cfhttp.fileContent)>
		<cfset story = "">
		<cfset name = "">
		<cfset caption = "">
		<cfset message = "">
		<cfset description = "">
		<cfif structKeyExists(result, 'story')>
			<cfset story = result.story>
		</cfif>
		<cfif structKeyExists(result, 'name')>
			<cfset name = result.name>
		</cfif>
		<cfif structKeyExists(result, 'caption')>
			<cfset caption = result.caption>
		</cfif>
		<cfif structKeyExists(result, 'message')>
			<cfset message = result.message>
		</cfif>
		<cfif structKeyExists(result, 'description')>
			<cfset description = result.description>
		</cfif>
		<cfquery datasource="#this.dsn#">
			update FacebookSearches
			set
				story = <cfqueryparam value="#story#" null="#not len(story)#" cfsqltype="cf_sql_varchar">,
				name =  <cfqueryparam value="#name#" null="#not len(name)#" cfsqltype="cf_sql_varchar">,
				caption =  <cfqueryparam value="#caption#" null="#not len(caption)#" cfsqltype="cf_sql_varchar">,
				message =  <cfqueryparam value="#message#" null="#not len(message)#" cfsqltype="cf_sql_varchar">,
				description =  <cfqueryparam value="#description#" null="#not len(description)#" cfsqltype="cf_sql_varchar">
			where search_id =  <cfqueryparam value="#getSearchIds.search_id#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfcatch type="any"></cfcatch>
	</cftry>
</cfloop>