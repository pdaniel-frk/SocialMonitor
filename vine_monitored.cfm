<!--- get monitored search terms --->
<cfquery name="getTerms" datasource="#this.dsn#">
	select
		s.scheduleId,
		s.name,
		s.searchTerm,
		s.startDate,
		s.endDate,
		(select count(1) from vineEntries where searchTerm = s.searchTerm) as entry_count
	from Schedules s
	where isdate(s.deleteDate) = 0
	and s.service = 'Vine'
</cfquery>


<h1 class="page-header">
	Vine &raquo; Monitored Terms
</h1>


<div class="panel panel-primary">

	<div class="panel-heading">
		<p class="panel-title">
			<cfoutput>
				<strong>
					Terms: #numberFormat(getTerms.recordCount, ",")#
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
						<a data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
						Monitored Search Terms
						</a>
						<span class="pull-right"><cfoutput>#numberFormat(getTerms.recordCount, ",")#</cfoutput></span>
						</h4>
					</div>
					<div id="collapseOne" class="panel-collapse collapse in">
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
												<td>
													<button class="btn btn-warning btn-xs monitor-vine-term-button" data-scheduleId="#scheduleId#" data-searchTerm="#searchTerm#" data-toggle="tooltip" data-placement="bottom" title="Edit Term Monitor">
														<span class="glyphicon glyphicon-edit"></span>
													</button>
													<button class="btn btn-info btn-xs run-schedule" data-scheduleid="#scheduleId#" data-service="vine" data-toggle="tooltip" data-placement="bottom" title="Run this task">
														<span class="glyphicon glyphicon-play-circle"></span>
													</button>
													<a href="#request.webRoot#show_entries.cfm?scheduleId=#scheduleId#">
														<button class="btn btn-primary btn-xs view-entries" data-scheduleid="#scheduleId#" data-service="vine" data-toggle="tooltip" data-placement="bottom" title="View collected entries">
															<span class="glyphicon glyphicon-eye-open"></span>
														</button>
													</a>
													<button class="btn btn-default btn-xs download-entries" data-scheduleid="#scheduleId#" data-service="vine" data-toggle="tooltip" data-placement="bottom" title="Download collected entries">
														<span class="glyphicon glyphicon-download-alt"></span>
													</button>
												</td>
											</tr>
										</cfoutput>
									</tbody>
								</table>

								<div class="progress progress-striped progress-info active" style="display:none;">
									<div class="progress-bar" style="width: 100%;"></div>
								</div>

							</div>
						</div>
					</div>
				</div>
			</cfif>
		</div>
	</div>
</div>


