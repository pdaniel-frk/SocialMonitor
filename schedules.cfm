<h1 class="page-header">
	Schedules
	<span class="pull-right">
		<div class="btn-group">
			<button class="btn btn-success btn-small dropdown-toggle" data-toggle="dropdown" title="Schedule new monitor">
				<span class="glyphicon glyphicon-eye-open"></span> <span class="caret"></span>
			</button>
			<ul class="dropdown-menu dropdown-menu-right" role="menu">
				<li><a href="facebook.cfm">Facebook</a></li>
				<li><a href="instagram.cfm">Instagram</a></li>
				<li><a href="twitter.cfm">Twitter</a></li>
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

<cfquery name="getSchedules" datasource="#this.dsn#">
	select 
		s.scheduleId,
		s.name,
		s.[service],
		s.monitor_page_id,
		s.monitor_post_id,
		s.searchTerm,
		s.startDate,
		s.endDate,
		page.name as pageName,
		post.[message] as postMessage
	from Schedules s
	left join FacebookPages page on s.scheduleId = page.scheduleId and s.monitor_page_id = page.page_id
	left join FacebookPagePosts post on s.scheduleId = post.scheduleId and s.monitor_post_id = post.post_id
	where isdate(s.deleteDate) = 0
	order by s.service,
		s.startDate,
		s.endDate
</cfquery>

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
								<table class="table table-striped">
									<thead>
										<tr>
											<th>##</th>
											<th>Name</th>
											<th>Monitoring</th>
											<th>Start</th>
											<th>End</th>
											<cfif service eq "Facebook">
												<th>Comments</th>
												<th>Likes</th>
											<cfelse>
												<th>Entries</th>
											</cfif>
											<th>Actions</th>
										</tr>
									</thead>
									<tbody>
										<cfoutput>
											
											<cfquery name="getEntryCount" datasource="#this.dsn#">
												<cfif service eq "Facebook">
													<cfif len(monitor_page_id)>
														select count(1) as comment_count,
														(
															select count(1)
															from FacebookPostLikes
															where page_id = <cfqueryparam value="#monitor_page_id#" cfsqltype="cf_sql_varchar">
															<!--- and scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer"> --->
														) as like_count
														from FacebookPostComments
														where page_id = <cfqueryparam value="#monitor_page_id#" cfsqltype="cf_sql_varchar">
														<!--- and scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer"> --->
													<cfelseif len(monitor_post_id)>
														select count(1) as comment_count,
														(
															select count(1)
															from FacebookPostLikes
															where post_id = <cfqueryparam value="#monitor_post_id#" cfsqltype="cf_sql_varchar">
															<!--- and scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer"> --->
														) as like_count
														from FacebookPostComments
														where post_id = <cfqueryparam value="#monitor_post_id#" cfsqltype="cf_sql_varchar">
														<!--- and scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer"> --->
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
											</cfquery>
											
											<tr>
												<td>#currentRow#</td>
												<td>#name#</td>
												<td>
													<cfif len(monitor_page_id)>
														<cfquery name="getPage" datasource="#this.dsn#">
															select *
															from FacebookPages
															where page_id = <cfqueryparam value="#monitor_page_id#" cfsqltype="cf_sql_varchar">
														</cfquery>
														<button class="btn btn-primary btn-sm page-button" data-id="#monitor_page_id#">#getPage.name#</button>
													<cfelseif len(monitor_post_id)>
														<cfquery name="getPost" datasource="#this.dsn#">
															select *
															from FacebookPagePosts
															where post_id = <cfqueryparam value="#monitor_post_id#" cfsqltype="cf_sql_varchar">
														</cfquery>
														<button class="btn btn-info btn-sm post-button" data-id="#monitor_post_id#">#left(getPost.message, 50)#&hellip;</button>
													<cfelseif len(searchTerm)>
														#searchTerm#
													</cfif>
												</td>
												<td>#dateFormat(startDate, 'mm/dd/yyyy')# #timeFormat(startDate, 'h:mm TT')#</td>
												<td>#dateFormat(endDate, 'mm/dd/yyyy')# #timeFormat(endDate, 'h:mm TT')#</td>
												<cfif service eq "Facebook">
													<td>#numberFormat(getEntryCount.comment_count, ",")#</td>
													<td>#numberFormat(getEntryCount.like_count, ",")#</td>
												<cfelse>
													<td>#numberFormat(getEntryCount.cnt, ",")#</td>
												</cfif>
												<td>
													<cfif service eq "Facebook">
														<cfif len(monitor_page_id)>
															<button class="btn btn-warning btn-small monitor-page-button" data-scheduleid="#scheduleId#" data-pageid="#monitor_page_id#" data-pagename="#getPage.name#" data-toggle="tooltip" data-placement="bottom" title="Edit Page Monitor">
																<span class="glyphicon glyphicon-wrench"></span>
															</button>
														<cfelseif len(monitor_post_id)>
															<button class="btn btn-warning btn-small monitor-post-button" data-scheduleid="#scheduleId#" data-postid="#monitor_post_id#" data-postmessage="#getPost.message#" data-toggle="tooltip" data-placement="bottom" title="Edit Page Monitor">
																<span class="glyphicon glyphicon-wrench"></span>
															</button>
														</cfif>
													</cfif>
													<cfif service eq "Instagram">
														<button class="btn btn-warning btn-small monitor-instagram-term-button" data-scheduleid="#scheduleId#" data-searchterm="#searchTerm#" data-toggle="tooltip" data-placement="bottom" title="Edit Term Monitor">
															<span class="glyphicon glyphicon-wrench"></span>
														</button>
													</cfif>													
													<cfif service eq "Twitter">
														<button class="btn btn-warning btn-small monitor-twitter-term-button" data-scheduleid="#scheduleId#" data-searchterm="#searchTerm#" data-toggle="tooltip" data-placement="bottom" title="Edit Term Monitor">
															<span class="glyphicon glyphicon-wrench"></span>
														</button>
													</cfif>
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
	</div>
	
</div>
