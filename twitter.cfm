<!--- <p>looking up friends</p>

<cfset userIds = "2852238350,329746445">

<p>get @office followers (most recent 5000)</p>

<!--- <cfdump var="#application.objMonkehTweet.getUserDetails(screen_name='office')#"> --->
<!--- 22209176 --->

<!--- <cfset followers = application.objMonkehTweet.getFollowersIDs(screen_name='office')> --->

<cfloop list="#userIds#" index="userId">

	<p>
	<cfoutput>#userId#</cfoutput>
	<cfset friends = application.objMonkehTweet.getFriendsIDs(user_id=userId)>
	<cfif structKeyExists(friends, 'ids')>
		<cfset friendIds = arrayToList(friends.ids)>
		<cfif listFindNoCase(friendIds, '22209176')>
			<strong>office found in this users friends (#userId#)</strong>
		</cfif>
	<cfelse>
		<cfdump var="#friends#">
	</cfif>
	</p>

	<!--- Your credentials do not allow access to this resource (can only get this information on behalf of authenticated users) --->
	<!--- <cfset result = application.objMonkehTweet.getFriendshipsLookup(user_id=userId)> --->

	<!--- <cfdump var="#result#">
	<cfabort> --->


</cfloop>


<cfabort> --->


<cfparam name="form.searchTerm" default="">

<h1 class="page-header">
	Twitter
	<span class="pull-right">
		<button class="btn btn-success btn-sm monitor-twitter-term-button" data-scheduleid="" data-searchterm="" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor new search term">
			<span class="glyphicon glyphicon-plus"></span>
		</button>
		<a href="schedules.cfm?service=Twitter"><button class="btn btn-sm btn-warning">Monitored</button></a>
	</span>
</h1>

<div class="panel panel-primary">

	<div class="panel-heading">
		<p class="panel-title"><strong>Search</strong></p>
	</div>

	<div class="panel-body">
		<form name="lookup-page" method="post">
			<div class="form-group">
				<label for="searchTerm">Search Term</label>
				<input type="text" class="form-control" id="searchTerm" name="searchTerm" placeholder="Multiple terms are supported, separated by spaces" value="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>">
			</div>
			<button type="submit" class="btn btn-default">Submit</button>
			<cfif len(form.searchTerm)>
				<button class="btn btn-success btn-xs monitor-twitter-term-button" data-scheduleid="" data-searchterm="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor this term">
					<span class="glyphicon glyphicon-eye-open"></span>
				</button>
			</cfif>
		</form>
	</div>

</div>

<cfif len(form.searchTerm)>

	<cfset form.searchTerm = replace(form.searchTerm, ' ', '+AND+', 'ALL')>

	<cfset q = URLEncodedFormat(form.searchTerm)>
	<cfset since_id = "">

	<cftry>

		<cfset searchResult = application.objMonkehTweet.search(q=q, since_id=since_id, count=100)>

		<cfset searchCount = 0>

		<cfset searchCount += arrayLen(searchResult.statuses)>

		<div class="table-responsive">
			<table class="table table-striped" id="lookup-results-table">
				<caption id="lookup-results-count"></caption>
				<thead>
					<tr>
						<th>#</th>
						<th>Created</th>
						<th>Handle</th>
						<th>Text</th>
						<th>Media</th>
						<!--- <th></th> --->
					</tr>
				</thead>
				<tbody>

					<cfloop from="1" to="#arrayLen(searchResult.statuses)#" index="ndx">

						<cfset thisResult = structGet("searchResult.statuses[#ndx#]")>

						<cfif isStruct(thisResult.place)>
							<cfdump var="#thisResult.place#">
						</cfif>

						<cfoutput>

							<tr>
								<td>#ndx#</td>
								<td>#thisResult.created_at#</td>
								<td>#thisResult.user.screen_name#</td>
								<td>#thisResult.text#</td>
								<td>
									<cfif structKeyExists(thisResult.entities, "media")>
										<a href="#thisResult.entities.media[1].media_url_https#" target="_blank"><!---
											 ---><img src="#thisResult.entities.media[1].media_url_https#" style="width:50px;height:50px;border-radius:25%;">
										</a>
									</cfif>
								</td>
								<!--- <td class="view-raw"><div style="display:none;"><cfdump var="#thisResult#"></div></td> --->
							</tr>

						</cfoutput>

						<cftry>

							<cfcatch type="any">
								<cfdump var="#cfcatch#">
								<cfdump var="#thisResult#">
								<cfabort>
							</cfcatch>

						</cftry>
					</cfloop>

				</tbody>

			</table>

		</div>

		<cfcatch type="any">
			<cfdump var="#cfcatch#">
		</cfcatch>

	</cftry>

</cfif>

<script>
	$(function(){
		$(document).on('click', '.view-raw', function(){
			$(this).find('div').show();
		});
	});
</script>