<cfparam name="url.scheduleId" default="">
<cfparam name="form.scheduleId" default="#url.scheduleId#">
<cfif not isDefined("schedule") or not schedule.recordCount>
	<cfset reRoute(destination="index.cfm", message="The schedule you requested was either not found, or you do not have the correct permissions.")>
</cfif>

<h1 class="page-header">
	Schedules &raquo; Cancel <small><cfoutput>#schedule.name#</cfoutput></small>
</h1>

<button class="btn btn-sm btn-danger delete-confirm">Yes, I want to cancel this schedule.</button>
<a href="index.cfm" class="btn btn-lg btn-info">No way! Get me out of here!</a>

<script>
	$(function(){
		$(document).on('click', '.delete-confirm', function(e){
			e.preventDefault();
			$.post('<cfoutput>#request.webRoot#</cfoutput>services/cancel-schedule.cfm', {
				scheduleid: '<cfoutput>#form.scheduleId#</cfoutput>',
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