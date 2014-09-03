<div class="alert alert-info">
	<button type="button" class="close" data-dismiss="alert">&times;</button>
	You have been signed out.
</div>

<!--- show progress bar --->
<div class="progress progress-striped progress-success active">
	<div class="progress-bar" style="width: 100%;"></div>
</div>

<cfset init("Tracking","oTracking","BaseComponents")>
<cfset oTracking.trackLogout(loginTrackingID=session.loginTrackingID)>

<!--- redirect to index (TODO: make landing page user-configurable) --->
<script type="text/javascript">
	window.setTimeout( function() {  location='login.cfm' }, 3000 );
</script>

<cfinvoke component="application" method="onsessionend">
<cfinvoke component="application" method="onsessionstart">
<cfset onRequestEnd(cgi.script_name)>
<cfabort>