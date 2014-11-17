<cfset init("Programs")>
<cfset init("Entries")>
<cfset getPrograms = oPrograms.getPrograms(customerId=session.customerId, userId=session.userId)>

<h1 class="page-header">
	Programs &raquo; List
	<span class="pull-right">
		<button class="btn btn-sm show-finished">Show finished</button>
		<button class="btn btn-sm show-archived">Show archived</button>
		<a href="add-program.cfm" class="btn btn-success btn-sm" data-toggle="tooltip" data-placement="bottom" title="Add a new program">
			<span class="glyphicon glyphicon-plus"></span>
		</a>
	</span>
</h1>

<div class="panel panel-primary">

	<div class="panel-heading">
		<p class="panel-title">
			<cfoutput>
				<strong>
					Programs: #numberFormat(getPrograms.recordCount)#
				</strong>
			</cfoutput>
		</p>
	</div>

	<div class="panel-body">

		<div class="panel panel-primary">

			<div class="table-responsive">
				<table class="table table-striped" style="font-family:sans-serif;font-size:12px;">
					<thead>
						<tr>
							<th>#</th>
							<th nowrap>Program Name</th>
							<th>Description</th>
							<th>Start</th>
							<th>End</th>
							<th>Schedules</th>
							<th>Entries</th>
							<th>Actions</th>
						</tr>
					</thead>
					<tbody>

						<cfoutput query="getPrograms">

							<cfquery name="getScheduleCount" datasource="#this.dsn#">
								select count(1) as cnt
								from Schedules
								where isdate(deleteDate) = 0
								and programId = <cfqueryparam value="#getPrograms.Id#" cfsqltype="cf_sql_integer">
							</cfquery>

							<tr class="<cfif len(endDate) and dateCompare(endDate, now()) lt 0>finished warning</cfif>">

								<td>#currentRow#</td>
								<td>#name#</td>
								<td>#description#</td>
								<td>#dateFormat(startDate, this.formats.date)# #timeFormat(startDate, this.formats.time)#</td>
								<td>#dateFormat(endDate, this.formats.date)# #timeFormat(endDate, this.formats.time)#</td>
								<td>#numberFormat(getScheduleCount.cnt, ",")#</td>
								<td>#numberFormat(oEntries.getEntryCount(programId=Id), ",")#</td>
								<td>
									<a href="edit-program.cfm?programId=#id#" class="btn btn-warning btn-xs" data-toggle="tooltip" data-placement="bottom" title="Edit Program">
										<span class="glyphicon glyphicon-edit"></span>
									</a>
									<a href="#request.webRoot#schedules/?programId=#id#" class="btn btn-primary btn-xs" data-toggle="tooltip" data-placement="bottom" title="View Schedules">
										<span class="glyphicon glyphicon-list"></span>
									</a>
									<a href="#request.webRoot#entries/view.cfm?programId=#Id#" class="btn btn-primary btn-xs" data-toggle="tooltip" data-placement="bottom" title="View collected entries">
										<span class="glyphicon glyphicon-eye-open"></span>
									</a>
									<button class="btn btn-default btn-xs download-entries" data-programid="#Id#" data-toggle="tooltip" data-placement="bottom" title="Download collected entries">
										<span class="glyphicon glyphicon-download-alt"></span>
									</button>
									<a href="cancel-program.cfm?programId=#id#" class="btn btn-danger btn-xs" data-toggle="tooltip" data-placement="bottom" title="Cancel Program">
										<span class="glyphicon glyphicon-trash"></span>
									</a>
								</td>

							</tr>

						</cfoutput>

					</tbody>
				</table>

			</div>

		</div>

		<div class="progress progress-striped progress-info active" style="display:none;">
			<div class="progress-bar" style="width: 100%;"></div>
		</div>

	</div>

</div>


<script>
	$(function(){
		$('.finished').css('display', 'none');
		$(document).on('click', '.show-finished', function(e){
			e.preventDefault();
			console.log('!');
			$('.finished').toggle('slow');
		});
	});
</script>