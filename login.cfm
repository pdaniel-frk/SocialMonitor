<cfparam name="form.uname" default="">
<cfparam name="form.upass" default="">

<cfif structKeyExists(form, "signInKey")>
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
	<div class="row">
		<div class="col-xs-12">
			<a href="" class="btn btn-link">Forgot username or password?</a>
		</div>
	</div>
	<input type="hidden" name="signInKey" value="<cfoutput>#hash(getTickCount(), 'sha-1')#</cfoutput>">
</form>