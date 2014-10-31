
<div style="padding:1em;">

	<h1>Check Params</h1>
	
	<p>Time: <cfoutput>#dateFormat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'hh:mm:ss')#</cfoutput></p>
	<p>Tick: <cfoutput>#getTickCount()#</cfoutput></p>
	<p>Browser: <strong><cfoutput>#browserShort#</cfoutput></strong></p>
	
	
	<h3 onclick="$('#appDump').toggle();">Application</h3>
	<div id="appDump" style="display:none;">
		<cfdump var="#application#" label="Application" format="text">
	</div>
	
	
	<h3 onclick="$('#thisDump').toggle();">This</h3>
	<div id="thisDump" style="display:none;">
		<cfdump var="#this#" label="This" format="text">
	</div>
	
	
	<h3 onclick="$('#requestDump').toggle();">Request</h3>
	<div id="requestDump" style="display:none;">
		<cfdump var="#request#" label="Request" format="text">
	</div>
	
	
	<h3 onclick="$('#cookieDump').toggle();">Cookie</h3>
	<div id="cookieDump" style="display:none;">
		<cfdump var="#cookie#" label="Cookie" format="text">
	</div>
	
	
	<h3 onclick="$('#sessionDump').toggle();">Session</h3>
	<div id="sessionDump" style="display:none;">
		<cfdump var="#session#" label="Session" format="text">
	</div>
	
	
	<h3 onclick="$('#cgiDump').toggle();">CGI</h3>
	<div id="cgiDump" style="display:none;">
		<cfdump var="#cgi#" label="CGI" format="text">
	</div>
	
	
	<h3 onclick="$('#serverDump').toggle();">Server</h3>
	<div id="serverDump" style="display:none;">
		<cfdump var="#server#" label="Server" format="text">
	</div>
	
	
	<h3 onclick="$('#urlDump').toggle();">URL</h3>
	<div id="urlDump" style="display:none;">
		<cfdump var="#url#" label="URL" format="text">
	</div>
	
	
	<h3 onclick="$('#formDump').toggle();">Form</h3>
	<div id="formDump" style="display:none;">
		<cfdump var="#form#" label="Form" format="text">
	</div>
	
	
	<h3 onclick="$('#variablesDump').toggle();">Variables</h3>
	<div id="variablesDump" style="display:none;">
		<cfdump var="#variables#" label="Variables" format="text">
	</div>

</div>

<script type="text/javascript">
	$(document).ready(function(){
		$('h3').css('cursor','pointer');
		$('h3').next('div').css('padding-left','1em');
	});
</script>

