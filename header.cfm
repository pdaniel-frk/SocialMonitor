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
		<!--- <link href="//promotions.mardenkane.com/common/bootstrap3/css/bootstrap.min.css" rel="stylesheet"> --->
		<!-- Latest compiled and minified CSS -->
		<link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css">
		<!-- Optional theme -->
		<link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap-theme.min.css">

		<!--- Site-specific CSS --->
		<link href="<cfoutput>#request.webRoot#styles/dashboard.css</cfoutput>" rel="stylesheet">
		
		<!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
		<!--[if lt IE 9]>
			<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
			<script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
		<![endif]-->
		
		<!--- jQuery --->
		<script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
		<script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js"></script>
		<link rel="stylesheet" href="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/themes/start/jquery-ui.min.css" />
	
	</head>
	
	<body>
	
		<div style="min-width:960px;">
	
			<cfinclude template="menu.cfm">
			
			<div class="container-fluid">
				
				<div class="row">
					
					<cfinclude template="sidebar.cfm">
					
					<div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">
					
				
