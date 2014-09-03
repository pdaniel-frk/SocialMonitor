<cfprocessingdirective suppressWhitespace="true">
<cfsetting enablecfoutputonly="true">
<cfparam name="url.scheduleId" default="">
<cfparam name="url.searchTerm" default="">
<cfparam name="startDate" default="">
<cfparam name="endDate" default="">
<cfset formTitle = 'New Vine Search Term Monitor'>
<cfif len(url.searchTerm)>
	<cfset formTitle &= ' - #url.searchTerm#'>
</cfif>
<cfif len(url.searchTerm) or len(url.scheduleId)>
	<cfquery name="getScheduleInfo" datasource="#this.dsn#">
		select
			s.scheduleId,
			s.name,
			s.startDate,
			s.endDate,
			s.searchTerm
		from Schedules s
		where s.service = 'Vine'
		and isdate(s.deleteDate) = 0
		<cfif len(url.scheduleId)>
			and s.scheduleId = <cfqueryparam value="#url.scheduleId#" cfsqltype="cf_sql_integer">
		</cfif>
		<cfif len(url.searchTerm)>
			and s.searchTerm = <cfqueryparam value="#url.searchTerm#" cfsqltype="cf_sql_varchar">
		</cfif>
	</cfquery>
	<cfif getScheduleInfo.recordCount>
		<cfset formTitle = 'Edit Vine Search Term Monitor - #getScheduleInfo.searchTerm#'>
		<cfset startDate = getScheduleInfo.startDate>
		<cfset endDate = getScheduleInfo.endDate>
	</cfif>
</cfif>
<!--- display form that will appear in a modal --->
<cfoutput>
<form name="monitorForm" method="post" action="services/monitor-vine-term.cfm">
	<div class="modal-header">
		<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
		<h4 class="modal-title" id="myModalLabel">#formTitle#</h4>
	</div>
	<div class="modal-body">
		<div class="row">
			<div class="col-xs-12">
				<div class="form-group">
					<label>Name of Program, Schedule, etc.</label>
					<input type="text" id="name" name="name" value="<cfif isDefined('getScheduleInfo')>#HTMLEditFormat(getScheduleInfo.name)#</cfif>" maxlength="100" class="form-control">
				</div>
			</div>
			<div class="col-xs-12">
				<div class="form-group">
					<label>Search Term</label>
					<input type="text" id="searchTerm" name="searchTerm" value="#HTMLEditFormat(url.searchTerm)#" maxlength="100" class="form-control">
				</div>
			</div>
			<div class="col-xs-6">
				<div class="form-group">
					<label>Start (at 00:00:00)</label>
					<div class="input-group">
						<input type="text" id="startDate" name="startDate" value="#dateFormat(startDate, 'mm/dd/yyyy')#" placeholder="mm/dd/yyyy" class="form-control datepicker">
						<span class="input-group-addon">
							<b class="glyphicon glyphicon-calendar"></b>
						</span>
					</div>
				</div>
			</div>
			<div class="col-xs-6">
				<div class="form-group">
					<label>End (at 23:59:59)</label>
					<div class="input-group">
						<input type="text" id="endDate" name="endDate" value="#dateFormat(endDate, 'mm/dd/yyyy')#" placeholder="mm/dd/yyyy" class="form-control datepicker">
						<span class="input-group-addon">
							<b class="glyphicon glyphicon-calendar"></b>
						</span>
					</div>
				</div>
			</div>
		</div>
	</div>
	<cfif len(url.searchTerm) and getScheduleInfo.recordCount>
		<div class="row">
			<div class="col-xs-12">
				<div class="text-center">
					<button type="button" class="btn btn-danger btn-stop-term-monitor">STOP MONITORING THIS SEARCH TERM <span class="glyphicon glyphicon-eye-close"></span></button>
				</div>
			</div>
		</div>
	</cfif>
	<div class="modal-footer">
		<button type="button" class="btn btn-sm btn-link" data-dismiss="modal"><span class="text-danger">Close</span></button>
		<button type="button" class="btn btn-primary btn-save-vine-term-monitor">Save changes</button>
		<input type="hidden" name="scheduleId" value="#url.scheduleId#">
		<input type="hidden" name="stopMonitor" value="">
		<!--- csrf --->
		<input type="hidden" name="__token" id="__token" value="<cfoutput>#session.stamp#</cfoutput>">
	</div>
</form>
</cfoutput>
</cfprocessingdirective>