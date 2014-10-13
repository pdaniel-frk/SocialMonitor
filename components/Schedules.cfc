<cfcomponent displayname="Scheduling Components"  output="no">

	<cffunction name="init" output="no">

		<!--- define arguments --->
		<cfargument name="dsn" required="true" type="string">

		<!--- set variables scope --->
		<cfset variables.dsn = arguments.dsn>

		<cfreturn this>

	</cffunction>


	<cffunction name="insertSchedule" output="no" returntype="numeric">

		<cfargument name="name" required="yes">
		<cfargument name="service" required="yes">
		<cfargument name="searchTerm" required="no" default="">
		<cfargument name="monitor_page_id" required="no" default="">
		<cfargument name="monitor_post_id" required="no" default="">
		<cfargument name="startDate" required="no" default="#dateFormat(now(), 'yyyy-mm-dd')# 00:00:00.000">
		<cfargument name="endDate" required="no" default="">

		<cfquery name="insertSchedule" datasource="#variables.dsn#">
			if not exists (
				select 1
				from Schedules
				where name = <cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar">
				and service = <cfqueryparam value="#arguments.service#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.searchTerm)>
					and searchTerm = <cfqueryparam value="#arguments.searchTerm#" cfsqltype="cf_sql_varchar">
				</cfif>
				<cfif len(arguments.monitor_page_id)>
					and monitor_page_id = <cfqueryparam value="#arguments.monitor_page_id#" cfsqltype="cf_sql_varchar">
				</cfif>
				<cfif len(arguments.monitor_post_id)>
					and monitor_post_id = <cfqueryparam value="#arguments.monitor_post_id#" cfsqltype="cf_sql_varchar">
				</cfif>
			)
			begin
				insert into Schedules (
					name,
					service,
					searchTerm,
					monitor_page_id,
					monitor_post_id,
					startDate,
					endDate
				)
				values (
					<cfqueryparam value="#arguments.name#" null="#not len(arguments.name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.service#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.searchTerm#" null="#not len(arguments.searchTerm)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.monitor_page_id#" null="#not len(arguments.monitor_page_id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.monitor_post_id#" null="#not len(arguments.monitor_post_id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.startDate#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="#arguments.endDate#" null="#not isdate(arguments.endDate)#" cfsqltype="cf_sql_timestamp">
				)
			end

			select scheduleId = scope_identity()
		</cfquery>

		<!--- catch in case scope_identity doesnt work --->
		<cftry>

			<cfreturn insertSchedule.scheduleId>

			<cfcatch type="any">

				<cfquery name="scheduleSelect" datasource="#variables.dsn#">
					select max(scheduleId) as scheduleId
					from Schedules
					where isdate(deleteDate) = 0
				</cfquery>

				<cfreturn scheduleSelect.scheduleId>

			</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="getSchedules" output="no" returntype="query">

		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="name" required="no" default="">
		<cfargument name="service" required="no" default="">
		<cfargument name="monitor_page_id" required="no" default="">
		<cfargument name="monitor_post_id" required="no" default="">
		<cfargument name="searchTerm" required="no" default="">
		<cfargument name="startDate" required="no" default="">
		<cfargument name="endDate" required="no" default="">
		<cfargument name="pageName" required="no" default="">
		<cfargument name="postMessage" required="no" default="">
		<cfargument name="currentlyRunning" required="no" default="false">

		<cfquery name="getSchedules" datasource="#variables.dsn#">
			select
				s.scheduleId,
				s.name,
				s.[service],
				s.monitor_page_id,
				s.monitor_post_id,
				s.searchTerm,
				s.startDate,
				s.endDate,
				page.name as pageName,
				post.[message] as postMessage
			from Schedules s
			left join FacebookPages page on s.scheduleId = page.scheduleId and s.monitor_page_id = page.page_id
			left join FacebookPagePosts post on s.scheduleId = post.scheduleId and s.monitor_post_id = post.post_id
			where isdate(s.deleteDate) = 0
			<cfif len(arguments.scheduleId)>
				and s.scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif len(arguments.name)>
				and s.name = <cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.service)>
				and s.[service] = <cfqueryparam value="#arguments.service#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.monitor_page_id)>
				and s.monitor_page_id = <cfqueryparam value="#arguments.monitor_page_id#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.monitor_post_id)>
				and s.monitor_post_id = <cfqueryparam value="#arguments.monitor_post_id#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.searchTerm)>
				and s.searchTerm = <cfqueryparam value="#arguments.searchTerm#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.startDate)>
				and s.startDate <= <cfqueryparam value="#arguments.startDate#" cfsqltype="cf_sql_timestamp">
			</cfif>
			<cfif len(arguments.endDate)>
				and s.endDate >= <cfqueryparam value="#arguments.endDate#" cfsqltype="cf_sql_timestamp">
			</cfif>
			<cfif len(arguments.pageName)>
				and page.name = <cfqueryparam value="#arguments.pageName#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.postMessage)>
				and post.[message] = <cfqueryparam value="#arguments.postMessage#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif arguments.currentlyRunning>
				and isnull(s.startdate, getdate()-1) <= getdate()
				and isnull(s.endDate, getdate()+1) >= getdate()
			</cfif>
			order by
				s.service,
				s.startDate,
				s.endDate
		</cfquery>

		<cfreturn getSchedules>

	</cffunction>


	<cffunction name="updateSchedule" output="no" returntype="void">

		<cfargument name="scheduleId" required="yes">
		<cfargument name="name" required="no" default="">
		<cfargument name="service" required="no" default="">
		<cfargument name="searchTerm" required="no" default="">
		<cfargument name="monitor_page_id" required="no" default="">
		<cfargument name="monitor_post_id" required="no" default="">
		<cfargument name="startDate" required="no" default="">
		<cfargument name="endDate" required="no" default="">

		<cfquery datasource="#variables.dsn#">
			update Schedules
			set modifyDate = getdate()
			<cfif len(arguments.name)>
				, name = <cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.service)>
				, service = <cfqueryparam value="#arguments.service#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.searchTerm)>
				, searchTerm = <cfqueryparam value="#arguments.searchTerm#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.monitor_page_id)>
				, monitor_page_id = <cfqueryparam value="#arguments.monitor_page_id#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.monitor_post_id)>
				, monitor_post_id = <cfqueryparam value="#arguments.monitor_post_id#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(arguments.startDate)>
				, startDate = <cfqueryparam value="#arguments.startDate#" cfsqltype="cf_sql_timestamp">
			</cfif>
			<cfif len(arguments.endDate)>
				, endDate = <cfqueryparam value="#arguments.endDate#" cfsqltype="cf_sql_timestamp">
			</cfif>
			where scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfreturn>

	</cffunction>

</cfcomponent>