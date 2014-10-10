<!--- get monitored search terms --->
<!--- this doesn't really yield any useful results, though. --->
<cfquery name="getTerms" datasource="#this.dsn#">
	select
		sched.scheduleId,
		sched.name,
		sched.searchTerm,
		sched.startDate,
		sched.endDate,
		(select count(1) from FacebookSearches where scheduleId = sched.scheduleId) as entry_count
	from Schedules sched
	where isdate(sched.deleteDate) = 0
	and sched.service = 'Facebook'
	and sched.searchTerm is not null
	and sched.monitor_page_id is null
	and sched.monitor_post_id is null
</cfquery>

<!--- get monitored pages --->
<cfquery name="getPages" datasource="#this.dsn#">
	select
		sched.scheduleId,
		sched.name,
		sched.searchTerm,
		sched.monitor_page_id,
		sched.startDate,
		sched.endDate,
		page.[name] as pageName,
		(select count(1) from FacebookPostComments where page_id = page.page_id) as comment_count,
		(select count(1) from FacebookPostLikes where page_id = page.page_id) as like_count
	from Schedules sched
	left join FacebookPages page on sched.monitor_page_id = page.page_id and sched.scheduleId = page.scheduleId
	where isdate(sched.deleteDate) = 0
	and sched.service = 'Facebook'
	and sched.monitor_page_id is not null
</cfquery>

<!--- get monitored posts --->
<cfquery name="getPosts" datasource="#this.dsn#">
	select
		sched.scheduleId,
		sched.name,
		sched.searchTerm,
		sched.monitor_post_id,
		sched.startDate,
		sched.endDate,
		post.[message],
		page.[name] as pageName,
		(select count(1) from FacebookPostComments where post_id = post.post_id) as comment_count,
		(select count(1) from FacebookPostLikes where post_id = post.post_id) as like_count
	from Schedules sched
	left join FacebookPagePosts post on sched.monitor_post_id = post.post_id and sched.scheduleId = post.scheduleId
	left join FacebookPages page on post.page_id = page.page_id and page.scheduleId = post.scheduleId
	where isdate(sched.deleteDate) = 0
	and sched.service = 'Facebook'
	and sched.monitor_post_id is not null
</cfquery>

<h1 class="page-header">
	Facebook &raquo; Monitored Pages and Posts
</h1>


