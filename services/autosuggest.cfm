<!--- get autosuggest schedule names --->
<cfparam name="url.term" default="">
<cfparam name="url.service" default="">
<cfif len(url.term)>
<cfquery name="getSchedules" datasource="#this.dsn#">
select distinct s.name
from Schedules s
where isdate(s.deleteDate) = 0
and s.name like <cfqueryparam value="%#url.term#%" cfsqltype="cf_sql_varchar">
<cfif len(url.service)>
	and s.service = <cfqueryparam value="#url.service#" cfsqltype="cf_sql_varchar">
</cfif>
</cfquery>
<cfif getSchedules.recordCount>
[<cfoutput query="getSchedules">{"label":"#name#","value":"#name#"}<cfif currentRow neq getSchedules.recordCount>,</cfif></cfoutput>]
</cfif>
</cfif>