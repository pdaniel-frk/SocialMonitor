<cfif not structKeyExists(form, "__token") or form.__token neq session.stamp>
	<!--- csrf attempt --->
	<cfset onRequestEnd(cgi.script_name)>
	<cfabort>
</cfif>

<cfparam name="form.scheduleId" default="">
<cfparam name="form.name" default="">
<cfparam name="form.postId" default="">
<cfparam name="form.searchTerm" default="">
<cfparam name="form.userId" default="">
<cfparam name="form.startDate" default="#now()#">
<cfparam name="form.endDate" default="">
<cfparam name="form.stopMonitor" default="false">
<cfif isdate(form.endDate)>
	<cfset form.endDate = "#dateFormat(form.endDate, 'yyyy-mm-dd')# 23:59:59">
</cfif>
<cfif form.stopMonitor eq 'true'>
	<cfset form.endDate = dateAdd("d", -1, now())>
</cfif>

<cfif not len(form.scheduleId) and len(form.postId)>

	<cfquery datasource="#this.dsn#">
		if not exists (
			select 1
			from Schedules
			where service = 'Facebook'
			and monitor_post_id = <cfqueryparam value="#form.postId#" cfsqltype="cf_sql_varchar">
			<cfif len(form.name)>
				and name = <cfqueryparam value="#form.name#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(form.searchTerm)>
				and searchTerm = <cfqueryparam value="#form.searchTerm#" cfsqltype="cf_sql_varchar">
			</cfif>
		)
		begin
			insert into Schedules (
				name,
				searchTerm,
				monitor_post_id,
				service,
				startDate,
				endDate
			)
			values (
				<cfqueryparam value="#form.name#" null="#not len(form.name)#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.searchTerm#" null="#not len(form.searchTerm)#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.postId#" cfsqltype="cf_sql_varchar">,
				'Facebook',
				<cfqueryparam value="#form.startDate#" null="#not isdate(form.startDate)#" cfsqltype="cf_sql_timestamp">,
				<cfqueryparam value="#form.endDate#" null="#not isdate(form.endDate)#" cfsqltype="cf_sql_timestamp">
			)
		end
	</cfquery>

	<!--- until the process runs and gets some results for this post, nothing will show up on the schedule --->

<cfelseif len(form.scheduleId)>

	<cfquery datasource="#this.dsn#">
		update Schedules
		set
			modifyDate = getdate()
			<cfif len(form.name)>
				, name = <cfqueryparam value="#form.name#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(form.searchTerm)>
				, searchTerm = <cfqueryparam value="#form.searchTerm#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(form.postId)>
				, monitor_post_id = <cfqueryparam value="#form.postId#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif len(form.startDate) and isDate(form.startDate)>
				, startDate = <cfqueryparam value="#form.startDate#" null="#not isdate(form.startDate)#" cfsqltype="cf_sql_timestamp">
			</cfif>
			<cfif len(form.endDate) and isDate(form.endDate)>
				, endDate = <cfqueryparam value="#form.endDate#" null="#not isdate(form.endDate)#" cfsqltype="cf_sql_timestamp">
			</cfif>
		where service = 'Facebook'
		and scheduleId = <cfqueryparam value="#form.scheduleId#" cfsqltype="cf_sql_integer">
	</cfquery>

</cfif>