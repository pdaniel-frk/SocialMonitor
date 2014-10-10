<div class="col-sm-3 col-md-2 sidebar">
	<cfif session.loggedIn>
		<!--- <ul class="nav nav-sidebar">
			<li class="active"><a href="#">Overview</a></li>
			<li><a href="#">Reports</a></li>
			<li><a href="#">Analytics</a></li>
			<li><a href="#">Export</a></li>
		</ul> --->
		<ul class="nav nav-sidebar">

			<li class="<cfif findNoCase('schedules', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#schedules.cfm</cfoutput>">Schedules</a></li>

			<li class="nav-divider"></li>

			<li class="<cfif findNoCase('show_entries', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#show_entries.cfm</cfoutput>">Entries</a></li>

			<li class="nav-divider"></li>

			<li class="<cfif findNoCase('facebook', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#facebook.cfm</cfoutput>">Facebook</a></li>
			<li class="<cfif findNoCase('instagram', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#instagram.cfm</cfoutput>">Instagram</a></li>
			<li class="<cfif findNoCase('twitter', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#twitter.cfm</cfoutput>">Twitter</a></li>
			<li class="<cfif findNoCase('vine', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#vine.cfm</cfoutput>">Vine</a></li>

			<li class="nav-divider"></li>

			<li class="disabled<cfif findNoCase('foursquare', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#foursquare.cfm</cfoutput>">Foursquare</a></li>
			<li class="disabled<cfif findNoCase('gplus', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#gplus.cfm</cfoutput>">Google+</a></li>
			<li class="disabled<cfif findNoCase('linkedin', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#linkedin.cfm</cfoutput>">LinkedIn</a></li>
			<li class="disabled<cfif findNoCase('pinterest', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#pinterest.cfm</cfoutput>">Pinterest</a></li>
			<li class="disabled<cfif findNoCase('tumblr', cgi.script_name)> active</cfif>"><a href="<cfoutput>#request.webRoot#tumblr.cfm</cfoutput>">Tumblr</a></li>

		</ul>
	</cfif>
</div>