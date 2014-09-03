<h1 class="page-header">LinkedIn</h1>
<h2>Coming Soon!</h2>
<cfset onRequestEnd(cgi.script_name)>
<cfabort>

<cfapplication name="linkedintesting" sessionmanagement="yes" sessiontimeout="#createtimespan(0,0,20,0)#">

<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title>LinkedIn API Testing</title>
		<meta name="description" content="">
		<meta name="author" content="">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
		
		<!--- <link href="//netdna.bootstrapcdn.com/bootstrap/3.0.0-rc1/css/bootstrap.min.css" rel="stylesheet"> ---><!--- this seems to be missing some style declarations --->
		<link href="//promotions.mardenkane.com/common/bootstrap3/css/bootstrap.min.css" rel="stylesheet">
		
		<!--[if IE]>
			<script src="//html5shiv.googlecode.com/svn/trunk/html5.js"></script>
		<![endif]-->
		
		<!--[if lt IE 9]>
		   <script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
		<![endif]-->
		<![if !IE]>
		   <script src="//ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min.js"></script><!--- jquery 2 is only compatible w/ ie9+ --->
		<![endif]>
	
	</head>
	
	<cfif not structKeyExists(session, "user_authorized") or structKeyExists(url, "reset_authorization")>
		<cfset session.user_authorized = "">
	</cfif>
	
	<cfif not isDefined("session.linkedin")>
		
		<cfset session.linkedin = {}>
		<cfset session.linkedin.application_name = "mk-testing">
		<cfset session.linkedin.api_key = "o9cind8eyb2g">
		<cfset session.linkedin.secret_key = "u521IFrMs9RxPVph">
		<cfset session.linkedin.oauth_user_token = "d297f3a4-9dff-45f5-9984-02ce44f945c1">
		<cfset session.linkedin.oauth_user_secret = "a6573cf1-da2f-4c26-b39c-59f20e0ed1bd">
		<!--- validation params --->
		<cfset session.linkedin.csrf_validation_token = hash(getTickCount(), 'sha-1')>
		<cfset session.linkedin.code = "">
		<cfset session.linkedin.access_token = "">
		
	</cfif>
	
	<body>
		
		<div class="container">
			
			<cfinclude template="nav.cfm">
		
			<div class="jumbotron">
				<h1>LinkedIn API Testing</h1>
			</div>
		
			<cfif not len(session.user_authorized) and not structKeyExists(url, "code") and not structKeyExists(url, "state")>
				
				<!--- <cfoutput>#GenerateAuthorizationCode()#</cfoutput> --->
				<cfscript>
					GenerateAuthorizationCode();
				</cfscript>
				
			<cfelse>
			
				<cfif not len(session.user_authorized) and structKeyExists(url, "state")>
				
					<cfif structKeyExists(url, "error")>
					
						<h2>Error</h2>
						<h3><cfoutput>#url.error#</cfoutput></h3>
						<h3><cfoutput>#url.error_description#</cfoutput></h3>
					
					<cfelseif url.state eq session.linkedin.csrf_validation_token>
						
						<cfset session.linkedin.code = url.code>
						
						<cfset RequestAccessTokenResult = RequestAccessToken()>
						
						<cfif structKeyExists(RequestAccessTokenResult, "access_token")>
						
							<cfset session.linkedin.access_token = RequestAccessTokenResult.access_token>
							
							<cfset session.user_authorized = true>
							
							<cflocation url="http://#cgi.server_name#/egrimm/testing/apis/linkedin.cfm" addtoken="no">
							
						<cfelse>
						
							<cfset session.user_authorized = false>
							
							<h2>USER NOT AUTHORIZED, NEED TO BETTER HANDLE THIS CONDITION</h2>
						
						</cfif>
						
					<cfelse>
					
						<h2>CSRF ATTEMPT</h2>
						
					</cfif>
				
				<cfelse>
				
					<h2>USER AUTHORIZED, CALLING API METHODS</h2>
					
					<cfhttp url="https://api.linkedin.com/v1/people/~" method="GET" charset="utf-8" result="getProfile">
						<cfhttpparam name="oauth2_access_token" value="#session.linkedin.access_token#" type="url">
					</cfhttp>
					<!--- <cfdump var="#getProfile#"> --->
					<!--- returns xml --->
					<cfset userProfile = xmlParse(getProfile.Filecontent)>
					<cfdump var="#userProfile#">
					
					<cfhttp url="https://api.linkedin.com/v1/people/~/email-address" method="GET" charset="utf-8" result="getEmailAddress">
						<cfhttpparam name="oauth2_access_token" value="#session.linkedin.access_token#" type="url">
					</cfhttp>
					<!--- <cfdump var="#getEmailAddress#"> --->
					<!--- returns xml --->
					<cfset userEmail = xmlParse(getEmailAddress.Filecontent)>
					<cfdump var="#userEmail#">
					
					<cfhttp url="https://api.linkedin.com/v1/people/~/connections" method="GET" charset="utf-8" result="getConnections">
						<cfhttpparam name="oauth2_access_token" value="#session.linkedin.access_token#" type="url">
					</cfhttp>
					<!--- <cfdump var="#getConnections#"> --->
					<!--- returns xml --->
					<cfset userConnections = xmlParse(getConnections.Filecontent)>
					<cfdump var="#userConnections#"><!---  --->
					
					<form class="form-horizontal">
						
						<div class="form-group">
							<label for="firstName" class="col-lg-2 control-label">First Name</label>
							<div class="col-lg-6">
								<input type="text" name="firstName" class="form-control" value="<cfoutput>#HTMLEditFormat(userProfile.person['first-name'].XmlText)#</cfoutput>">
							</div>
						</div>
						
						<div class="form-group">
							<label for="lastName" class="col-lg-2 control-label">Last Name</label>
							<div class="col-lg-6">
								<input type="text" name="lastName" class="form-control" value="<cfoutput>#HTMLEditFormat(userProfile.person['last-name'].XmlText)#</cfoutput>">
							</div>
						</div>
						
						<div class="form-group">
							<label for="emailAddress" class="col-lg-2 control-label">Email</label>
							<div class="col-lg-6">
								<input type="text" name="emailAddress" class="form-control" value="<cfoutput>#HTMLEditFormat(userEmail['email-address'].XmlText)#</cfoutput>">
							</div>
						</div>
						
						<cfoutput>#userConnections.connections.person[12]['first-name'].XmlText#</cfoutput>
						
					</form>
				
				</cfif>
				
			</cfif>
			
		</div>
	
		<!--- Placed at the end of the document so the pages load faster --->
		<!--- <script src="//netdna.bootstrapcdn.com/bootstrap/3.0.0-rc1/js/bootstrap.min.js"></script> --->
		<script src="//promotions.mardenkane.com/common/bootstrap3/js/bootstrap.min.js"></script>

  </body>
