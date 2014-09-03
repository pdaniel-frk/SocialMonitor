<cfprocessingdirective suppressWhitespace="true">
<cfsetting enablecfoutputonly="true">
<cfparam name="url.scheduleId" default="">
<cfparam name="url.pageId" default="">
<cfparam name="url.pageName" default="">
<cfparam name="page.pageName" default="#url.pageName#">
<cfparam name="page.pageId" default="#url.pageId#">
<cfparam name="page.startDate" default="">
<cfparam name="page.endDate" default="">
<cfset formTitle = 'New Page Monitor'>
<cfif len(url.pageName)>
	<cfset formTitle &= ' - #url.pageName#'>
</cfif>
<cfif len(url.pageId) or len(url.scheduleId)>
	<cfquery name="getScheduleInfo" datasource="#this.dsn#">
		select 
			s.scheduleId,
			s.name,
			s.startDate, 
			s.endDate, 
			s.searchTerm,
			f.name as pageName
		from Schedules s
		left join FacebookPages f on s.scheduleId = f.scheduleId
		where s.service = 'Facebook'
		and isdate(s.deleteDate) = 0
		<cfif len(url.scheduleId)>
			and s.scheduleId = <cfqueryparam value="#url.scheduleId#" cfsqltype="cf_sql_integer">
		</cfif>
		<cfif len(url.pageId)>
			and s.monitor_page_id = <cfqueryparam value="#url.pageId#" cfsqltype="cf_sql_varchar">
		</cfif>
	</cfquery>
	<cfif getScheduleInfo.recordCount>
		<cfset formTitle = 'Edit Page Monitor - #getScheduleInfo.pageName#'>
		<cfset page.pageName = getScheduleInfo.pageName>
		<cfset page.startDate = getScheduleInfo.startDate>
		<cfset page.endDate = getScheduleInfo.endDate>
	</cfif>
</cfif>
<!--- display form that will appear in a modal --->
<cfoutput>
<form name="monitorPageForm" method="post" action="services/monitor-page.cfm">
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
			<div class="col-xs-6">
				<div class="form-group">
					<label>Start (at 00:00:00)</label>
					<div class="input-group">
						<input type="text" id="startDate" name="startDate" value="#dateFormat(page.startDate, 'mm/dd/yyyy')#" placeholder="mm/dd/yyyy" class="form-control datepicker">
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
						<input type="text" id="endDate" name="endDate" value="#dateFormat(page.endDate, 'mm/dd/yyyy')#" placeholder="mm/dd/yyyy" class="form-control datepicker">
						<span class="input-group-addon">
							<b class="glyphicon glyphicon-calendar"></b>
						</span>
					</div>
				</div>
			</div>
		</div>
	</div>
	<cfif len(url.pageId) and getScheduleInfo.recordCount>
		<div class="row">
			<div class="col-xs-12">
				<div class="text-center">
					<button type="button" class="btn btn-danger btn-stop-page-monitor">STOP MONITORING THIS PAGE <span class="glyphicon glyphicon-eye-close"></span></button>
				</div>
			</div>
		</div>
	</cfif>
	<div class="modal-footer">
		<button type="button" class="btn btn-sm btn-link" data-dismiss="modal"><span class="text-danger">Close</span></button>
		<button type="button" class="btn btn-primary btn-save-page-monitor">Save changes</button>
		<input type="hidden" name="pageId" value="#page.pageId#">
		<input type="hidden" name="pageName" value="#page.pageName#">
		<input type="hidden" name="scheduleId" value="#url.scheduleId#">
		<input type="hidden" name="stopMonitor" value="">
		<!--- csrf --->
		<input type="hidden" name="__token" id="__token" value="<cfoutput>#session.stamp#</cfoutput>">
	</div>
</form>
</cfoutput>
</cfprocessingdirective>