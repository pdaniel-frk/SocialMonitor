<cfparam name="url.programId" default="">
<cfparam name="form.programId" default="#url.programId#">
<cfif not isDefined("program") or not program.recordCount>
	<cfset reRoute(destination="index.cfm", message="The program you requested was either not found, or you do not have the correct permissions.")>
</cfif>

<h1 class="page-header">
	Programs &raquo; Cancel <small><cfoutput>#program.name#</cfoutput></small>
</h1>

<button class="btn btn-sm btn-danger delete-confirm">Yes, I want to cancel this program.</button>
<a href="index.cfm" class="btn btn-lg btn-info">No way! Get me out of here!</a>

<script>
	$(function(){
		$(document).on('click', '.delete-confirm', function(e){
			e.preventDefault();
			$.post('<cfoutput>#request.webRoot#</cfoutput>services/cancel-program.cfm', {
				programid: '<cfoutput>#form.programId#</cfoutput>',
				__token: '<cfoutput>#session.stamp#</cfoutput>'
			}, function(response){
			})
			.done(function(){
				window.location = 'index.cfm';
			})
			.fail(function(){})
			.always(function(){});
		});
	});
</script>