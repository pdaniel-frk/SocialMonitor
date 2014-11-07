<div class="col-sm-3 col-md-2 sidebar">
	<cfif session.loggedIn>
		<!--- <ul class="nav nav-sidebar">
			<li class="active"><a href="#">Overview</a></li>
			<li><a href="#">Reports</a></li>
			<li><a href="#">Analytics</a></li>
			<li><a href="#">Export</a></li>
		</ul> --->
		<ul class="nav nav-sidebar">

			<li class="<cfif findNoCase('programs/', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#programs/</cfoutput>">Programs</a></li>

			<li class="nav-divider"></li>

			<li class="<cfif findNoCase('schedules/', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#schedules/</cfoutput>">Schedules</a></li>

			<li class="nav-divider"></li>

			<li class="<cfif findNoCase('entries/view', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#entries/view.cfm</cfoutput>">Entries</a></li>

			<cfif session.uName eq "egrimm">

				<li class="nav-divider"></li>

				<li class="<cfif findNoCase('tests/facebook', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#tests/facebook.cfm</cfoutput>">Facebook</a></li>
				<li class="<cfif findNoCase('tests/gplus', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#tests/gplus.cfm</cfoutput>">Google+</a></li>
				<li class="<cfif findNoCase('tests/instagram', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#tests/instagram.cfm</cfoutput>">Instagram</a></li>
				<li class="<cfif findNoCase('tests/twitter', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#tests/twitter.cfm</cfoutput>">Twitter</a></li>
				<li class="<cfif findNoCase('tests/vine', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#tests/vine.cfm</cfoutput>">Vine</a></li>

				<li class="nav-divider"></li>

				<li class="disabled<cfif findNoCase('tests/foursquare', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#tests/foursquare.cfm</cfoutput>">Foursquare</a></li>
				<li class="disabled<cfif findNoCase('tests/linkedin', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#tests/linkedin.cfm</cfoutput>">LinkedIn</a></li>
				<li class="disabled<cfif findNoCase('tests/pinterest', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#tests/pinterest.cfm</cfoutput>">Pinterest</a></li>
				<li class="disabled<cfif findNoCase('tests/tumblr', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#tests/tumblr.cfm</cfoutput>">Tumblr</a></li>

			</cfif>

		</ul>
	</cfif>
</div>