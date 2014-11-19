<cfprocessingdirective suppressWhitespace="true">
<cfsetting enablecfoutputonly="true">
<cfparam name="form.firstName" default="">
<cfparam name="form.lastName" default="">
<cfparam name="form.emailAddress" default="">
<cfparam name="errorFields" default="">
<cfset formTitle = 'Forgot Username'>
<!--- display form that will appear in a modal --->
<cfoutput>
<form name="forgotUsernameForm" class="form form-horizontal" method="post">
	<div class="modal-header">
		<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
		<h4 class="modal-title" id="myModalLabel">#formTitle#</h4>
	</div>
	<div class="modal-body">

		<div class="alert alert-danger form-errors" <cfif not listLen(errorFields)>style="display:none;"</cfif>>
		    <!--- <button type="button" class="close" data-dismiss="alert">&times;</button> --->
		    <div class="invalid-fields form-error">
		        All highlighted fields below need to be completed.
		    </div>
		    <div class="user-not-found form-error" style="display:none;">
		        The information you provided was not found in our system.
		    </div>
		</div>

		<div class="row">
			<div class="col-xs-12">
				<p>Please fill out the form below. Your username will be emailed to you.</p>
			</div>
			<div class="col-xs-12">
				<div class="form-group <cfif findNoCase('firstName', errorFields)>has-error</cfif>">
					<label for="firstName" class="col-sm-4 control-label">First Name</label>
					<div class="col-sm-8">
						<input type="text" name="firstName" id="firstName" class="form-control" required maxlength="50" value="#HTMLEditFormat(form.firstName)#">
					</div>
				</div>
				<div class="form-group <cfif findNoCase('lastName', errorFields)>has-error</cfif>">
					<label for="lastName" class="col-sm-4 control-label">Last Name</label>
					<div class="col-sm-8">
						<input type="text" name="lastName" id="lastName" class="form-control" required maxlength="50" value="#HTMLEditFormat(form.lastName)#">
					</div>
				</div>
				<div class="form-group <cfif findNoCase('emailAddress', errorFields)>has-error</cfif>">
					<label for="emailAddress" class="col-sm-4 control-label">Email Address</label>
					<div class="col-sm-8">
						<input type="email" name="emailAddress" id="emailAddress" class="form-control" required maxlength="100" value="#HTMLEditFormat(form.emailAddress)#">
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="modal-footer">
		<input type="submit" class="btn btn-lg btn-primary" value="Submit">
		<!--- csrf --->
		<input type="hidden" name="__token" id="__token" value="#session.stamp#">
	</div>
</form>
<script>
	$(function(){
		$('form[name=forgotUsernameForm]').submit(function(e){
			e.preventDefault();
			$.post('partials/forgot-username-submit.cfm', $('form[name=forgotUsernameForm]').serialize(), function(response){
			})
			.done(function(data){
				var success = data.success;
				if(success === true){
					$('.modal-body').html('Your username has been emailed to the address provided.');
					$('input[type=submit]').hide();
					window.setTimeout("$('##myModal').modal('hide');", 5000);
				} else {
					$('.user-not-found').show();
					$('.form-error').not('.user-not-found').hide();
					$('.form-errors').fadeIn('slow');
				}
			})
			.fail(function(){})
			.always(function(){});
			return false;
		});
	});
</script>
</cfoutput>
</cfprocessingdirective>