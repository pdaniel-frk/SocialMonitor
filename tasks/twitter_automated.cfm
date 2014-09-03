<cfsetting requesttimeout="999">

<!--- get everything on the schedule --->
<cfquery name="getSchedule" datasource="#this.dsn#">
	select 
		scheduleId, 
		searchTerm
	from Schedules
	where service = 'Twitter'
	and isdate(deleteDate) = 0
	and isnull(startdate, getdate()-1) <= getdate()
	and isnull(endDate, getdate()+1) >= getdate()
</cfquery>

<cfif getSchedule.recordCount>
	
	<cfloop query="getSchedule">
		
		<!--- get latest id and pull entries later than it --->
		<cfset since_id = "">
		<cfquery name="getSinceId" datasource="#this.dsn#">	
			select max(cast(id_str as bigint)) as since_id
			from TwitterEntries
			where scheduleId = <cfqueryparam value="#getSchedule.scheduleId#">
		</cfquery>
		<cfif len(getSinceId.since_id)>
			<cfset since_id = getSinceId.since_id>
		</cfif>
		
		<cfset q = URLEncodedFormat(getSchedule.searchTerm)>
		
		<cftry>
					
			<cfset searchResult =  application.objMonkehTweet.search(q=q, since_id=since_id, count=100)>
			
			<cfset searchCount = 0>
							
			<cfset searchCount += arrayLen(searchResult.statuses)>
			
			<cfloop from="1" to="#arrayLen(searchResult.statuses)#" index="ndx">
				
				<cfset image_url = "">
				<cfif structKeyExists(searchResult.statuses[ndx].entities, "media")>
					<cfset image_url = searchResult.statuses[ndx].entities.media[1].media_url_https>
				</cfif>
				
				<!--- import entries into database --->
				<cfquery datasource="#this.dsn#">
					if not exists (
						select 1
						from TwitterEntries
						where id_str = <cfqueryparam value="#searchResult.statuses[ndx].id_str#" cfsqltype="cf_sql_varchar">
						and scheduleId = <cfqueryparam value="#getSchedule.scheduleId#" cfsqltype="cf_sql_integer">
					)
					begin
						insert into TwitterEntries (
							[scheduleId],
							[searchTerm],
							[Id],
							[id_str],
							[created_at],
							[geo.coordinates.latitude],
							[geo.coordinates.longitude],
							[geo.coordinates.type],
							[lang],
							[text],
							[user.id],
							[media.media_url_https]
						)
						values (
							<cfqueryparam value="#getSchedule.scheduleId#" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#getSchedule.searchTerm#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#searchResult.statuses[ndx].Id#" cfsqltype="cf_sql_bigint">,
							<cfqueryparam value="#searchResult.statuses[ndx].id_str#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#searchResult.statuses[ndx].created_at#" cfsqltype="cf_sql_varchar">,
							<cfif isStruct(searchResult.statuses[ndx].geo)>
								<cfqueryparam value="#searchResult.statuses[ndx].geo.coordinates[1]#" cfsqltype="cf_sql_float">,
								<cfqueryparam value="#searchResult.statuses[ndx].geo.coordinates[2]#" cfsqltype="cf_sql_float">,
								<cfqueryparam value="#searchResult.statuses[ndx].geo.type#" cfsqltype="cf_sql_varchar">,
							<cfelse>
								null,
								null,
								null,
							</cfif>
							<cfqueryparam value="#searchResult.statuses[ndx].lang#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#searchResult.statuses[ndx].text#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#searchResult.statuses[ndx].user.id#" cfsqltype="cf_sql_bigint">,
							<cfqueryparam value="#image_url#" cfsqltype="cf_sql_varchar">
						)
					end
				</cfquery>
				
				<!--- import users --->
				<cfquery datasource="#this.dsn#">
					if not exists (
						select 1
						from TwitterUsers
						where [user.id] = <cfqueryparam value="#searchResult.statuses[ndx].user.id#" cfsqltype="cf_sql_bigint">
					)
					begin
						insert into TwitterUsers (
							[user.id],
							[user.id_str],
							[user.location],
							[user.name],
							[user.screen_name],
							[user.url]
						)
						values (
							<cfqueryparam value="#searchResult.statuses[ndx].user.id#" cfsqltype="cf_sql_bigint">,
							<cfqueryparam value="#searchResult.statuses[ndx].user.id_str#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#searchResult.statuses[ndx].user.location#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#searchResult.statuses[ndx].user.name#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#searchResult.statuses[ndx].user.screen_name#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#searchResult.statuses[ndx].user.url#" cfsqltype="cf_sql_varchar">
						)
					end
				</cfquery>
				
			</cfloop>
			
			<cfcatch type="any">
				<cfdump var="#cfcatch#">
			</cfcatch>
			
		</cftry>
		
	</cfloop>
	
</cfif>
