<cfsetting requesttimeout="999">

<!--- get everything on the schedule --->
<cfquery name="getSchedule" datasource="#this.dsn#">
	select
		scheduleId,
		searchTerm
	from Schedules
	where service = 'Instagram'
	and isdate(deleteDate) = 0
	<cfif structKeyExists(url, "scheduleId")>
		and scheduleId = <cfqueryparam value="#url.scheduleId#" cfsqltype="cf_sql_integer">
	<cfelse>
		and isnull(startdate, getdate()-1) <= getdate()
		and isnull(endDate, getdate()+1) >= getdate()
	</cfif>
</cfquery>

<cfif getSchedule.recordCount>

	<cfloop query="getSchedule">

		<cfset getSchedule.searchTerm = replace(getSchedule.searchTerm, '##', '', 'All')><!--- using # or %23 leads to a 404; --->
		<!--- with no since_id, it'll crawl back FOREVER, so give it something reasonable as a minimum' --->
		<!--- <cfset since_id = "1405036800000"> ---><!--- select cast(abs(dateDiff(s, '2014-07-11', '1970-01-01')) as bigint)*1000 --->

		<cfquery name="getSinceId" datasource="#this.dsn#">
			select coalesce(
				max(created_time)*1000,
				cast(abs(dateDiff(s, dateadd(dd, datediff(dd, 0, getdate())-7, 0), '1970-01-01')) as bigint)*1000
			) as since_id
			from InstagramEntries
			where searchTerm = <cfqueryparam value="#getSchedule.searchTerm#" cfsqltype="cf_sql_varchar">
			and scheduleId = <cfqueryparam value="#getSchedule.scheduleId#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfif len(getSinceId.since_id)>
			<cfset since_id = getSinceId.since_id>
		</cfif>

		<cfset min_tag_id = "#since_id#">
		<cfset max_tag_id = "">
		<cfset EOF = false>
		<cfset sanityCheck = 10>
		<cfset loopCount = 0>
		<cfset searchCount = 0>
		<cfset counter = 1>

		<cfloop condition="NOT EOF">

			<!--- the call will return up to 20(30?) of the most recently-tagged items, so we may need to work backward until were at or before the min_tag_id parameter --->
			<cfhttp method="get" url="https://api.instagram.com/v1/tags/#getSchedule.searchTerm#/media/recent?client_id=#credentials.instagram.client_id#&min_tag_id=#min_tag_id#&max_tag_id=#max_tag_id#&count=50"></cfhttp>
			<cfset result = deserializeJson(cfhttp.fileContent)>

			<cfif not structKeyExists(result, "error")>

				<cfif arrayLen(result.data)>

					<cfloop from="1" to="#arrayLen(result.data)#" index="ndx">

						<cftry>

							<!--- save to database --->
							<cfquery datasource="#this.dsn#">
								if not exists (
									select 1
									from InstagramEntries
									where Id = <cfqueryparam value="#result.data[ndx].id#">
									and scheduleId = <cfqueryparam value="#getSchedule.scheduleId#" cfsqltype="cf_sql_integer">
								)
								begin
									insert into InstagramEntries (
										[scheduleId],
										[Id],
										[SearchTerm],
										[caption.created_time],
										[caption.from.full_name],
										[caption.from.id],
										[caption.from.profile_picture],
										[caption.from.username],
										[caption.id],
										[caption.text],
										[created_time],
										[images.low_resolution.url],
										[images.standard_resolution.url],
										[images.thumbnail.url],
										[link],
										[location.latitude],
										[location.longitude],
										[location.id],
										[tags],
										[type],
										[user.id]
									)
									values (
										<cfqueryparam value="#getSchedule.scheduleId#" cfsqltype="cf_sql_integer">,
										<cfqueryparam value="#result.data[ndx].id#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="#getSchedule.searchTerm#" cfsqltype="cf_sql_varchar">,
										<cfif isStruct(result.data[ndx].caption)>
											<cfqueryparam value="#result.data[ndx].caption.created_time#" cfsqltype="cf_sql_bigint">,
											<cfqueryparam value="#result.data[ndx].caption.from.full_name#" cfsqltype="cf_sql_varchar">,
											<cfqueryparam value="#result.data[ndx].caption.from.id#" cfsqltype="cf_sql_bigint">,
											<cfqueryparam value="#result.data[ndx].caption.from.profile_picture#" cfsqltype="cf_sql_varchar">,
											<cfqueryparam value="#result.data[ndx].caption.from.username#" cfsqltype="cf_sql_varchar">,
											<cfqueryparam value="#result.data[ndx].caption.id#" cfsqltype="cf_sql_bigint">,
											<cfqueryparam value="#result.data[ndx].caption.text#" cfsqltype="cf_sql_varchar">,
										<cfelse>
											null,
											null,
											null,
											null,
											null,
											null,
											null,
										</cfif>
										<cfqueryparam value="#result.data[ndx].created_time#" cfsqltype="cf_sql_bigint">,
										<cfqueryparam value="#result.data[ndx].images.low_resolution.url#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="#result.data[ndx].images.standard_resolution.url#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="#result.data[ndx].images.thumbnail.url#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="#result.data[ndx].link#" cfsqltype="cf_sql_varchar">,
										<!--- location might be null OR IT MIGHT BE AN ID! --->
										<cfif isStruct(result.data[ndx].location)>
											<cfif structKeyExists(result.data[ndx].location, "id")>
												null,
												null,
												<cfqueryparam value="#result.data[ndx].location.id#" cfsqltype="cf_sql_bigint">,
											<cfelse>
												<cfqueryparam value="#result.data[ndx].location.latitude#" cfsqltype="cf_sql_float">,
												<cfqueryparam value="#result.data[ndx].location.longitude#" cfsqltype="cf_sql_float">,
												null,
											</cfif>
										<cfelse>
											null,
											null,
											null,
										</cfif>
										<cfif isArray(result.data[ndx].tags)>
											<cfqueryparam value="#arrayToList(result.data[ndx].tags)#" cfsqltype="cf_sql_varchar">,
										<cfelse>
											null,
										</cfif>
										<cfqueryparam value="#result.data[ndx].type#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="#result.data[ndx].user.id#" cfsqltype="cf_sql_bigint">
									)
								end
							</cfquery>

							<cfquery datasource="#this.dsn#">
								if not exists (
									select 1
									from InstagramUsers
									where [user_id] = <cfqueryparam value="#result.data[ndx].user.id#">
								)
								begin
									insert into InstagramUsers (
										[bio],
										[full_name],
										[user_id],
										[profile_picture],
										[username],
										[website]
									)
									values (
										<cfqueryparam value="#result.data[ndx].user.bio#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="#result.data[ndx].user.full_name#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="#result.data[ndx].user.id#" cfsqltype="cf_sql_bigint">,
										<cfqueryparam value="#result.data[ndx].user.profile_picture#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="#result.data[ndx].user.username#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="#result.data[ndx].user.website#" cfsqltype="cf_sql_varchar">
									)
								end
							</cfquery>

							<cfcatch type="any">
								<cfdump var="#cfcatch#">
								<cfdump var="#result.data[ndx]#">
								<cfabort>
							</cfcatch>

						</cftry>

						<cfset counter += 1>

					</cfloop>

					<cfset loopCount += 1>
					<cfif loopCount gte sanityCheck>
						<cfset EOF = true>

						<div class="alert alert-warning">
							 <button type="button" class="close" data-dismiss="alert">&times;</button>
							 <cfoutput>Loop count exceeded sanity check for term #getSchedule.searchTerm#</cfoutput>
						</div>
					</cfif>

					<cfif structKeyExists(result.pagination, "next_max_id")>

						<cfset max_tag_id = result.pagination['next_max_id']>

						<cfif numberFormat(max_tag_id) LTE numberFormat(min_tag_id)>

							<cfset EOF = true>

						</cfif>

					<cfelse>

						<cfset EOF = true>

					</cfif>

				<cfelse>

					<cfset EOF = true>

				</cfif><!--- </cfif arrayLen(result.data)> --->

			<cfelse>

				<!--- handle errors as you see fit --->
				<cfdump var="#result#">
				<cfset EOF = true>

			</cfif><!--- </cfif not structKeyExists(result, "error")> --->

		</cfloop><!--- </cfloop condition="NOT EOF"> --->

	</cfloop>

</cfif>
