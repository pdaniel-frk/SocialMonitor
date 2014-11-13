<cfparam name="url.scheduleId" default="">
<cfparam name="form.scheduleId" default="#url.scheduleId#">
<cfif not isDefined("schedule") or not schedule.recordCount>
	<cfset reRoute(destination="index.cfm", message="The schedule you requested was either not found, or you do not have the correct permissions.")>
</cfif>
<cfparam name="form.programId" default="#schedule.programId#">
<cfparam name="form.name" default="#schedule.name#">
<cfparam name="form.searchTerm" default="#schedule.searchTerm#">
<cfparam name="form.startDate" default="#schedule.startDate#">
<cfparam name="form.endDate" default="#schedule.endDate#">
<cfparam name="form.service" default="#schedule.service#">
<cfparam name="form.monitor_page_id" default="">
<cfparam name="form.monitor_post_id" default="">
<cfparam name="errorFields" default="">

<cfset init("Programs")>
<cfset program = oPrograms.getPrograms(scheduleId=form.scheduleId)>

<h1 class="page-header">
	Schedules &raquo; Edit <small><cfoutput>#schedule.name#</cfoutput></small>
</h1>

<cfif structKeyExists(form, "__token")>
	<cfinclude template="schedule-submit.cfm">
</cfif>

<div class="alert alert-danger form-errors" <cfif not listLen(errorFields)>style="display:none;"</cfif>>
	<button type="button" class="close" data-dismiss="alert">&times;</button>
	<div class="invalid-fields form-error">
		All highlighted fields below need to be completed.
	</div>
</div>

