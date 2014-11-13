<cfcomponent displayname="Entries Components"  output="no">

	<cffunction name="init" output="no">

		<!--- define arguments --->
		<cfargument name="dsn" required="true" type="string">

		<!--- set variables scope --->
		<cfset variables.dsn = arguments.dsn>

		<cfreturn this>

	</cffunction>


	<cffunction name="getEntries" output="no" returntype="query">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="service" required="no" default="">
		<cfargument name="entryType" required="no" default="">
		<cfargument name="userId" required="no" default="">
		<cfargument name="entryDay" required="no" default="">

		<cfquery name="getEntries" datasource="#variables.dsn#">
			select
				programId,
				scheduleId,
				[service],
				entryType,
				entryId,
				userId,
				[text],
				link,
				emailAddress,
				firstName,
				lastName,
				name,
				userName,
				entryDate,
				entryDay,
				rowNumber,
				rowNumberDay
			from uvwSelectEntries
			where 1=1
			and rowNumber = 1
			<cfif len(arguments.programId)>
				and programId = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif len(arguments.scheduleId)>
				and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif len(arguments.service)>
				and [service] = <cfqueryparam value="#arguments.service#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.entryType)>
				and entryType = <cfqueryparam value="#arguments.entryType#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.userId)>
				and userId = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.entryDay)>
				and entryDay = <cfqueryparam value="#arguments.entryDay#" cfsqltype="cf_sql_timestamp">
			</cfif>
		</cfquery>

		<cfreturn getEntries>

	</cffunction>


	<cffunction name="getEntryCount" output="no" returntype="numeric">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="service" required="no" default="">
		<cfargument name="entryType" required="no" default="">
		<cfargument name="entryDay" required="no" default="">
		<cfargument name="allowDupes" required="no" default=false>

		<cfquery name="getEntryCount" datasource="#variables.dsn#">
			select count(1) as cnt
			from uvwSelectEntries
			where 1=1
			<cfif len(arguments.programId)>
				and programId = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif len(arguments.scheduleId)>
				and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif len(arguments.service)>
				and [service] = <cfqueryparam value="#arguments.service#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.entryType)>
				and entryType = <cfqueryparam value="#arguments.entryType#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.entryDay)>
				and entryDay = <cfqueryparam value="#arguments.entryDay#" cfsqltype="cf_sql_timestamp">
			</cfif>
			<cfif not arguments.allowDupes>
				and rowNumber = 1
			</cfif>
		</cfquery>

		<cfreturn getEntryCount.cnt>

	</cffunction>


	<cffunction name="getFacebookEntries" output="no" returntype="query">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="entryType" required="no" default="">
		<cfargument name="userId" required="no" default="">
		<cfargument name="entryDay" required="no" default="">

		<cfreturn getEntries (
			service = 'Facebook',
			argumentcollection = arguments
		)>
	</cffunction>


	<cffunction name="getTwitterEntries" output="no" returntype="query">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="entryType" required="no" default="">
		<cfargument name="userId" required="no" default="">
		<cfargument name="entryDay" required="no" default="">

		<cfreturn getEntries (
			service = 'Twitter',
			argumentcollection = arguments
		)>
	</cffunction>


	<cffunction name="getInstagramEntries" output="no" returntype="query">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="entryType" required="no" default="">
		<cfargument name="userId" required="no" default="">
		<cfargument name="entryDay" required="no" default="">

		<cfreturn getEntries (
			service = 'Instagram',
			argumentcollection = arguments
		)>
	</cffunction>


	<cffunction name="getVineEntries" output="no" returntype="query">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="entryType" required="no" default="">
		<cfargument name="userId" required="no" default="">
		<cfargument name="entryDay" required="no" default="">

		<cfreturn getEntries (
			service = 'Vine',
			argumentcollection = arguments
		)>
	</cffunction>


	<cffunction name="getGPlusEntries" output="no" returntype="query">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="entryType" required="no" default="">
		<cfargument name="userId" required="no" default="">
		<cfargument name="entryDay" required="no" default="">

		<cfreturn getEntries (
			service = 'GPlus',
			argumentcollection = arguments
		)>
	</cffunction>


</cfcomponent>