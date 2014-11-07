<cfcomponent displayname="Programs Components"  output="no">

	<cffunction name="init" output="no">

		<!--- define arguments --->
		<cfargument name="dsn" required="true" type="string">

		<!--- set variables scope --->
		<cfset variables.dsn = arguments.dsn>

		<cfreturn this>

	</cffunction>


	<cffunction name="insertProgram" output="no" returntype="numeric">

		<cfargument name="customerId" required="no" default="">
		<cfargument name="userId" required="no" default="">
		<cfargument name="name" required="yes">
		<cfargument name="description" required="no" default="">
		<cfargument name="startDate" required="no" default="#dateFormat(now(), 'yyyy-mm-dd')# 00:00:00.000">
		<cfargument name="endDate" required="no" default="">
		<cfargument name="archiveDate" required="no" default="">
		<cfargument name="dateArchived" required="no" default="">


		<cfquery name="insertProgram" datasource="#variables.dsn#">
			if not exists (
				select 1
				from Programs
				where name = <cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.customerId)>
					and customerId = <cfqueryparam value="#arguments.customerId#" cfsqltype="cf_sql_integer">
				</cfif>
				<cfif len(arguments.userId)>
					and userId = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin
				insert into Programs (
					customerId,
					userId,
					name,
					description,
					startDate,
					endDate,
					archiveDate,
					dateArchived
				)
				values (
					<cfqueryparam value="#arguments.customerId#" null="#not len(arguments.customerId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.userId#" null="#not len(arguments.userId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.description#" null="#not len(arguments.description)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.startDate#" null="#not isDate(arguments.startDate)#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="#arguments.endDate#" null="#not isDate(arguments.endDate)#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="#arguments.archiveDate#" null="#not isDate(arguments.archiveDate)#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="#arguments.dateArchived#" null="#not isDate(arguments.dateArchived)#" cfsqltype="cf_sql_timestamp">
				)
			end

			select Id = scope_identity()
		</cfquery>

		<!--- catch in case scope_identity doesnt work --->
		<cftry>

			<cfreturn insertProgram.Id>

			<cfcatch type="any">

				<cfquery name="programSelect" datasource="#variables.dsn#">
					select max(Id) as Id
					from Programs
					where isdate(deleteDate) = 0
				</cfquery>

				<cfreturn programSelect.Id>

			</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="getPrograms" output="no">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="customerId" required="no" default="">
		<cfargument name="userId" required="no" default="">
		<cfargument name="name" required="no" default="">
		<cfargument name="description" required="no" default="">
		<cfargument name="startDate" required="no" default="">
		<cfargument name="endDate" required="no" default="">
		<cfargument name="archiveDate" required="no" default="">
		<cfargument name="dateArchived" required="no" default="">

		<cfquery name="programSelect" datasource="#variables.dsn#">
			select
				Id,
				customerId,
				userId,
				name,
				description,
				startDate,
				endDate,
				archiveDate,
				dateArchived
			from Programs
			where isdate(deleteDate) = 0
			<cfif len(arguments.scheduleId)>
				and exists (
					select 1
					from Schedules
					where scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
					and programId = Programs.Id
				)
			</cfif>
			<cfif len(arguments.programId)>
				and Id = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif len(arguments.customerId)>
				and customerId = <cfqueryparam value="#arguments.customerId#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif len(arguments.userId)>
				and userId = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif len(arguments.name)>
				and name = <cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.description)>
				and description = <cfqueryparam value="#arguments.description#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.startDate)>
				and startDate <= <cfqueryparam value="#arguments.startDate#" cfsqltype="cf_sql_timestamp">
			</cfif>
			<cfif len(arguments.endDate)>
				and endDate >= <cfqueryparam value="#arguments.endDate#" cfsqltype="cf_sql_timestamp">
			</cfif>
			<cfif len(arguments.archiveDate)>
				and archiveDate = <cfqueryparam value="#arguments.archiveDate#" cfsqltype="cf_sql_timestamp">
			</cfif>
			<cfif len(arguments.dateArchived)>
				and dateArchived = <cfqueryparam value="#arguments.dateArchived#" cfsqltype="cf_sql_timestamp">
			</cfif>
		</cfquery>

		<cfreturn programSelect>

	</cffunction>


	<cffunction name="updateProgram" output="no">

		<cfargument name="programId" required="yes">
		<cfargument name="customerId" required="no" default="">
		<cfargument name="userId" required="no" default="">
		<cfargument name="name" required="no" default="">
		<cfargument name="description" required="no" default="">
		<cfargument name="startDate" required="no" default="">
		<cfargument name="endDate" required="no" default="">
		<cfargument name="archiveDate" required="no" default="">
		<cfargument name="dateArchived" required="no" default="">

		<cfquery datasource="#variables.dsn#">
			update Programs
			set modifyDate = getdate()
			<cfif len(arguments.customerId)>
				, customerId = <cfqueryparam value="#arguments.customerId#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif len(arguments.userId)>
				, userId = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif len(arguments.name)>
				, name = <cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.description)>
				, description = <cfqueryparam value="#arguments.description#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.startDate)>
				, startDate = <cfqueryparam value="#arguments.startDate#" cfsqltype="cf_sql_timestamp">
			</cfif>
			<cfif len(arguments.endDate)>
				, endDate = <cfqueryparam value="#arguments.endDate#" cfsqltype="cf_sql_timestamp">
			</cfif>
			<cfif len(arguments.archiveDate)>
				, archiveDate = <cfqueryparam value="#arguments.archiveDate#" cfsqltype="cf_sql_timestamp">
			</cfif>
			<cfif len(arguments.dateArchived)>
				, dateArchived = <cfqueryparam value="#arguments.dateArchived#" cfsqltype="cf_sql_timestamp">
			</cfif>
			where Id = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
		</cfquery>

	</cffunction>


	<cffunction name="archiveProgram" output="no">

		<cfargument name="programId" required="no" default="">

		<cfset updateProgram(programId=arguments.programId, dateArchived=now())>

		<cfreturn>

	</cffunction>

</cfcomponent>