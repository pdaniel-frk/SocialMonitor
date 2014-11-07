<cfparam name="form.searchTerm" default="">

<h1 class="page-header">
	Tumblr
	<span class="pull-right">
		<button class="btn btn-success btn-sm monitor-tumblr-term-button" data-scheduleid="" data-searchterm="" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor new search term">
			<span class="glyphicon glyphicon-plus"></span>
		</button>
		<a href="schedules.cfm?service=tumblr"><button class="btn btn-sm btn-warning">Monitored</button></a>
	</span>
</h1>

<div class="panel panel-primary">

	<div class="panel-heading">
		<p class="panel-title"><strong>Search</strong></p>
	</div>

	<div class="panel-body">
		<form name="lookup-page" method="post">
			<div class="form-group">
				<label for="searchTerm">Search Term</label>
				<input type="text" class="form-control" id="searchTerm" name="searchTerm" placeholder="" value="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>">
			</div>
			<button type="submit" class="btn btn-default">Submit</button>
			<cfif len(form.searchTerm)>
				<button class="btn btn-success btn-xs monitor-tumblr-term-button" data-scheduleid="" data-searchterm="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor this term">
					<span class="glyphicon glyphicon-eye-open"></span>
				</button>
			</cfif>
		</form>
	</div>

</div>

<cfif len(form.searchTerm)>

	<cfhttp method="get" url="http://api.tumblr.com/v2/tagged">
		<cfhttpparam type="url" name="api_key" value="#credentials.tumblr.oauth_consumer_key#">
		<cfhttpparam type="url" name="tag" value="#form.searchTerm#">
	</cfhttp>

	<!--- <cfdump var="#cfhttp#"> --->
	<!--- <cfdump var="#cfhttp.fileContent#"> --->
	<cfset result = deserializeJson(cfhttp.fileContent)>

	<cfloop from="1" to="#arrayLen(result.response)#" index="ndx">
		<cfset thisResponse = structGet('result.response[#ndx#]')>
		<cfdump var="#thisResponse#">
		<!--- get blog info --->
		<cfhttp method="get" url="http://api.tumblr.com/v2/blog/#thisResponse.blog_name#.tumblr.com/info" redirect="no">
			<cfhttpparam type="url" name="api_key" value="#credentials.tumblr.oauth_consumer_key#">
		</cfhttp>
		<cfset blogResult = deserializeJson(cfhttp.fileContent)>
		<cfdump var="#blogResult.response.blog#">
	</cfloop>
</cfif>



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
