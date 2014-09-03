<cfif compareNoCase("cfschedule", cgi.http_user_agent) is not 0 and not session.loggedIn>
	
	<cfset onRequestEnd(cgi.script_name)>
	<cfabort>
	
</cfif>

<!--- get current schedule --->
<cfquery name="getCurrent" datasource="#this.dsn#">
	select distinct [service]
	from Schedules
	where isdate(deleteDate) = 0
	and isnull(startdate, getdate()-1) <= getdate()
	and isnull(endDate, getdate()+1) >= getdate()
</cfquery>

<cfif getCurrent.recordCount>
	
	<cfloop query="getCurrent">
		
		<cftry>
			
			<cfinclude template="#getCurrent.service#_automated.cfm">
			
			<cfcatch type="any">
				
				<cfmail from="egrimm@mardenkane.com" to="egrimm@mardenkane.com" subject="error processing #getCurrent.service#_automated" type="html">
					<p>#dateFormat(now(), 'yyyy-mm-dd')# #timeFormat(now(), 'HH:mm:ss')#</p>
					<cfdump var="#cfcatch#">
				</cfmail>
				
			</cfcatch>
			
		</cftry>
		
	</cfloop>
	
	
	<p>MK Social Monitor automated import(s) ran for <cfoutput>#valueList(getCurrent.service)#</cfoutput>: <cfoutput>#dateFormat(now(), 'yyyy-mm-dd')# #timeFormat(now(), 'HH:mm:ss')#</cfoutput></p>
	
	<cfif hour(now()) mod 8 eq 0>
		<!--- send a preiodic email --->
		<cfmail from="egrimm@mardenkane.com" to="egrimm@mardenkane.com" subject="MK Social Monitor automated import(s) ran" type="html">
			<p>MK Social Monitor automated imports ran for #valueList(getCurrent.service)#: #dateFormat(now(), 'yyyy-mm-dd')# #timeFormat(now(), 'HH:mm:ss')#</p>
		</cfmail>
		<p>periodic email notice sent</p>
	</cfif>
	
</cfif>