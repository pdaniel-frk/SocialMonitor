<cfsetting requesttimeout="999">

<cfparam name="url.scheduleId" default="">
<cfset init("Schedules")>
<cfset getSchedule = oSchedules.getSchedules (
	service = 'Vine',
	scheduleId = url.scheduleId,
	currentlyRunning = true
)>

<cfif getSchedule.recordCount>

	<cfloop query="getSchedule">

		<cfhttp method="get" url="https://api.vineapp.com/timelines/tags/#getSchedule.searchTerm#"></cfhttp>
		<cfset searchResult = deserializeJson(cfhttp.fileContent)>

		<cfset searchCount = 0>
		<cfset searchCount += searchResult.data.count>
		<cfset pages = ceiling(searchCount / 20)>

		<cfif searchCount gt 0>

			<cfloop from="1" to="#pages#" index="page">

				<cfhttp method="get" url="https://api.vineapp.com/timelines/tags/#getSchedule.searchTerm#?page=#page#" charset="utf-8"></cfhttp>
				<cfset pageResult = deserializeJson(cfhttp.fileContent)>
				<cfset pageCount = arrayLen(pageResult.data.records)>

				<cfloop from="1" to="#pageCount#" index="ndx">

					<cftry>

						<cfset record = structGet('pageResult.data.records[#ndx#]')>

						<cfset userId = convertNum(record.userId)>
						<cfset postId = convertNum(record.postId)>
						<cfset user = getVineUser(userId)>
						<cfset created_date = getToken(record.created, 1, 'T')>
						<cfset created_time = getToken(record.created, 2, 'T')>
						<cfset created = createDateTime(year(created_date), month(created_date), day(created_date), hour(created_time), minute(created_time), second(created_time))>

						<!--- import entries into database --->
						<cfquery datasource="#this.dsn#">
							if not exists (
								select 1
								from VineEntries
								where postId = <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">
								and scheduleId = <cfqueryparam value="#getSchedule.scheduleId#" cfsqltype="cf_sql_integer">
							)
							begin
								insert into VineEntries (
									scheduleId,
									searchTerm,
									userId,
									postId,
									description,
									explicitContent,
									permalinkUrl,
									thumbnailUrl,
									videoLowUrl,
									videoUrl,
									created
								)
								values (
									<cfqueryparam value="#getSchedule.scheduleId#" cfsqltype="cf_sql_integer">,
									<cfqueryparam value="#getSchedule.searchTerm#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#userId#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#record.description#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#record.explicitContent#" cfsqltype="cf_sql_bit">,
									<cfqueryparam value="#record.permalinkUrl#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#record.thumbnailUrl#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#record.videoLowUrl#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#record.videoUrl#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#created#" cfsqltype="cf_sql_timestamp">
								)
							end
						</cfquery>

						<!--- import users --->
						<cfquery datasource="#this.dsn#">
							if not exists (
								select 1
								from VineUsers
								where userId = <cfqueryparam value="#userId#" cfsqltype="cf_sql_varchar">
							)
							begin
								insert into VineUsers (
									userId,
									username,
									location,
									email,
									avatarUrl
								)
								values (
									<cfqueryparam value="#userId#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#user.username#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#user.location#" cfsqltype="cf_sql_varchar">,
									<cfif structKeyExists(user, "email")>
										<cfqueryparam value="#user.email#" cfsqltype="cf_sql_varchar">,
									<cfelse>
										null,
									</cfif>
									<cfqueryparam value="#user.avatarUrl#" cfsqltype="cf_sql_varchar">
								)
							end
						</cfquery>


						<cfcatch type="any">
							<cfdump var="#cfcatch#">
						</cfcatch>

					</cftry>

				</cfloop>

			</cfloop>

		</cfif>

	</cfloop>

</cfif>


<!--- convert the scientific notation number of the long user/post/whatever ids to the actual value --->
<cffunction name="convertNum" returntype="string">
	<cfargument name="num" required="yes">
	<cfset bigD = createObject('java', 'java.math.BigDecimal')>
	<cfreturn bigD.init(arguments.num)>
</cffunction>


<cffunction name="getVineUser" returntype="struct">
	<cfargument name="userId" required="yes"><!--- userId should first be passed to the convertNum function when calling this function --->
	<cfhttp method="get" url="https://api.vineapp.com/users/profiles/#arguments.userId#"></cfhttp>
	<cfreturn deserializeJson(cfhttp.fileContent).data>
</cffunction>