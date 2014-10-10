<cfset init("Schedules")>
<cfset getSchedules = oSchedules.getSchedules()>

<h1 class="page-header">
	Schedules
	<span class="pull-right">
		<div class="btn-group">
			<button class="btn btn-success btn-sm dropdown-toggle" data-toggle="dropdown" title="Schedule new monitor">
				<span class="glyphicon glyphicon-plus"></span> <span class="caret"></span>
			</button>
			<ul class="dropdown-menu dropdown-menu-right" role="menu">
				<li><a href="facebook.cfm">Facebook</a></li>
				<li><a href="instagram.cfm">Instagram</a></li>
				<li><a href="twitter.cfm">Twitter</a></li>
				<li><a href="vine.cfm">Vine</a></li>
				<li class="divider"></li>
				<li class="disabled"><a href="foursquare.cfm">Foursquare</a></li>
				<li class="disabled"><a href="gplus.cfm">Google+</a></li>
				<li class="disabled"><a href="linkedin.cfm">LinkedIn</a></li>
				<li class="disabled"><a href="pinterest.cfm">Pinterest</a></li>
				<li class="disabled"><a href="tumblr.cfm">Tumblr</a></li>
			</ul>
		</div>
	</span>
</h1>

<div class="panel panel-primary">

	<div class="panel-heading">
		<p class="panel-title">
			<cfoutput>
				<strong>
					Scheduled Monitors: #numberFormat(getSchedules.recordCount)#
				</strong>
			</cfoutput>
		</p>
	</div>

	<div class="panel-body">
		<div class="panel-group" id="accordion">

			<cfoutput query="getSchedules" group="service">

				<cfquery name="getCount" datasource="#this.dsn#">
					select count(1) as cnt
					from Schedules
					where isdate(deleteDate) = 0
					and service = <cfqueryparam value="#service#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<div class="panel panel-primary">
					<div class="panel-heading">
						<h4 class="panel-title">
						<a data-toggle="collapse" data-parent="##accordion" href="##collapse#service#">
						#service#
						</a>
						<span class="pull-right">#numberFormat(getCount.cnt, ",")#</span>
						</h4>
					</div>
					<div id="collapse#service#" class="panel-collapse collapse <cfif currentRow eq 1>in</cfif>">
						<div class="panel-body">
							<div class="table-responsive">
								<table class="table table-striped" style="font-family:sans-serif;font-size:12px;">
									<thead>
										<tr>
											<th>##</th>
											<th nowrap>Name of Program, Schedule, etc.</th>
											<cfif service eq "Facebook">
												<th>Page</th>
												<th>Post</th>
											</cfif>
											<th>Term</th>
											<th>Start</th>
											<th>End</th>
											<th>Entries</th>
											<cfif service eq "Facebook">
												<th>Comments</th>
												<th>Likes</th>
											</cfif>
											<th>Actions</th>
										</tr>
									</thead>
									<tbody>
										<cfoutput>

											<cfquery name="getEntryCount" datasource="#this.dsn#">
												<cfif service eq "Facebook">
													<cfif len(searchTerm) and not len(monitor_page_id) and not len(monitor_post_id)>
														select
															count(1) as cnt,
															null as comment_count,
															null as like_count
														from FacebookSearches
														where scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer">
													<cfelseif len(monitor_page_id)>
														select
															null as cnt,
															count(1) as comment_count,
															(
																select count(1)
																from FacebookPostLikes
																where page_id = <cfqueryparam value="#monitor_page_id#" cfsqltype="cf_sql_varchar">
																and scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer">
															) as like_count
														from FacebookPostComments
														where page_id = <cfqueryparam value="#monitor_page_id#" cfsqltype="cf_sql_varchar">
														and scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer">
													<cfelseif len(monitor_post_id)>
														select
															null as cnt,
															count(1) as comment_count,
															(
																select count(1)
																from FacebookPostLikes
																where post_id = <cfqueryparam value="#monitor_post_id#" cfsqltype="cf_sql_varchar">
																and scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer">
															) as like_count
														from FacebookPostComments
														where post_id = <cfqueryparam value="#monitor_post_id#" cfsqltype="cf_sql_varchar">
														and scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer">
													</cfif>
												</cfif>

												<cfif service eq "Instagram">
													select count(1) as cnt
													from InstagramEntries
													where scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer">
													and searchTerm = <cfqueryparam value="#searchTerm#" cfsqltype="cf_sql_varchar">
												</cfif>

												<cfif service eq "Twitter">
													select count(1) as cnt
													from TwitterEntries
													where scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer">
													and searchTerm = <cfqueryparam value="#searchTerm#" cfsqltype="cf_sql_varchar">
												</cfif>

												<cfif service eq "Vine">
													select count(1) as cnt
													from VineEntries
													where scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer">
													and searchTerm = <cfqueryparam value="#searchTerm#" cfsqltype="cf_sql_varchar">
												</cfif>
											</cfquery>

											<tr>
												<td>#currentRow#</td>
												<td>#name#</td>

												<cfif service eq "Facebook">
													<td>
														<cfif len(monitor_page_id)>
															<cfquery name="getPage" datasource="#this.dsn#">
																select *
																from FacebookPages
																where page_id = <cfqueryparam value="#monitor_page_id#" cfsqltype="cf_sql_varchar">
																and scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer">
															</cfquery>
															#getPage.name#
														</cfif>
													</td>
													<td>
														<cfif len(monitor_post_id)>
															<cfquery name="getPost" datasource="#this.dsn#">
																select *
																from FacebookPagePosts
																where post_id = <cfqueryparam value="#monitor_post_id#" cfsqltype="cf_sql_varchar">
																and scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer">
															</cfquery>
															#left(getPost.message, 50)#&hellip;
														</cfif>
													</td>
												</cfif>

												<td>#searchTerm#</td>
												<td>#dateFormat(startDate, 'mm/dd/yyyy')# #timeFormat(startDate, 'h:mm TT')#</td>
												<td>#dateFormat(endDate, 'mm/dd/yyyy')# #timeFormat(endDate, 'h:mm TT')#</td>
												<td>#numberFormat(getEntryCount.cnt, ",")#</td>
												<cfif service eq "Facebook">
													<td>#numberFormat(getEntryCount.comment_count, ",")#</td>
													<td>#numberFormat(getEntryCount.like_count, ",")#</td>
												</cfif>
												<td nowrap>
													<cfif service eq "Facebook">
														<cfif len(monitor_page_id)>
															<button class="btn btn-warning btn-xs monitor-page-button" data-scheduleid="#scheduleId#" data-pageid="#monitor_page_id#" data-pagename="#getPage.name#" data-toggle="tooltip" data-placement="bottom" title="Edit Page Monitor">
																<span class="glyphicon glyphicon-edit"></span>
															</button>
														<cfelseif len(monitor_post_id)>
															<button class="btn btn-warning btn-xs monitor-post-button" data-scheduleid="#scheduleId#" data-postid="#monitor_post_id#" data-postmessage="#getPost.message#" data-toggle="tooltip" data-placement="bottom" title="Edit Page Monitor">
																<span class="glyphicon glyphicon-edit"></span>
															</button>
														</cfif>
													</cfif>
													<cfif service eq "Instagram">
														<button class="btn btn-warning btn-xs monitor-instagram-term-button" data-scheduleid="#scheduleId#" data-searchterm="#searchTerm#" data-toggle="tooltip" data-placement="bottom" title="Edit Term Monitor">
															<span class="glyphicon glyphicon-edit"></span>
														</button>
													</cfif>
													<cfif service eq "Twitter">
														<button class="btn btn-warning btn-xs monitor-twitter-term-button" data-scheduleid="#scheduleId#" data-searchterm="#searchTerm#" data-toggle="tooltip" data-placement="bottom" title="Edit Term Monitor">
															<span class="glyphicon glyphicon-edit"></span>
														</button>
													</cfif>
													<cfif service eq "Vine">
														<button class="btn btn-warning btn-xs monitor-vine-term-button" data-scheduleid="#scheduleId#" data-searchterm="#searchTerm#" data-toggle="tooltip" data-placement="bottom" title="Edit Term Monitor">
															<span class="glyphicon glyphicon-edit"></span>
														</button>
													</cfif>
													<button class="btn btn-info btn-xs run-schedule" data-scheduleid="#scheduleId#" data-service="#lcase(service)#" data-toggle="tooltip" data-placement="bottom" title="Run this task">
														<span class="glyphicon glyphicon-play-circle"></span>
													</button>
													<a href="#request.webRoot#show_entries.cfm?scheduleId=#scheduleId#">
														<button class="btn btn-primary btn-xs view-entries" data-scheduleid="#scheduleId#" data-service="#lcase(service)#" data-toggle="tooltip" data-placement="bottom" title="View collected entries">
															<span class="glyphicon glyphicon-eye-open"></span>
														</button>
													</a>
													<button class="btn btn-default btn-xs download-entries" data-scheduleid="#scheduleId#" data-service="#lcase(service)#" data-toggle="tooltip" data-placement="bottom" title="Download collected entries">
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

			</cfoutput>

		</div>

		<div class="progress progress-striped progress-info active" style="display:none;">
			<div class="progress-bar" style="width: 100%;"></div>
		</div>

	</div>

</div>
