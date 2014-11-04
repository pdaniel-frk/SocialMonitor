<cfprocessingdirective suppressWhitespace="true">
<cfsetting enablecfoutputonly="true">
<cfparam name="url.scheduleId" default="">
<cfparam name="url.postId" default="">
<cfparam name="url.postMessage" default="">
<cfparam name="url.searchTerm" default="">
<cfparam name="post.postId" default="#url.postId#">
<cfparam name="post.startDate" default="">
<cfparam name="post.endDate" default="">
<cfset formTitle = 'New Post Monitor'>
<cfif len(url.postMessage)>
	<cfset formTitle &= ' - #left(url.postMessage, 25)#&hellip;'>
</cfif>
<cfif len(url.postId) or len(url.scheduleId)>

	<cfset init("Schedules")>
	<cfset getScheduleInfo = oSchedules.getSchedules (
		service = 'Facebook',
		scheduleId = url.scheduleId,
		monitor_post_id = url.postId
	)>
	<cfif getScheduleInfo.recordCount>
		<cfset formTitle = 'Edit Post Monitor - #left(getScheduleInfo.postMessage, 25)#&hellip;'>
		<cfset post.startDate = getScheduleInfo.startDate>
		<cfset post.endDate = getScheduleInfo.endDate>
	</cfif>
</cfif>
<!--- display form that will appear in a modal --->
<cfoutput>
<form name="monitorPostForm">
	<div class="modal-header">
		<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
		<h4 class="modal-title" id="myModalLabel">#formTitle#</h4>
	</div>
	<div class="modal-body">
		<div class="row">
			<div class="col-xs-12">
				<div class="form-group">
					<label>Name of Schedule</label>
					<input type="text" id="name" name="name" value="<cfif isDefined('getScheduleInfo')>#HTMLEditFormat(getScheduleInfo.name)#</cfif>" maxlength="100" class="form-control">
				</div>
			</div>
			<div class="col-xs-12">
				<div class="form-group">
					<label>Search Term</label>
					<input type="text" id="searchTerm" name="searchTerm" value="#HTMLEditFormat(getScheduleInfo.searchTerm)#" maxlength="100" class="form-control">
				</div>
			</div>
			<div class="col-xs-6">
				<div class="form-group">
					<label>Start (at 00:00:00)</label>
					<div class="input-group">
						<input type="text" id="startDate" name="startDate" value="#dateFormat(post.startDate, 'mm/dd/yyyy')#" placeholder="mm/dd/yyyy" class="form-control datepicker">
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
						<input type="text" id="endDate" name="endDate" value="#dateFormat(post.endDate, 'mm/dd/yyyy')#" placeholder="mm/dd/yyyy" class="form-control datepicker">
						<span class="input-group-addon">
							<b class="glyphicon glyphicon-calendar"></b>
						</span>
					</div>
				</div>
			</div>
		</div>
		<cfif len(url.postId) and getScheduleInfo.recordCount>
			<div class="row">
				<div class="col-xs-12">
					<div class="text-center">
						<button type="button" class="btn btn-danger btn-stop-post-monitor">STOP MONITORING THIS POST <span class="glyphicon glyphicon-eye-close"></span></button>
					</div>
				</div>
			</div>
		</cfif>
	</div>
	<div class="modal-footer">
		<button type="button" class="btn btn-sm btn-link" data-dismiss="modal"><span class="text-danger">Close</span></button>
		<button type="button" class="btn btn-primary btn-save-post-monitor">Save changes</button>
		<input type="hidden" name="postId" value="#post.postId#">
		<input type="hidden" name="scheduleId" value="#url.scheduleId#">
		<input type="hidden" name="stopMonitor" value="">
		<!--- csrf --->
		<input type="hidden" name="__token" id="__token" value="<cfoutput>#session.stamp#</cfoutput>">
	</div>
</form>
</cfoutput>
</cfprocessingdirective>