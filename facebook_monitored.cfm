<!--- get monitored pages --->
<cfquery name="getPages" datasource="#this.dsn#">
	select
		sched.scheduleId,
		sched.name,
		sched.monitor_page_id,
		sched.startDate,
		sched.endDate,
		page.[name] as pageName,
		(select count(1) from FacebookPostComments where page_id = page.page_id) as comment_count,
		(select count(1) from FacebookPostLikes where page_id = page.page_id) as like_count
	from Schedules sched
	inner join FacebookPages page on sched.monitor_page_id = page.page_id
	where isdate(sched.deleteDate) = 0
</cfquery>

<!--- get monitored posts --->
<cfquery name="getPosts" datasource="#this.dsn#">
	select
		sched.scheduleId,
		sched.name,
		sched.monitor_post_id,
		sched.startDate,
		sched.endDate,
		post.[message],
		page.[name] as pageName,
		(select count(1) from FacebookPostComments where post_id = post.post_id) as comment_count,
		(select count(1) from FacebookPostLikes where post_id = post.post_id) as like_count
	from Schedules sched
	inner join FacebookPagePosts post on sched.monitor_post_id = post.post_id
	left join FacebookPages page on post.page_id = page.page_id
	where isdate(sched.deleteDate) = 0
</cfquery>

<h1 class="page-header">
	Facebook &raquo; Monitored Pages and Posts
</h1>


<div class="panel panel-primary">

	<div class="panel-heading">
		<p class="panel-title">
			<cfoutput>
				<strong>
					Pages: #numberFormat(getPages.recordCount, ",")# |
					Posts: #numberFormat(getPosts.recordCount, ",")#
				</strong>
			</cfoutput>
		</p>
	</div>

	<div class="panel-body">
		<div class="panel-group" id="accordion">

			<cfif getPages.recordCount gt 0>
				<div class="panel panel-primary">
					<div class="panel-heading">
						<h4 class="panel-title">
						<a data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
						Monitored Pages
						</a>
						<span class="pull-right"><cfoutput>#numberFormat(getPages.recordCount, ",")#</cfoutput></span>
						</h4>
					</div>
					<div id="collapseOne" class="panel-collapse collapse in">
						<div class="panel-body">
							<div class="table-responsive">
								<table class="table table-striped">
									<thead>
										<tr>
											<th>#</th>
											<th>Page</th>
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
												<td>#numberFormat(comment_count, ",")#</td>
												<td>#numberFormat(like_count, ",")#</td>
												<td>#dateFormat(startDate, 'mm/dd/yyyy')# #timeFormat(startDate, 'h:mm TT')#</td>
												<td>#dateFormat(endDate, 'mm/dd/yyyy')# #timeFormat(endDate, 'h:mm TT')#</td>
												<td>
													<button class="btn btn-warning btn-small monitor-page-button" data-scheduleid="#scheduleId#" data-pageid="#monitor_page_id#" data-pagename="#pageName#" data-toggle="tooltip" data-placement="bottom" title="Edit Page Monitor">
														<span class="glyphicon glyphicon-wrench"></span>
													</button>
													<button class="btn btn-info btn-small run-schedule" data-scheduleid="#scheduleId#" data-service="facebook" data-toggle="tooltip" data-placement="bottom" title="Run this task">
														<span class="glyphicon glyphicon-refresh"></span>
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
						<a data-toggle="collapse" data-parent="#accordion" href="#collapseTwo">
						Monitored Posts
						</a>
						<span class="pull-right"><cfoutput>#numberFormat(getPosts.recordCount, ",")#</cfoutput></span>
						</h4>
					</div>
					<div id="collapseTwo" class="panel-collapse collapse">
						<div class="panel-body">
							<div class="table-responsive">
								<table class="table table-striped">
									<thead>
										<tr>
											<th>#</th>
											<th>Page</th>
											<th>Post</th>
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
												<td>#left(message, 50)#&hellip;</td>
												<td>#numberFormat(comment_count, ",")#</td>
												<td>#numberFormat(like_count, ",")#</td>
												<td>#dateFormat(startDate, 'mm/dd/yyyy')# #timeFormat(startDate, 'h:mm TT')#</td>
												<td>#dateFormat(endDate, 'mm/dd/yyyy')# #timeFormat(endDate, 'h:mm TT')#</td>
												<td>
													<button class="btn btn-warning btn-small monitor-post-button" data-scheduleid="#scheduleId#" data-postid="#monitor_post_id#" data-postmessage="#message#" data-toggle="tooltip" data-placement="bottom" title="Edit Post Monitor">
														<span class="glyphicon glyphicon-wrench"></span>
													</button>
													<button class="btn btn-info btn-small run-schedule" data-scheduleid="#scheduleId#" data-service="facebook" data-toggle="tooltip" data-placement="bottom" title="Run this task">
														<span class="glyphicon glyphicon-refresh"></span>
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

