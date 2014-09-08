<cfif not structKeyExists(form, "__token") or form.__token neq session.stamp>
	<!--- csrf attempt --->
	<cfset onRequestEnd(cgi.script_name)>
	<cfabort>
</cfif>

<cfparam name="form.scheduleId" default="">
<cfparam name="form.name" default="">
<cfparam name="form.searchTerm" default="">
<cfparam name="form.startDate" default="#now()#">
<cfparam name="form.endDate" default="">
<cfparam name="form.stopMonitor" default="false">
<cfif isdate(form.endDate)>
	<cfset form.endDate = "#dateFormat(form.endDate, 'yyyy-mm-dd')# 23:59:59">
</cfif>
<cfif form.stopMonitor eq 'true'>
	<cfset form.endDate = dateAdd("d", -1, now())>
</cfif>

<cfif not len(form.scheduleId) and len(form.searchTerm)>

	<cfquery datasource="#this.dsn#">
		if not exists (
			select 1
			from Schedules
			where searchTerm = <cfqueryparam value="#form.searchTerm#" cfsqltype="cf_sql_varchar">
			and service = 'Twitter'
			<cfif len(form.name)>
				and name = <cfqueryparam value="#form.name#" cfsqltype="cf_sql_varchar">
			</cfif>
		)
		begin
			insert into Schedules (
				name,
				searchTerm,
				service,
				startDate,
				endDate
			)
			values (
				<cfqueryparam value="#form.name#" null="#not len(form.name)#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.searchTerm#" cfsqltype="cf_sql_varchar">,
				'Twitter',
				<cfqueryparam value="#form.startDate#" null="#not isdate(form.startDate)#" cfsqltype="cf_sql_timestamp">,
				<cfqueryparam value="#form.endDate#" null="#not isdate(form.endDate)#" cfsqltype="cf_sql_timestamp">
			)
		end
	</cfquery>
	
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
			<cfif len(form.startDate) and isDate(form.startDate)>
				, startDate = <cfqueryparam value="#form.startDate#" null="#not isdate(form.startDate)#" cfsqltype="cf_sql_timestamp">
			</cfif>
			<cfif len(form.endDate) and isDate(form.endDate)>
				, endDate = <cfqueryparam value="#form.endDate#" null="#not isdate(form.endDate)#" cfsqltype="cf_sql_timestamp">
			</cfif>
		where service = 'Twitter'
		and scheduleId = <cfqueryparam value="#form.scheduleId#" cfsqltype="cf_sql_integer">
	</cfquery>
	
</cfif>