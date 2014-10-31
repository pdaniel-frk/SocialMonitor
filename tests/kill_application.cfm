<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Expires" CONTENT="-1">

<h1>Kill Application</h1>

<!--- <h2>Resetting Visit Count Cookie</h2>
<cfcookie name="siteVisitCount" value=0> --->


<h2>Clearing Application</h2>
<cfset structclear(application)>


<cfinclude template="check_params.cfm">
