<h1 class="page-header">Pinterest</h1>
<h2>Coming Soon!</h2>
<cfset onRequestEnd(cgi.script_name)>
<cfabort>

<cfapplication name="pinteresttesting" sessionmanagement="yes" sessiontimeout="#createtimespan(0,0,20,0)#">

<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title>Pinterest API Testing</title>
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
				<h1>Pinterest API Testing</h1>
				<h2>Coming Soon? There is currently (10.14.2013) no official API, but that won't stop us trying.</h2>
			</div>
			
			<div class="col-md-8 col-md-offset-2">
				<p>Endpoint? https://api.pinterest.com/v3</p>
				<p>Stackoverflow link: http://stackoverflow.com/questions/9951045/pinterest-api-documentation</p>
			</div>
			
		</div>
	


		<!--- Placed at the end of the document so the pages load faster --->
		<!--- <script src="//netdna.bootstrapcdn.com/bootstrap/3.0.0-rc1/js/bootstrap.min.js"></script> --->
		<script src="//promotions.mardenkane.com/common/bootstrap3/js/bootstrap.min.js"></script>

  </body>
</html>
