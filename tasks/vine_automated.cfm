<!--- this is currently failing on production (throwing 500 errors), so I'm halting it for now (EG 2014-10-24 11:00) --->

<!---

<cfsetting requesttimeout="999">

<cfparam name="url.programId" default="">
<cfparam name="url.scheduleId" default="">
<cfset init("Schedules")>
<cfset init("Vine")>
<cfset getSchedule = oSchedules.getSchedules (
	service = 'Vine',
	programId = url.programId,
	scheduleId = url.scheduleId,
	currentlyRunning = true
)>

<cfif getSchedule.recordCount>

	<cfloop query="getSchedule">

		<cfset searchResult = oVine.searchVine(searchTerm=getSchedule.searchTerm)>

		<cfset searchCount = 0>
		<cfset searchCount += searchResult.data.count>
		<cfset pages = ceiling(searchCount / 20)>

		<cfif searchCount gt 0>

			<cfloop from="1" to="#pages#" index="page">

				<cfset pageResult = oVine.searchVine(searchTerm=getSchedule.searchTerm, page=page)>
				<cfset pageCount = arrayLen(pageResult.data.records)>

				<cfloop from="1" to="#pageCount#" index="ndx">

					<cftry>

						<cfset record = structGet('pageResult.data.records[#ndx#]')>
						<cfset vine = oVine.parseVineObject(record)>

						<cfset oVine.insertVineEntry (
							programId = getSchedule.programId,
							scheduleId = getSchedule.scheduleId,
							vine = vine
						)>

						<cfset user = oVine.parseUserObject(oVine.getVineUser(userId=vine.userId))>

						<!--- import users --->
						<cfquery datasource="#this.dsn#">
							if not exists (
								select 1
								from VineUsers
								where userId = <cfqueryparam value="#user.userId#" cfsqltype="cf_sql_varchar">
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
									<cfqueryparam value="#user.userId#" null="#not len(user.userId)#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#user.username#" null="#not len(user.username)#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#user.location#" null="#not len(user.location)#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#user.email#" null="#not len(user.email)#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#user.avatarUrl#" null="#not len(user.avatarUrl)#" cfsqltype="cf_sql_varchar">
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

 --->