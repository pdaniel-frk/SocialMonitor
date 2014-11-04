<!--- get autosuggest PROGRAM names --->
<cfparam name="url.term" default="">
<cfparam name="url.service" default="">
<cfif len(url.term)>
<cfquery name="getPrograms" datasource="#this.dsn#">
select distinct p.name
from Programs p
where isdate(p.deleteDate) = 0
and p.name like <cfqueryparam value="%#url.term#%" cfsqltype="cf_sql_varchar">
<cfif len(session.customerId)>
and p.customerId = <cfqueryparam value="#session.customerId#" cfsqltype="cf_sql_integer">
</cfif>
<cfif len(session.userId)>
and p.userId = <cfqueryparam value="#session.userId#" cfsqltype="cf_sql_integer">
</cfif>
</cfquery>
<cfif getPrograms.recordCount>
[<cfoutput query="getPrograms">{"label":"#name#","value":"#name#"}<cfif currentRow neq getPrograms.recordCount>,</cfif></cfoutput>]
</cfif>
</cfif>
<!--- get autosuggest schedule names --->
<!--- <cfparam name="url.term" default="">
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
</cfif> --->