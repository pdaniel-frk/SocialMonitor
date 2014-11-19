<cfprocessingdirective suppressWhitespace="true">
<cfsetting enablecfoutputonly="true">
<cfparam name="form.uName" default="">
<cfparam name="errorFields" default="">
<cfset formTitle = 'Forgot Password'>
<!--- display form that will appear in a modal --->
<cfoutput>
<form name="forgotPasswordForm" class="form form-horizontal" method="post">
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
				<p>Please submit your username below. Your password reset link will be sent to the email address provided at the time of registration.</p>
			</div>
			<div class="col-xs-12">
				<div class="form-group <cfif findNoCase('firstName', errorFields)>has-error</cfif>">
					<label for="uName" class="col-sm-4 control-label">Username</label>
					<div class="col-sm-8">
						<input type="text" name="uName" id="uName" class="form-control" required maxlength="50" value="#HTMLEditFormat(form.uName)#">
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
		$('form[name=forgotPasswordForm]').submit(function(e){
			e.preventDefault();
			$.post('partials/forgot-password-submit.cfm', $('form[name=forgotPasswordForm]').serialize(), function(response){
			})
			.done(function(data){
				var success = data.success;
				if(success === true){
					$('.modal-body').html('An email has been sent to the contact email associated with your account. This email describes how to get your new password.');
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