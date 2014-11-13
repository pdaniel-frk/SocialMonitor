<cfif not structKeyExists(form, "__token") or form.__token neq session.stamp>
	<!--- csrf attempt --->
	<cfset onRequestEnd(cgi.script_name)>
	<cfabort>
</cfif>
<cfparam name="form.programId" default="">
<cfset init("Programs")>
<cfset oPrograms.deleteProgram (
	programId = form.programId
)>