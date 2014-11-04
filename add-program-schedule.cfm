<cfparam name="url.programId" default="">

<cfif len(url.programId)>

	<!--- check that customer is owner of program --->
	<cfset init("Programs")>
	<cfif oPrograms.getPrograms(programId=url.programId).customerId neq session.customerId>
		<cflocation url="programs.cfm" addtoken="no">
	<cfelse>

		Facebook
			Select Page
			Select Post
			Add Search Term

		Google+
			Add Search Term

		Instagram
			Add Search Term

		Twitter
			Add Search Term

		<button class="btn btn-success btn-sm monitor-twitter-term-button" data-programid="<cfoutput>#val(url.programId)#</cfoutput>" data-scheduleid="" data-searchterm="" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor new search term">
			<span class="glyphicon glyphicon-plus"></span>
		</button>

		Vine
			Add Search Term

	</cfif>

</cfif>

