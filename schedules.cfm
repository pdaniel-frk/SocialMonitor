<cfparam name="url.service" default="">
<cfset init("Schedules")>
<cfset getSchedules = oSchedules.getSchedules(service=url.service)>

<h1 class="page-header">
	Schedules
	<cfif len(trim(url.service)) and getSchedules.recordCount>
		&raquo; <cfoutput>#HTMLEditFormat(url.service)#</cfoutput>
	</cfif>
	<span class="pull-right">
		<button class="btn btn-sm show-finished">Show finished</button>
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
						<!--- <div class="panel-body"> --->

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
											<cfset lc = currentRow>
											<cfinclude template="partials\show-schedule-row.cfm">
										</cfoutput>
									</tbody>
								</table>
							<!--- </div> --->
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