<div class="panel panel-primary">

	<div class="panel-heading">
		<p class="panel-title">
			<cfoutput>
				<strong>
					Terms: #numberFormat(getTerms.recordCount, ",")# |
					Pages: #numberFormat(getPages.recordCount, ",")# |
					Posts: #numberFormat(getPosts.recordCount, ",")#
				</strong>
			</cfoutput>
		</p>
	</div>

	<div class="panel-body">
		<div class="panel-group" id="accordion">

			<cfif getTerms.recordCount gt 0>
				<div class="panel panel-primary">
					<div class="panel-heading">
						<h4 class="panel-title">
						<a data-toggle="collapse" data-parent="#accordion" href="#collapseTerms">
						Monitored Terms
						</a>
						<span class="pull-right"><cfoutput>#numberFormat(getTerms.recordCount, ",")#</cfoutput></span>
						</h4>
					</div>
					<div id="collapseTerms" class="panel-collapse collapse in">
						<div class="panel-body">
							<div class="table-responsive">
								<table class="table table-striped" style="font-family:sans-serif;font-size:12px;">
									<thead>
										<tr>
											<th>#</th>
											<th>Name of Program, Schedule, etc.</th>
											<th>Term</th>
											<th>Entries</th>
											<th>Start</th>
											<th>End</th>
											<th>Actions</th>
										</tr>
									</thead>
									<tbody>
										<cfoutput query="getTerms">
											<tr>
												<td>#currentRow#</td>
												<td>#name#</td>
												<td>#searchTerm#</td>
												<td>#numberFormat(entry_count, ",")#</td>
												<td>#dateFormat(startDate, 'mm/dd/yyyy')# #timeFormat(startDate, 'h:mm TT')#</td>
												<td>#dateFormat(endDate, 'mm/dd/yyyy')# #timeFormat(endDate, 'h:mm TT')#</td>
												<td nowrap>
													<button class="btn btn-warning btn-xs monitor-facebook-term-button" data-scheduleid="#scheduleId#" data-searchterm="#searchTerm#" data-toggle="tooltip" data-placement="bottom" title="Edit Term Monitor">
														<span class="glyphicon glyphicon-edit"></span>
													</button>
													<button class="btn btn-info btn-xs run-schedule" data-scheduleid="#scheduleId#" data-service="facebook" data-toggle="tooltip" data-placement="bottom" title="Run this task">
														<span class="glyphicon glyphicon-play-circle"></span>
													</button>
													<a href="#request.webRoot#show_entries.cfm?scheduleId=#scheduleId#">
														<button class="btn btn-primary btn-xs view-entries" data-scheduleid="#scheduleId#" data-service="facebook" data-toggle="tooltip" data-placement="bottom" title="View collected entries">
															<span class="glyphicon glyphicon-eye-open"></span>
														</button>
													</a>
													<button class="btn btn-default btn-xs download-entries" data-scheduleid="#scheduleId#" data-service="facebook" data-toggle="tooltip" data-placement="bottom" title="Download collected entries">
														<span class="glyphicon glyphicon-download-alt"></span>
													</button>
												</td>
											</tr>
										</cfoutput>
									</tbody>
								</table>
							</div>
						</div>
					</div>
				</div>
			</cfif>

			<cfif getPages.recordCount gt 0>
				<div class="panel panel-primary">
					<div class="panel-heading">
						<h4 class="panel-title">
						<a data-toggle="collapse" data-parent="#accordion" href="#collapsePages">
						Monitored Pages
						</a>
						<span class="pull-right"><cfoutput>#numberFormat(getPages.recordCount, ",")#</cfoutput></span>
						</h4>
					</div>
					<div id="collapsePages" class="panel-collapse collapse">
						<div class="panel-body">
							<div class="table-responsive">
								<table class="table table-striped">
									<thead>
										<tr>
											<th>#</th>
											<th>Name of Program, Schedule, etc.</th>
											<th>Page</th>
											<th>Term</th>
											<th>Comments</th>
											<th>Likes</th>
											<th>Start</th>
											<th>End</th>
											<th>Actions</th>
										</tr>
									</thead>
									<tbody>
										<cfoutput query="getPages">
											<tr>
												<td>#currentRow#</td>
												<td>#name#</td>
												<td>#pageName#</td>
												<td>#searchTerm#</td>
												<td>#numberFormat(comment_count, ",")#</td>
												<td>#numberFormat(like_count, ",")#</td>
												<td>#dateFormat(startDate, 'mm/dd/yyyy')# #timeFormat(startDate, 'h:mm TT')#</td>
												<td>#dateFormat(endDate, 'mm/dd/yyyy')# #timeFormat(endDate, 'h:mm TT')#</td>
												<td nowrap>
													<button class="btn btn-warning btn-xs monitor-page-button" data-scheduleid="#scheduleId#" data-pageid="#monitor_page_id#" data-pagename="#pageName#" data-toggle="tooltip" data-placement="bottom" title="Edit Page Monitor">
														<span class="glyphicon glyphicon-wrench"></span>
													</button>
													<button class="btn btn-info btn-xs run-schedule" data-scheduleid="#scheduleId#" data-service="facebook" data-toggle="tooltip" data-placement="bottom" title="Run this task">
														<span class="glyphicon glyphicon-play-circle"></span>
													</button>
													<a href="#request.webRoot#show_entries.cfm?scheduleId=#scheduleId#">
														<button class="btn btn-primary btn-xs view-entries" data-scheduleid="#scheduleId#" data-service="facebook" data-toggle="tooltip" data-placement="bottom" title="View collected entries">
															<span class="glyphicon glyphicon-eye-open"></span>
														</button>
													</a>
													<button class="btn btn-default btn-xs download-entries" data-scheduleid="#scheduleId#" data-service="facebook" data-toggle="tooltip" data-placement="bottom" title="Download collected entries">
														<span class="glyphicon glyphicon-download-alt"></span>
													</button>
												</td>
											</tr>
										</cfoutput>
									</tbody>
								</table>
							</div>
						</div>
					</div>
				</div>
			</cfif>

			<cfif getPosts.recordCount gt 0>
				<div class="panel panel-primary">
					<div class="panel-heading">
						<h4 class="panel-title">
						<a data-toggle="collapse" data-parent="#accordion" href="#collapsePosts">
						Monitored Posts
						</a>
						<span class="pull-right"><cfoutput>#numberFormat(getPosts.recordCount, ",")#</cfoutput></span>
						</h4>
					</div>
					<div id="collapsePosts" class="panel-collapse collapse">
						<div class="panel-body">
							<div class="table-responsive">
								<table class="table table-striped">
									<thead>
										<tr>
											<th>#</th>
											<th>Name of Program, Schedule, etc.</th>
											<th>Page</th>
											<th>Post</th>
											<th>Term</th>
											<th>Comments</th>
											<th>Likes</th>
											<th>Start</th>
											<th>End</th>
											<th>Actions</th>
										</tr>
									</thead>
									<tbody>
										<cfoutput query="getPosts">
											<tr>
												<td>#currentRow#</td>
												<td>#name#</td>
												<td>#pageName#</td>
												<td>#left(message, 50)#&hellip;</td>
												<td>#searchTerm#</td>
												<td>#numberFormat(comment_count, ",")#</td>
												<td>#numberFormat(like_count, ",")#</td>
												<td>#dateFormat(startDate, 'mm/dd/yyyy')# #timeFormat(startDate, 'h:mm TT')#</td>
												<td>#dateFormat(endDate, 'mm/dd/yyyy')# #timeFormat(endDate, 'h:mm TT')#</td>
												<td nowrap>
													<button class="btn btn-warning btn-xs monitor-post-button" data-scheduleid="#scheduleId#" data-postid="#monitor_post_id#" data-postmessage="#message#" data-toggle="tooltip" data-placement="bottom" title="Edit Post Monitor">
														<span class="glyphicon glyphicon-wrench"></span>
													</button>
													<button class="btn btn-info btn-xs run-schedule" data-scheduleid="#scheduleId#" data-service="facebook" data-toggle="tooltip" data-placement="bottom" title="Run this task">
														<span class="glyphicon glyphicon-play-circle"></span>
													</button>
													<a href="#request.webRoot#show_entries.cfm?scheduleId=#scheduleId#">
														<button class="btn btn-primary btn-xs view-entries" data-scheduleid="#scheduleId#" data-service="facebook" data-toggle="tooltip" data-placement="bottom" title="View collected entries">
															<span class="glyphicon glyphicon-eye-open"></span>
														</button>
													</a>
													<button class="btn btn-default btn-xs download-entries" data-scheduleid="#scheduleId#" data-service="facebook" data-toggle="tooltip" data-placement="bottom" title="Download collected entries">
														<span class="glyphicon glyphicon-download-alt"></span>
													</button>
												</td>
											</tr>
										</cfoutput>
									</tbody>
								</table>
							</div>
						</div>
					</div>
				</div>
			</cfif>

			<div class="progress progress-striped progress-info active" style="display:none;">
				<div class="progress-bar" style="width: 100%;"></div>
			</div>

		</div>
	</div>
</div>