<div class="panel panel-primary">

	<div class="panel-body">

		<form name="scheduleForm" method="post" action="">
			<div class="row">
				<div class="col-xs-12">
					<div class="form-group">
						<label>Program</label>
						<input type="text" value="<cfoutput>#HTMLEditFormat(program.name)#</cfoutput>" class="form-control" disabled>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-xs-12">
					<div class="form-group <cfif findNoCase('name', errorFields)>has-error</cfif>">
						<label>Name of Schedule</label>
						<input type="text" id="name" name="name" value="<cfoutput>#HTMLEditFormat(form.name)#</cfoutput>" maxlength="100" class="form-control">
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-xs-6">
					<div class="form-group <cfif findNoCase('name', errorFields)>has-error</cfif>">
						<label>Search Term</label>
						<!--- <div class="input-group"> --->
							<input type="text" id="searchTerm" name="searchTerm" value="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>" maxlength="100" class="form-control">
							<!--- <span class="input-group-addon">
								<b class="glyphicon glyphicon-plus add-search-term"></b>
							</span>
						</div> --->
						<span class="help-block">Enter your #hashtag here. Some services will ignore the #.</span>
						<span class="help-block">Most services allow multiple search terms (eg. #promotions @mardenkane).</span>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-xs-6">
					<div class="form-group <cfif findNoCase('startDate', errorFields)>has-error</cfif>">
						<label>Start (at 00:00:00)</label>
						<div class="input-group">
							<input type="text" id="startDate" name="startDate" value="<cfoutput>#HTMLEditFormat(form.startDate)#</cfoutput>" placeholder="mm/dd/yyyy" class="form-control datepicker">
							<span class="input-group-addon">
								<b class="glyphicon glyphicon-calendar"></b>
							</span>
						</div>
					</div>
				</div>
				<div class="col-xs-6">
					<div class="form-group <cfif findNoCase('endDate', errorFields)>has-error</cfif>">
						<label>End (at 23:59:59)</label>
						<div class="input-group">
							<input type="text" id="endDate" name="endDate" value="<cfoutput>#HTMLEditFormat(form.endDate)#</cfoutput>" placeholder="mm/dd/yyyy" class="form-control datepicker">
							<span class="input-group-addon">
								<b class="glyphicon glyphicon-calendar"></b>
							</span>
						</div>
						<span class="help-block">Hint: Leave blank to allow this program to run forever (within reason).</span>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-xs-12">
					<div class="form-group <cfif findNoCase('service', errorFields)>has-error</cfif>">
						<label>Monitoring Service</label> <cfoutput>#HTMLEditFormat(form.service)#</cfoutput>
					</div>
				</div>
			</div>

			<cfif form.service eq "Facebook">

				<!--- <cfdump var="#schedule#"> --->

				<div class="row">
					<div class="col-xs-12">
						<div class="form-group">
							<label>Monitoring Page</label>
							<cfif len(schedule.monitor_page_id)>
								<cfquery name="getPage" datasource="#this.dsn#">
									select
										Id,
										category,
										checkins,
										[description],
										likes,
										link,
										name,
										username
									from FacebookPages
									where Id = <cfqueryparam value="#schedule.monitor_page_id#" cfsqltype="cf_sql_varchar">
									and scheduleId = <cfqueryparam value="#form.scheduleId#" cfsqltype="cf_sql_integer">
								</cfquery>

								<div class="table-responsive">
									<table class="table table-condensed">
										<thead>
											<tr>
												<th>#</th>
												<th>Name</th>
												<th>Category</th>
												<th>Likes</th>
												<th>Actions</th>
											</tr>
										</thead>
										<tbody>
											<tr>
												<td>1</td>
												<td><cfoutput><a href="#getPage.link#" target="_blank">#getPage.name#</a></cfoutput></td>
												<td><cfoutput>#getPage.category#</cfoutput></td>
												<td><cfoutput>#numberFormat(getPage.likes, ",")#</cfoutput></td>
												<td nowrap>
													<a href="edit-page.cfm?type=edit-page&scheduleId=<cfoutput>#form.scheduleId#</cfoutput>" class="btn btn-warning btn-xs" data-toggle="tooltip" data-placement="bottom" title="Change monitored page">
														<span class="glyphicon glyphicon-edit"></span>
													</a>
													<a href="edit-page.cfm?type=remove-page&scheduleId=<cfoutput>#form.scheduleId#</cfoutput>" class="btn btn-danger btn-xs" data-toggle="tooltip" data-placement="bottom" title="Remove monitored page">
														<span class="glyphicon glyphicon-trash"></span>
													</a>
												</td>
											</tr>
										</tbody>
									</table>
								</div>

							<cfelse>
								<a href="edit-page.cfm?type=add-page&scheduleId=<cfoutput>#form.scheduleId#</cfoutput>" class="btn btn-warning btn-xs" data-toggle="tooltip" data-placement="bottom" title="Add monitored page">
									Add a page to monitor
								</a>
							</cfif>
						</div>
					</div>
				</div>

				<div class="row">
					<div class="col-xs-12">
						<div class="form-group">
							<label>Monitoring Post</label>
							<cfif len(schedule.monitor_post_id)>
								<cfset init("Facebook")>
								<cfquery name="getPost" datasource="#this.dsn#">
									select
										pageId,
										Id,
										[from.name],
										[from.id],
										[message],
										[type],
										status_type,
										[object_id],
										created_time,
										[shares.count],
										[likes.count]
									from FacebookPosts
									where Id = <cfqueryparam value="#schedule.monitor_post_id#" cfsqltype="cf_sql_varchar">
									and scheduleId = <cfqueryparam value="#form.scheduleId#" cfsqltype="cf_sql_integer">
								</cfquery>

								<div class="table-responsive">
									<table class="table table-condensed">
										<thead>
											<tr>
												<th>Date</th>
												<th>From</th>
												<th>Message</th>
												<th>Likes</th>
												<th>Shares</th>
												<th>Actions</th>
											</tr>
										</thead>
										<tbody>
											<tr>
												<td><cfoutput>#oFacebook.convertCreatedTimeToString(getPost.created_time)#</cfoutput></td>
												<td><cfoutput>#getPost.from.name#</cfoutput></td>
												<td><cfoutput>#getPost.message#</cfoutput></td>
												<td><cfoutput>#numberFormat(getPost.likes.count, ",")#</cfoutput></td>
												<td><cfoutput>#numberFormat(getPost.shares.count, ",")#</cfoutput></td>
												<td nowrap>
													<a href="edit-page.cfm?type=edit-post&scheduleId=<cfoutput>#form.scheduleId#</cfoutput>" class="btn btn-warning btn-xs" data-toggle="tooltip" data-placement="bottom" title="Change monitored post">
														<span class="glyphicon glyphicon-edit"></span>
													</a>
													<a href="edit-page.cfm?type=remove-post&scheduleId=<cfoutput>#form.scheduleId#</cfoutput>" class="btn btn-danger btn-xs" data-toggle="tooltip" data-placement="bottom" title="Remove monitored post">
														<span class="glyphicon glyphicon-trash"></span>
													</a>
												</td>
											</tr>
										</tbody>
									</table>
								</div>
							<cfelse>
								<a href="edit-page.cfm?type=add-post&scheduleId=<cfoutput>#form.scheduleId#</cfoutput>" class="btn btn-warning btn-xs" data-toggle="tooltip" data-placement="bottom" title="Add monitored post">
									Add a post to monitor
								</a>
							</cfif>
						</div>
					</div>
				</div>

			</cfif>

			<div class="modal-footer">
				<a href="index.cfm" class="btn btn-link"><span class="text-warning">Cancel</span></a>
				<button type="submit" class="btn btn-primary">Save Changes</button>
				<!--- csrf --->
				<input type="hidden" name="__token" id="__token" value="<cfoutput>#session.stamp#</cfoutput>">
				<input type="hidden" name="scheduleId" id="scheduleId" value="<cfoutput>#form.scheduleId#</cfoutput>">
			</div>
		</form>

	</div>

</div>