</html>

<cffunction name="GenerateAuthorizationCode">
	<!--- a. Generate Authorization Code by redirecting user to LinkedIn's authorization dialog --->
	<cflocation url="https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=#session.linkedin.api_key#&scope=r_fullprofile%20r_emailaddress%20r_network&state=#session.linkedin.csrf_validation_token#&redirect_uri=http://#cgi.server_name#/egrimm/testing/apis/linkedin.cfm" addtoken="no">
</cffunction>

<cffunction name="RequestAccessToken" output="yes" returntype="any">
	<!--- b. Request Access Token by exchanging the authorization_code for it --->
	<cfhttp url="https://www.linkedin.com/uas/oauth2/accessToken" method="POST" charset="utf-8">
		<cfhttpparam name="grant_type" value="authorization_code" type="formfield">
		<cfhttpparam name="code" value="#session.linkedin.code#" type="formfield">
		<cfhttpparam name="redirect_uri" value="http://#cgi.server_name#/egrimm/testing/apis/linkedin.cfm" type="formfield">
		<cfhttpparam name="client_id" value="#session.linkedin.api_key#" type="formfield">
		<cfhttpparam name="client_secret" value="#session.linkedin.secret_key#" type="formfield">
	</cfhttp>
	<cfset results = deserializejson(cfhttp.filecontent)>
	<cfreturn results>
</cffunction>
