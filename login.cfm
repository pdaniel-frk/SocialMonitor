<cfparam name="form.uname" default="">
<cfparam name="form.upass" default="">

<cfif structKeyExists(form, "__token")>
	<cfinclude template="login_submit.cfm">
</cfif>

<style type="text/css">
.form-signin {
  max-width: 330px;
  padding: 15px;
}
.form-signin .form-signin-heading{
  margin-bottom: 10px;
}
.form-signin .form-control {
  position: relative;
  height: auto;
  -webkit-box-sizing: border-box;
     -moz-box-sizing: border-box;
          box-sizing: border-box;
  padding: 10px;
  font-size: 16px;
}
.form-signin .form-control:focus {
  z-index: 2;
}
</style>

<form class="form-signin" role="form" method="post">
	<h2 class="form-signin-heading">Please sign in</h2>
	<div class="row">
		<div class="col-xs-12">
			<div class="form-group">
				<input class="form-control" type="text" name="uName" id="uName" placeholder="User name" required autofocus>
			</div>
		</div>
	</div>
	<div class="row">
		<div class="col-xs-12">
			<div class="form-group">
				<input class="form-control" type="password" name="uPass" id="uPass" placeholder="Password" required autocomplete="off">
			</div>
		</div>
	</div>
	<div class="row">
		<div class="col-xs-12">
			<button class="btn btn-lg btn-primary btn-block" type="submit">Sign In</button>
		</div>
	</div>

	<input type="hidden" name="__token" value="<cfoutput>#session.stamp#</cfoutput>">
</form>

<div class="row">
	<div class="col-xs-12">
		<a href="#" class="forgot-username">Forgot your Username?</a> | <a href="#" class="forgot-password">Forgot your Password?</a>
	</div>
</div>

<script>
	$(function(){
		$(document).on('click', '.forgot-username', function(e){
			e.preventDefault();
			$('#myModal .modal-dialog .modal-content').empty();
			$.get('<cfoutput>#request.webRoot#</cfoutput>partials/forgot-username.cfm', function(data){
				$('#myModal .modal-dialog .modal-content').html(data);
				$('#myModal').modal();
			});
		});


		$(document).on('click', '.forgot-password', function(e){
			e.preventDefault();
			$('#myModal .modal-dialog .modal-content').empty();
			$.get('<cfoutput>#request.webRoot#</cfoutput>partials/forgot-password.cfm', function(data){
				$('#myModal .modal-dialog .modal-content').html(data);
				$('#myModal').modal();
			});
		});
	});
</script>