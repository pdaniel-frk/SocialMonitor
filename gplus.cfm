<cfparam name="form.searchTerm" default="">

<h1 class="page-header">
	Google+
	<span class="pull-right">
		<button class="btn btn-success btn-sm monitor-gplus-term-button" data-scheduleid="" data-searchterm="" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor new search term">
			<span class="glyphicon glyphicon-plus"></span>
		</button>
		<a href="schedules.cfm?service=GPlus"><button class="btn btn-sm btn-warning">Monitored</button></a>
	</span>
</h1>

<div class="panel panel-primary">

	<div class="panel-heading">
		<p class="panel-title"><strong>Search</strong></p>
	</div>

	<div class="panel-body">
		<form name="lookup-term" method="post">
			<div class="form-group">
				<label for="searchTerm">Search Term</label>
				<input type="text" class="form-control" id="searchTerm" name="searchTerm" placeholder="Google is pretty loose in their matching. 'notthesame' will match 'not the #same'" value="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>">
			</div>
			<button type="submit" class="btn btn-default">Submit</button>
			<cfif len(form.searchTerm)>
				<button class="btn btn-success btn-xs monitor-facebook-term-button" data-scheduleid="" data-searchterm="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor this term">
					<span class="glyphicon glyphicon-eye-open"></span>
				</button>
			</cfif>
		</form>
	</div>

</div>

<cfif len(form.searchTerm)>

	<cfset init("GPlus")>

	<cfset EOF = false>
	<cfset lc = 1>
	<cfset nextPageToken = "">
	<cfset minDate = "2014-10-15">
	<cfset sanityCheck = 50>

	<div class="table-responsive">

		<table class="table table-condensed table-bordered">

			<thead>

				<tr>

					<th>#</th>
					<th>id</th>
					<th>kind</th>
					<th>verb</th>
					<th>actor</th>
					<th>title</th>
					<th>content</th>
					<th>location</th>
					<th>published</th>

				</tr>

			</thead>

			<tbody>

				<cfloop condition="NOT EOF">

					<cfset activities = oGPlus.getActivities(
						searchTerm = form.searchTerm,
						api_key = credentials.gplus.api_key,
						nextPageToken = nextPageToken,
						save_results = true
					)>

					<cfif structKeyExists(activities, "items")>

						<cfif not arrayLen(activities.items)>
							<cfset EOF = true>
						<cfelse>

							<cfloop from="1" to="#arrayLen(activities.items)#" index="i">

								<cfset activity = structGet("activities.items[#i#]")>

								<cfif findNoCase(form.searchTerm, activity.object.content)>

									<cfset activity = oGPlus.parseActivityObject(activity)>
									<cfset user = oGPlus.getPeople(userId=activity.actor.id, api_key=credentials.gplus.api_key)>
									<cfset user = oGPlus.parseUserObject(user)>

									<cfset comments = oGPlus.getComments(activityId=activity.id, api_key=credentials.gplus.api_key)>
									<cfif structKeyExists(comments, "items") and arrayLen(comments.items)>
										<!--- <cfset comment = oGPlus.parseCommentObject(comments.items[1])>
										<cfdump var="#comment#">
										<cfabort> --->
										<!--- check for comments matcing search term --->
										<cfloop from="1" to="#arrayLen(comments.items)#" index="ci">
											<cfif structKeyExists(comments.items[ci], "object") and findNoCase(form.searchTerm, comments.items[ci].object.content)>
												<cfset comment = oGPlus.parseCommentObject(comments.items[ci])>
												<cfdump var="#comment#">
												<cfabort>
											</cfif>
										</cfloop>
									</cfif>

									<!--- same, just for one object (probably used internally) --->
									<!--- <cfset activity_details = oGPlus.getActivities (activityId = activity.id, api_key=credentials.gplus.api_key)>
									<cfdump var="#activity_details#"> --->

									<cfoutput>

										<tr>

											<td>#lc#[#i#]</td>
											<td>#activity.id#</td>
											<td>#activity.kind#</td>
											<td>#activity.verb#</td>
											<td><img src="#user.image.url#"></td>
											<td>#activity.title#</td>
											<td>#activity.object.content#</td>
											<td>#activity.placeName#</td>
											<td>#activity.published# (#dateCompare(activity.published, minDate)#)</td><!--- RFC3339 (eg 2014-10-29T10:25:31.279Z) --->
											<!--- <td>#created_date_time#</td> ---><!--- converted to local datetime --->

										</tr>

									</cfoutput>

									<cfif dateCompare(activity.published, minDate) lt 0>
										<p>results too stale</p>
										<cfset EOF = true>
									</cfif>

								</cfif>

							</cfloop>

						</cfif>

						<cfif not structKeyExists(activities, "nextPageToken")>
							<p>no next page token provided</p>
							<cfset EOF = true>
						<cfelse>
							<cfset nextPageToken = activities.nextPageToken>
						</cfif>

						<cfif lc gte sanityCheck>
							<p>exceeded sanitiy check for activities</p>
							<cfset EOF = true>
						</cfif>

						<cfset lc += 1>

					<cfelse>
						<p>not items in activities</p>
						<cfset EOF = true>
					</cfif>

				</cfloop>

			</tbody>

		</table>

	</div>

	<!--- search activities --->
	<!--- <cfset activities = oGPlus.getActivities(searchTerm=form.searchTerm, api_key=credentials.gplus.api_key)>
	<cfdump var="#activities#"> --->
		<!--- search an activity's comments --->

</cfif>