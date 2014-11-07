<cfparam name="form.searchTerm" default="">

<h1 class="page-header">
	Foursquare
	<span class="pull-right">
		<button class="btn btn-success btn-sm monitor-foursquare-term-button" data-scheduleid="" data-searchterm="" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor new search term">
			<span class="glyphicon glyphicon-plus"></span>
		</button>
		<a href="schedules.cfm?service=Foursquare"><button class="btn btn-sm btn-warning">Monitored</button></a>
	</span>
</h1>

<div class="panel panel-primary">

	<div class="panel-heading">
		<p class="panel-title"><strong>Search</strong></p>
	</div>

	<div class="panel-body">
		<form name="lookup-term" method="post">
			<div class="form-group">
				<label for="searchTerm">Search Term</label>
				<input type="text" class="form-control" id="searchTerm" name="searchTerm" placeholder="This is not presently working, just returning a 'Name in certificate `*.a.ssl.fastly.net` does not match host name `api.foursquare.com`' error." value="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>">
			</div>
			<button type="submit" class="btn btn-default">Submit</button>
			<cfif len(form.searchTerm)>
				<button class="btn btn-success btn-xs monitor-foursquare-term-button" data-scheduleid="" data-searchterm="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor this term">
					<span class="glyphicon glyphicon-eye-open"></span>
				</button>
			</cfif>
		</form>
	</div>

</div>

<cfif len(form.searchTerm)>

	<cfhttp method="get" url="https://api.foursquare.com/v2/venues/search">
		<cfhttpparam type="url" name="client_id" value="#credentials.foursquare.clientId#">
		<cfhttpparam type="url" name="client_secret" value="#credentials.foursquare.clientSecret#">
		<cfhttpparam type="url" name="v" value="#dateFormat(now(), 'yyyymmdd')#">
		<cfhttpparam type="url" name="intent" value="global">
		<cfhttpparam type="url" name="query" value="#form.searchTerm#">
	</cfhttp>
	<!--- I/O Exception: Name in certificate `*.a.ssl.fastly.net' does not match host name `api.foursquare.com' --->
	<!--- <cfdump var="#cfhttp#"> --->
	<!--- <cfdump var="#cfhttp.fileContent#"> --->
	<cfset result = deserializeJson(cfhttp.fileContent)>
	<cfdump var="#result#">

	<!--- get photos from javits venue (4283ee00f964a5209d221fe3) --->
	<cfhttp method="get" url="https://api.foursquare.com/v2/venues/4283ee00f964a5209d221fe3/photos">
		<cfhttpparam type="url" name="client_id" value="#credentials.foursquare.clientId#">
		<cfhttpparam type="url" name="client_secret" value="#credentials.foursquare.clientSecret#">
		<cfhttpparam type="url" name="v" value="#dateFormat(now(), 'yyyymmdd')#">
	</cfhttp>
	<cfset result = deserializeJson(cfhttp.fileContent)>

</cfif>




<cfset onRequestEnd(cgi.script_name)>
<cfabort>

<cfapplication name="foursquaretesting" sessionmanagement="yes" sessiontimeout="#createtimespan(0,0,20,0)#">
<cfset credentials.foursquare = {
	application_name = "test-app",
	clientId = "4CJEN0M1KKJC5QCRYHP0OVGFYZLUC4150E4VTGOYFPIDGNOF",
	clientSecret = "OZRTMB5HLP1FAQHYULT5GONNO3ZG05CMN0SFHKJVWK2LQ0ZM"
}>

<!--- get herenow from times square venue (49b7ed6df964a52030531fe3) --->
<!--- <cfhttp method="get" url="http://api.foursquare.com/v2/venues/49b7ed6df964a52030531fe3/herenow">
						<cfhttpparam type="url" name="client_id" value="#credentials.foursquare.clientId#">
						<cfhttpparam type="url" name="client_secret" value="#credentials.foursquare.clientSecret#">
						<cfhttpparam type="url" name="v" value="#dateFormat(now(), 'yyyymmdd')#">
					</cfhttp>
					<cfdump var="#cfhttp#">
					<cfdump var="#cfhttp.fileContent#">
					<cfset result = deserializeJson(cfhttp.fileContent)>

					<cfabort> --->


