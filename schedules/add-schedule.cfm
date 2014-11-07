<cfparam name="url.programId" default="">
<cfparam name="form.programId" default="#url.programId#">
<cfparam name="form.name" default="">
<cfparam name="form.searchTerm" default="">
<cfparam name="form.startDate" default="">
<cfparam name="form.endDate" default="">
<cfparam name="form.service" default="">
<cfparam name="errorFields" default="">
<cfset init("Programs")>
<cfset programs = oPrograms.getPrograms(customerId=session.customerId, userId=session.userId)>

<h1 class="page-header">
	Schedules &raquo; Add
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

		<form name="scheduleForm" method="post" action=""><!--- id seems a bit odd, but its so the autocomplete can target the element --->
			<div class="row">
				<div class="col-xs-12">
					<div class="form-group <cfif findNoCase('programId', errorFields)>has-error</cfif>">
						<label>Program</label>
						<select name="programId" id="programId" class="form-control">
							<option value="">Select&hellip;</option>
							<cfoutput query="programs">
								<option value="#Id#" <cfif Id eq form.programId>selected="selected"</cfif>>#name#</option>
							</cfoutput>
						</select>
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
						<label>Service(s) to Monitor</label>
						<div class="row">
							<div class="col-xs-2">
								<div class="checkbox">
									<label>
										<input type="checkbox" name="service" value="Facebook" <cfif listFindNoCase(form.service, "Facebook")>checked="checked"</cfif>>
										Facebook
									</label>
								</div>
								<div class="checkbox">
									<label>
										<input type="checkbox" name="service" value="Foursquare" <cfif listFindNoCase(form.service, "Foursquare")>checked="checked"</cfif> disabled>
										Foursquare
									</label>
								</div>
								<div class="checkbox">
									<label>
										<input type="checkbox" name="service" value="GPlus" <cfif listFindNoCase(form.service, "GPlus")>checked="checked"</cfif>>
										Google+
									</label>
								</div>
							</div>
							<div class="col-xs-2">
								<div class="checkbox">
									<label>
										<input type="checkbox" name="service" value="Instagram" <cfif listFindNoCase(form.service, "Instagram")>checked="checked"</cfif>>
										Instagram
									</label>
								</div>
								<div class="checkbox">
									<label>
										<input type="checkbox" name="service" value="LinkedIn" <cfif listFindNoCase(form.service, "LinkedIn")>checked="checked"</cfif> disabled>
										LinkedIn
									</label>
								</div>
								<div class="checkbox">
									<label>
										<input type="checkbox" name="service" value="Pinterest" <cfif listFindNoCase(form.service, "Pinterest")>checked="checked"</cfif> disabled>
										Pinterest
									</label>
								</div>
							</div>
							<div class="col-xs-2">
								<div class="checkbox">
									<label>
										<input type="checkbox" name="service" value="Snapchat" <cfif listFindNoCase(form.service, "Snapchat")>checked="checked"</cfif> disabled>
										Snapchat
									</label>
								</div>
								<div class="checkbox">
									<label>
										<input type="checkbox" name="service" value="Tumblr" <cfif listFindNoCase(form.service, "Tumblr")>checked="checked"</cfif> disabled>
										Tumblr
									</label>
								</div>
								<div class="checkbox">
									<label>
										<input type="checkbox" name="service" value="Twitter" <cfif listFindNoCase(form.service, "Twitter")>checked="checked"</cfif>>
										Twitter
									</label>
								</div>
							</div>
							<div class="col-xs-2">
								<div class="checkbox">
									<label>
										<input type="checkbox" name="service" value="Vine" <cfif listFindNoCase(form.service, "Vine")>checked="checked"</cfif>>
										Vine
									</label>
								</div>
							</div>
						</div>
					</div>
					<span class="help-block">Hint: Each selected service will create a separate schedule. These may be edited separately.</span>
				</div>
			</div>
			<div class="modal-footer">
				<button type="submit" class="btn btn-primary">Next</button>
				<!--- csrf --->
				<input type="hidden" name="__token" id="__token" value="<cfoutput>#session.stamp#</cfoutput>">
			</div>
		</form>

	</div>

</div>

<script>
	$(function(){
		$('.add-search-term').css('cursor', 'pointer');
		$(document).on('click', '.add-search-term', function(){

		});
	});
</script>


