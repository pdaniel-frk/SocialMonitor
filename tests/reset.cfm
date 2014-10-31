<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Expires" CONTENT="-1">

<h1>Reset</h1>

<!--- <h2>Resetting Visit Count Cookie</h2>
<cfcookie name="siteVisitCount" value=0> --->

<h2>Clearing Session</h2>
<cfset structclear(session)>

<h2>Clearing Application</h2>
<cfset structclear(application)>

<h2>Restarting Application</h2>
<cfinvoke component="application" method="onApplicationStart">


<h2>Restarting Session</h2>
<cfinvoke component="application" method="onSessionStart">


<cfinclude template="check_params.cfm">