<!--- get photos from times square venue (49b7ed6df964a52030531fe3) --->
					<cfhttp method="get" url="http://api.foursquare.com/v2/venues/49b7ed6df964a52030531fe3/photos">
						<cfhttpparam type="url" name="client_id" value="#credentials.foursquare.clientId#">
						<cfhttpparam type="url" name="client_secret" value="#credentials.foursquare.clientSecret#">
						<cfhttpparam type="url" name="v" value="#dateFormat(now(), 'yyyymmdd')#">
					</cfhttp>
					<cfset result = deserializeJson(cfhttp.fileContent)>

					<cfdump var="#result#"><!---  --->
					<cfloop from="1" to="#result.response.photos.count#" index="ndx">
						<p><cfoutput>#result.response.photos.items[ndx].prefix#original#result.response.photos.items[ndx].suffix#</cfoutput></p>
						<p><img src="<cfoutput>#result.response.photos.items[ndx].prefix#original#result.response.photos.items[ndx].suffix#</cfoutput>"></p>
					</cfloop>

					<cfabort>
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title>Foursquare API Testing</title>
		<meta name="description" content="">
		<meta name="author" content="">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

		<!--- <link href="//netdna.bootstrapcdn.com/bootstrap/3.0.0-rc1/css/bootstrap.min.css" rel="stylesheet"> ---><!--- this seems to be missing some style declarations --->
		<link href="//promotions.mardenkane.com/common/bootstrap3/css/bootstrap.min.css" rel="stylesheet">

		<!--[if IE]>
			<script src="//html5shiv.googlecode.com/svn/trunk/html5.js"></script>
		<![endif]-->
		<script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>

	</head>

	<body>

		<div class="container">

			<cfinclude template="nav.cfm">

			<div class="jumbotron">
				<h1>Foursquare API Testing</h1>
				<p class="text-muted">Also consider looking into enabling push notifications for apps, and set up an app to monitor each venue, and ??? and profit</p>
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

			<cfif structKeyExists(form, "searchKey")>
				<cfif structKeyExists(form, "searchTerm") and len(form.searchTerm)>
					<!--- https://api.foursquare.com/v2/venues/search
									?intent=global
									&client_id=4CJEN0M1KKJC5QCRYHP0OVGFYZLUC4150E4VTGOYFPIDGNOF
									&client_secret=OZRTMB5HLP1FAQHYULT5GONNO3ZG05CMN0SFHKJVWK2LQ0ZM
									&query=nycc
									&v=20130815 --->

					<!--- ?client_id=4CJEN0M1KKJC5QCRYHP0OVGFYZLUC4150E4VTGOYFPIDGNOF&client_secret=OZRTMB5HLP1FAQHYULT5GONNO3ZG05CMN0SFHKJVWK2LQ0ZM&v=20130815 --->

					<!--- using https throws the following error: I/O Exception: Name in certificate `*.a.ssl.fastly.net' does not match host name `api.foursquare.com'  --->
					<cfhttp method="get" url="http://api.foursquare.com/v2/venues/search">
						<cfhttpparam type="url" name="client_id" value="#credentials.foursquare.clientId#">
						<cfhttpparam type="url" name="client_secret" value="#credentials.foursquare.clientSecret#">
						<cfhttpparam type="url" name="v" value="#dateFormat(now(), 'yyyymmdd')#">
						<cfhttpparam type="url" name="intent" value="global">
						<cfhttpparam type="url" name="query" value="#form.searchTerm#">
					</cfhttp>
					<!--- <cfdump var="#cfhttp#"> --->
					<!--- <cfdump var="#cfhttp.fileContent#"> --->
					<cfset result = deserializeJson(cfhttp.fileContent)>
					<cfdump var="#result#">


					<!--- get photos from pc richard venue (4bc4b97aabf495219077c593) --->
					<!--- get photos from times square venue (49b7ed6df964a52030531fe3) --->
					<cfhttp method="get" url="http://api.foursquare.com/v2/venues/49b7ed6df964a52030531fe3/photos">
						<cfhttpparam type="url" name="client_id" value="#credentials.foursquare.clientId#">
						<cfhttpparam type="url" name="client_secret" value="#credentials.foursquare.clientSecret#">
						<cfhttpparam type="url" name="v" value="#dateFormat(now(), 'yyyymmdd')#">
					</cfhttp>
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
