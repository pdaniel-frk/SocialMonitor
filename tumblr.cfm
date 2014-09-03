<h1 class="page-header">Tumblr</h1>
<h2>Coming Soon!</h2>
<cfset onRequestEnd(cgi.script_name)>
<cfabort>

<cfapplication name="tumblrtesting" sessionmanagement="yes" sessiontimeout="#createtimespan(0,0,20,0)#">
<cfset credentials.tumblr = {
	application_name = "test-app",
	oauth_consumer_key = "HOnAUNkF31ztWI3EkJksX6YJWIsqqRfYPvsE2otvfsHukaDmtF",
	secret_key = "jO2KPnKKRZVU35EUtr8ikixIppsYKj9rYzJC304tFkl2eJIDCd"	
}>
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title>Tumblr API Testing</title>
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
	
	<body>
		
		<div class="container">

			<cfinclude template="nav.cfm">

			<div class="jumbotron">
				<h1>Tumblr API Testing</h1>
			</div>
			
			<div class="col-md-8 col-md-offset-2">
				
				<form class="form-inline" method="post">
					
					<div class="input-group">
						<input type="text" class="form-control" name="searchTerm" id="searchTerm">
						<span class="input-group-btn">
							<button type="submit" class="btn btn-primary">Search</button>
						</span>
					</div>
				
					<input type="hidden" name="searchKey" value="<cfoutput>#hash(getTickCount(), 'SHA-1')#</cfoutput>">
				</form>
				
			</div>
			
			<div class="col-md-8 col-md-offset-2">
				<h2>Test getting blog info for 'programmerkane'</h2>
				<cfhttp method="get" url="http://api.tumblr.com/v2/blog/programmerkane.tumblr.com/info?api_key=#credentials.tumblr.oauth_consumer_key#"></cfhttp>
				<cfset result = deserializeJson(cfhttp.fileContent)>
				<cfdump var="#result#">
			</div>
			
			<cfif structKeyExists(form, "searchKey")>
				<cfif structKeyExists(form, "searchTerm") and len(form.searchTerm)>
					<cfhttp method="get" url="http://api.tumblr.com/v2/tagged?api_key=#credentials.tumblr.oauth_consumer_key#&tag=#form.searchTerm#"></cfhttp>
					<!--- <cfdump var="#cfhttp#"> --->
					<!--- <cfdump var="#cfhttp.fileContent#"> --->
					<cfset result = deserializeJson(cfhttp.fileContent)>
					<cfdump var="#result#">
				</cfif>
			</cfif>
			
		</div>
	


		<!--- Placed at the end of the document so the pages load faster --->
		<!--- <script src="//netdna.bootstrapcdn.com/bootstrap/3.0.0-rc1/js/bootstrap.min.js"></script> --->
		<script src="//promotions.mardenkane.com/common/bootstrap3/js/bootstrap.min.js"></script>

  </body>
</html>
