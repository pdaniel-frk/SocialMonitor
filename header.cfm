<!--- NEW SITE LAYOUT BASED ON http://getbootstrap.com/examples/dashboard/ --->
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title><cfoutput>#this.title#</cfoutput></title>
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<meta name="description" content="">
		<meta name="author" content="">

		<!--- Bootstrap --->
		<!--- Latest compiled and minified CSS --->
		<link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css">
		<!--- Optional theme --->
		<link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap-theme.min.css">

		<!--- Site-specific CSS --->
		<link href="<cfoutput>#request.webRoot#</cfoutput>styles/dashboard.css" rel="stylesheet">

		<!--- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries --->
		<!--[if lt IE 9]>
			<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
			<script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
		<![endif]-->

		<!--- jQuery+jqueryui --->
		<!--[if lt IE 9]>
		    <script src="//oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
			<script src="//oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
		    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.0/jquery.min.js"></script>
		<![endif]-->
		<!--[if gte IE 9]><!-->
		    <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
		<!--<![endif]-->
		<script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.11.0/jquery-ui.min.js"></script>
		<script src="<cfoutput>#request.webRoot#</cfoutput>scripts/jquery.sparkline.min.js"></script>
		<link rel="stylesheet" href="//ajax.googleapis.com/ajax/libs/jqueryui/1.11.0/themes/start/jquery-ui.min.css" />

	</head>

	<body>

		<div style="min-width:960px;">

			<cfinclude template="menu.cfm">

			<div class="container-fluid">

				<div class="row">

					<cfinclude template="sidebar.cfm">

					<div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">


