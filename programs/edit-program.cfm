<cfparam name="url.programId" default="">
<cfparam name="form.programId" default="#url.programId#">
<cfif not isDefined("program") or not program.recordCount>
	<cfset reRoute(destination="index.cfm", message="The program you requested was either not found, or you do not have the correct permissions.")>
</cfif>
<cfparam name="form.name" default="#program.name#">
<cfparam name="form.description" default="#program.description#">
<cfparam name="form.startDate" default="#program.startDate#">
<cfparam name="form.endDate" default="#program.endDate#">
<cfparam name="errorFields" default="">

<h1 class="page-header">
	Programs &raquo; Edit <small><cfoutput>#program.name#</cfoutput></small>
</h1>

<cfif structKeyExists(form, "__token")>
	<cfinclude template="program-submit.cfm">
</cfif>

<div class="alert alert-danger form-errors" <cfif not listLen(errorFields)>style="display:none;"</cfif>>
	<button type="button" class="close" data-dismiss="alert">&times;</button>
	<div class="invalid-fields form-error">
		All highlighted fields below need to be completed.
	</div>
	<div class="program-exists form-error" style="display:none;">
		The program name you entered already exists. Please select a different program name, or edit the existing program.
	</div>
</div>

<div class="panel panel-primary">

	<div class="panel-body">

		<form name="programForm" id="myModal" method="post" action=""><!--- id seems a bit odd, but its so the autocomplete can target the element --->
			<div class="row">
				<div class="col-xs-12">
					<div class="form-group <cfif findNoCase('name', errorFields)>has-error</cfif>">
						<label>Name of Program</label>
						<input type="text" id="name" name="name" value="<cfoutput>#HTMLEditFormat(form.name)#</cfoutput>" maxlength="100" class="form-control">
					</div>
				</div>
				<div class="col-xs-12">
					<div class="form-group <cfif findNoCase('description', errorFields)>has-error</cfif>">
						<label>Description</label>
						<textarea id="description" name="description" class="form-control"><cfoutput>#HTMLEditFormat(form.description)#</cfoutput></textarea>
					</div>
				</div>
				<div class="col-xs-6">
					<div class="form-group <cfif findNoCase('startDate', errorFields)>has-error</cfif>">
						<label>Start</label>
						<div class="input-group">
							<input type="text" id="startDate" name="startDate" value="<cfoutput>#dateFormat(form.startDate, this.formats.date)# #timeFormat(form.startDate, this.formats.time)#</cfoutput>" placeholder="<cfoutput>#this.formats.date# #this.formats.time#</cfoutput>" class="form-control datepicker">
							<span class="input-group-addon">
								<b class="glyphicon glyphicon-calendar"></b>
							</span>
						</div>
					</div>
				</div>
				<div class="col-xs-6">
					<div class="form-group <cfif findNoCase('endDate', errorFields)>has-error</cfif>">
						<label>End</label>
						<div class="input-group">
							<input type="text" id="endDate" name="endDate" value="<cfoutput>#dateFormat(form.endDate, this.formats.date)# #timeFormat(form.endDate, this.formats.time)#</cfoutput>" placeholder="<cfoutput>#this.formats.date# #this.formats.time#</cfoutput>" class="form-control datepicker">
							<span class="input-group-addon">
								<b class="glyphicon glyphicon-calendar"></b>
							</span>
						</div>
							<span class="help-block">Hint: Leave blank to allow this program to run forever (within reason).</span>
					</div>
				</div>
			</div>
			<div class="modal-footer">
				<button type="submit" class="btn btn-primary">Save Changes</button>
				<!--- csrf --->
				<input type="hidden" name="__token" id="__token" value="<cfoutput>#session.stamp#</cfoutput>">
				<input type="hidden" name="programId" id="programId" value="<cfoutput>#form.programId#</cfoutput>">
			</div>
		</form>

	</div>

</div>