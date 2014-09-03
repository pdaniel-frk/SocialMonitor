<cfparam name="form.searchTerm" default="">

<h1 class="page-header">
	Twitter
	<span class="pull-right">
		<button class="btn btn-success btn-small monitor-twitter-term-button" data-scheduleid="" data-searchterm="" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor new search term">
			<span class="glyphicon glyphicon-eye-open"></span>
		</button>
		<a href="twitter_monitored.cfm"><button class="btn btn-sm btn-warning">Monitored</button></a>
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
				<input type="text" class="form-control" id="searchTerm" name="searchTerm" placeholder="Multiple terms are supported, separated by spaces" value="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>">
			</div>
			<button type="submit" class="btn btn-default">Submit</button>
			<cfif len(form.searchTerm)>
				<button class="btn btn-success btn-small monitor-twitter-term-button" data-scheduleid="" data-searchterm="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor this term">
					<span class="glyphicon glyphicon-eye-open"></span>
				</button>
			</cfif>
		</form>
	</div>
	
</div>

<cfif len(form.searchTerm)>
	
	<cfset form.searchTerm = replace(form.searchTerm, ' ', '+AND+', 'ALL')>
	
	<cfset q = URLEncodedFormat(form.searchTerm)>
	<cfset since_id = "">
	
	<cftry>
				
		<cfset searchResult =  application.objMonkehTweet.search(q=q, since_id=since_id, count=100)>
		
		<cfset searchCount = 0>
						
		<cfset searchCount += arrayLen(searchResult.statuses)>
		
		<div class="table-responsive">
			<table class="table table-striped" id="lookup-results-table">
				<caption id="lookup-results-count"></caption>
				<thead>
					<tr>
						<th>#</th>
						<th>Created</th>
						<th>Handle</th>
						<th>Text</th>
					</tr>
				</thead>
				<tbody>
		
					<cfloop from="1" to="#arrayLen(searchResult.statuses)#" index="ndx">
						
						<tr>
							<td><cfoutput>#ndx#</cfoutput></td>
							<td><cfoutput>#searchResult.statuses[ndx].created_at#</cfoutput></td>
							<td><cfoutput>#searchResult.statuses[ndx].user.screen_name#</cfoutput></td>
							<td><cfoutput>#searchResult.statuses[ndx].text#</cfoutput></td>
						</tr>
							
						<cftry>
						
							<cfcatch type="any">
								<cfdump var="#cfcatch#">
								<cfdump var="#searchResult.statuses[ndx]#">
								<cfabort>
							</cfcatch>
						
						</cftry>							
					</cfloop>
					
				</tbody>
				
			</table>
			
		</div>
		
		<cfcatch type="any">
			<cfdump var="#cfcatch#">
		</cfcatch>
		
	</cftry>
	
</cfif>



<cfset onRequestEnd(cgi.script_name)>
<cfabort>

<cfapplication name="twittertesting" sessionmanagement="yes" sessiontimeout="#createtimespan(0,0,20,0)#">
<cfset requestTimeout = 999>

<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title>Twitter API Testing</title>
		<meta name="description" content="">
		<meta name="author" content="">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
		
		<link href="//promotions.mardenkane.com/common/bootstrap3/css/bootstrap.min.css" rel="stylesheet">
		
		<!--[if IE]>
			<script src="//html5shiv.googlecode.com/svn/trunk/html5.js"></script>
		<![endif]-->
		
		<script src="//ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min.js"></script>
	
	</head>
	
	<cfif not isDefined("session.twitter") or structKeyExists(url, "restart")>
		
		<cfset session.twitter = {}>
		<cfset session.twitter.application_name = "egrimm-api-test">
		<cfset session.twitter.consumer_key = "d9TRqFxJcHUvCrvTtPKzA">
		<cfset session.twitter.consumer_secret = "mbsi5SFV3Djbhx7E11JLwvSqOgLEvymacXTmQotEBc">
		<cfset session.twitter.access_token = "272471143-1Hyn29JWu1WqmbJOshJtt3OUb0IaO5gi45j0vybh">
		<cfset session.twitter.access_token_secret = "y8AUqRj5k9iUZEjZP774izHKuYcnnPn9Z4bPUny12O0">
		<cfset session.twitter.request_token_url = "https://api.twitter.com/oauth/request_token">
		<cfset session.twitter.authorize_url = "https://api.twitter.com/oauth/authorize">
		<cfset session.twitter.access_token_url = "https://api.twitter.com/oauth/access_token">
		<cfset session.twitter.callback_url = "http://#cgi.server_name#/egrimm/testing/apis/twitter.cfm">
		
		<cfset session.twitter.user_authorized = "">
		<cfset session.twitter.user_denied_token = "">
		<cfset session.twitter.user_authorized_oauth_token = "">
		<cfset session.twitter.user_authorized_oauth_verifier = "">
		
		<cfset session.twitter.user.accessToken = "">
		<cfset session.twitter.user.accessSecret = "">
		<cfset session.twitter.user.screen_name = "">
		<cfset session.twitter.user.user_id = "">
		
	</cfif>
	
	<body>
		
		<div class="container">
			
			<cfinclude template="nav.cfm">
		
			<div class="jumbotron">
				<h1>Twitter API Testing</h1>
				<h2><a href="?restart=true">Start Over</a></h2>
				<h2><cfoutput>#now()#</cfoutput></h2>
			</div>
			
			
			<div class="row">
				<div class="col-sm-8 col-sm-offset-2">
					
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
			</div>
			
			
			<!--- <cfhttp url="https://api.twitter.com/oauth/request_token?oauth_callback=http%3A%2F%2Fmk02%2Fegrimm%2Ftesting%2Fapis%2Ftwitter.cfm&oauth_consumer_key=d9TRqFxJcHUvCrvTtPKzA&oauth_nonce=4B962B98589B2B68D9DFBD490843A3EC19AF883B&oauth_signature=j%2FfPjgeHySQk%2BIu04d3GduwqPUU%3D&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1386971920&oauth_version=1.0" method="get" result="test">
			<cfdump var="#test#"> --->
			
			<!--- <h1>Testing VeriSign Certs</h1>
			<h2>Root 1 VeriSign Class 3 Public Primary CA - G2</h2>
			<cfhttp url="https://ssltest24.bbtest.net" method="get" result="root1"/>
			<cfdump var="#root1.statusCode#">

			<h2>Root 2 VeriSign Class 3 Public Primary CA</h2>
			<cfhttp url="https://ssltest23.bbtest.net" method="get" result="root2"/>
			<cfdump var="#root2.statusCode#">
			
			<h2>Root 3 VeriSign Class 3 Primary CA - G5</h2>
			<cfhttp url="https://ssltest2.bbtest.net" method="get" result="root3"/>
			<cfdump var="#root3.statusCode#">
			
			<h2>Root 4 VeriSign Class 3 Public Primary CA - G3</h2>
			<cfhttp url="https://ssltest1.bbtest.net" method="get" result="root4"/>
			<cfdump var="#root4.statusCode#">
			
			<h2>Root 10 VeriSign Universal Root CA </h2>
			<cfhttp url="https://ssltest26.bbtest.net" method="get" result="root10"/>
			<cfdump var="#root10.statusCode#">
			
			
			<cfabort> --->
	
	
			<!--- <div class="row">
				<h1>Starting from scratch and working step-by-step</h1>
				<h2>Instantiating API</h2>
				<cfdump var="#session.twitter#" label="session.twitter values">
				<cfset objMonkehTweet = createObject("component", "baseComponents.monkehTweet.monkehTweet").init(
										consumerKey = session.twitter.consumer_key,
										consumerSecret = session.twitter.consumer_secret,
										parseResults = true
									)>
				<cfdump var="#objMonkehTweet#" label="objMonkehTweet">
				<h2>Attempting authorization</h2>
				<cfscript>
					authStruct = objMonkehTweet.getAuthorisation(callbackURL=session.twitter.callback_url);
				</cfscript>
				<cfdump var="#authStruct#" label="authStruct">
				<h2>This is failing with "Connection Failure" message.</h2>
				<!--- <cfset oauthtest = createobject("component", "basecomponents.monkehtweet.oauth.oauthdatastore")> --->
				
			</div>
			
			
			<cfabort> --->
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			<!--- <div class="row">
				
				<h1>Using cfhttp only</h1>
				<h2>Search?</h2>
				<cfhttp url="https://api.twitter.com/1.1/search/tweets.json" method="get">
					<cfhttpparam type="header" name="oauth_consumer_key" value="#session.twitter.consumer_key#">
				    <cfhttpparam type="header" name="oauth_nonce" value="8e1074f0799227454845c374859eed3f">
				    <cfhttpparam type="header" name="oauth_signature" value="2Ed0Ik2vNTgoagPwq6vfExnUa1Q%3D">
				    <cfhttpparam type="header" name="oauth_signature_method" value="HMAC-SHA1">
				    <cfhttpparam type="header" name="oauth_token" value="#session.twitter.access_token#">
				    <cfhttpparam type="header" name="oauth_timestamp" value="1386772572">
				    <cfhttpparam type="header" name="oauth_version" value="1.0">
	
					<cfhttpparam type="url" name="q" value="freebandnames">
					<cfhttpparam type="url" name="count" value="4">
					<cfhttpparam type="url" name="since_id" value="24012619984051000">
					<cfhttpparam type="url" name="max_id" value="250126199840518145">
				</cfhttp>
				
				<cfdump var="#cfhttp#">
				<cfabort>
				
			</div> --->
			
			
			
			<!--- instantiate monkehTweet if not already --->
			<cfif not structKeyExists(application, "objMonkehTweet") or structKeyExists(url, "restart")>
				
				<div class="row">
					
					<h1>Instantiate API</h1>
					
					<cftry>
						
						<cfset application.objMonkehTweet = createObject("component", "baseComponents.monkehTweet.monkehTweet").init(
										consumerKey = session.twitter.consumer_key,
										consumerSecret = session.twitter.consumer_secret,
										oauthToken =  session.twitter.access_token,
										oauthTokenSecret =  session.twitter.access_token_secret,
										parseResults = true
									)>
						
						<div class="alert alert-success alert-dismissable">
							<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
							<strong>Success!</strong>
							<cfdump var="#application.objMonkehTweet#">
							<cfdump var="#application.objMonkehTweet.getapiURL()#">
							<!--- <cfdump var="#application.objMonkehTweet.getAuthDetails()#">
							<cfdump var="#application.objMonkehTweet.getBaseURL()#">
							<cfdump var="#application.objMonkehTweet.getapiURL()#">
							<cfdump var="#application.objMonkehTweet.verifyCredentials()#">
							<cfabort> --->
						</div>
						
						<cfcatch type="any">
							<div class="alert alert-danger alert-dismissable">
								<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
								<strong>Error!</strong>
								<cfdump var="#cfcatch#">
							</div>
						</cfcatch>
						
					</cftry>
					
				</div>
				
			</cfif>
			
			
			
			<cfif structKeyExists(form, "searchKey")>
			
				<p><cfoutput>form.searchTerm: #form.searchTerm#</cfoutput></p>
			
				<cfset status = application.objMonkehTweet.getStatusByID(id='#form.searchTerm#')>
				<cfdump var="#status#">
				
				<cfset retweets = application.objMonkehTweet.getRetweets(id='#form.searchTerm#')>
				<cfdump var="#retweets#">
				<cfabort>
				
				<cfif structKeyExists(form, "searchTerm") and len(form.searchTerm)>
					
					<cfloop from="1" to="25" index="ff">
					
						<cfquery name="get_max_id" datasource="SonyPictureYourselfSweepstakes">
							select min(Id) as max_id from twitterentries where [text] like '%##esurancesave30%'
						</cfquery>
						<cfset max_id = get_max_id.max_id>
					
						<cfset searchResult = application.objMonkehTweet.search(q=form.searchTerm, count=100)>
						
						<cfif ff eq 1>
							<!--- <cfdump var="#searchResult#"> --->
						</cfif>
						
						<!--- <cfdump var="#searchResult.search_metadata#"> --->
						<p><cfoutput>#searchResult.statuses[1].created_at#</cfoutput></p>
						
						<!--- <cfif isDefined('searchResult.search_metadata.next_results')>
							<cfset next_results = searchResult.search_metadata.next_results>
							<!--- ?max_id=430145243367739392&q=%23esurancesave30&count=100&include_entities=1&result_type=mixed --->
							<cfset max_id = right(next_results, len(next_results)-1)>
							<cfset max_id = getToken(max_id, 1, '&')>
							<cfset max_id = getToken(max_id, 2, '=')>
							<p><cfoutput>next_results: #next_results#</cfoutput></p>
							<p><cfoutput>max_id: #max_id#</cfoutput></p>
						</cfif> --->
						
						<!--- <cfdump var="#searchResult.statuses[1]#"> --->
						
						<cfloop from="1" to="#arrayLen(searchResult.statuses)#" index="ndx">
							
							<cftry>
						
								<!--- lets try an insert --->
								<cfquery datasource="SonyPictureYourselfSweepstakes">
									if not exists
									(
										select 1
										from TwitterEntries
										where Id = <cfqueryparam value="#searchResult.statuses[ndx].id#" cfsqltype="cf_sql_bigint">
										or id_str = <cfqueryparam value="#searchResult.statuses[ndx].id_str#" cfsqltype="cf_sql_varchar">
									)
									begin
										insert into TwitterEntries
										(
											[Id],
											[SearchTermId],
											[id_str],
											[created_at],
											[geo.coordinates.latitude],
											[geo.coordinates.longitude],
											[geo.coordinates.type],
											[lang],
											[text],
											[user.id],
											[user.id_str],
											[user.location],
											[user.name],
											[user.screen_name],
											[user.url]
										)
										values
										(
											<cfqueryparam value="#searchResult.statuses[ndx].Id#" cfsqltype="cf_sql_bigint">,
											1,
											<cfqueryparam value="#searchResult.statuses[ndx].id_str#" cfsqltype="cf_sql_varchar">,
											<cfqueryparam value="#searchResult.statuses[ndx].created_at#" cfsqltype="cf_sql_varchar">,
											<cfif isStruct(searchResult.statuses[ndx].geo)>
												<cfqueryparam value="#searchResult.statuses[ndx].geo.coordinates[1]#" cfsqltype="cf_sql_float">,
												<cfqueryparam value="#searchResult.statuses[ndx].geo.coordinates[2]#" cfsqltype="cf_sql_float">,
												<cfqueryparam value="#searchResult.statuses[ndx].geo.type#" cfsqltype="cf_sql_varchar">,
											<cfelse>
												null,
												null,
												null,
											</cfif>
											<cfqueryparam value="#searchResult.statuses[ndx].lang#" cfsqltype="cf_sql_varchar">,
											<cfqueryparam value="#searchResult.statuses[ndx].text#" cfsqltype="cf_sql_varchar">,
											<cfqueryparam value="#searchResult.statuses[ndx].user.id#" cfsqltype="cf_sql_bigint">,
											<cfqueryparam value="#searchResult.statuses[ndx].user.id_str#" cfsqltype="cf_sql_varchar">,
											<cfqueryparam value="#searchResult.statuses[ndx].user.location#" cfsqltype="cf_sql_varchar">,
											<cfqueryparam value="#searchResult.statuses[ndx].user.name#" cfsqltype="cf_sql_varchar">,
											<cfqueryparam value="#searchResult.statuses[ndx].user.screen_name#" cfsqltype="cf_sql_varchar">,
											<cfqueryparam value="#searchResult.statuses[ndx].user.url#" cfsqltype="cf_sql_varchar">
										)
									end
								</cfquery>
								
								<cfcatch type="any">
									<cfdump var="#cfcatch#">
									<cfdump var="#searchResult.statuses[ndx]#">
									<cfabort>
								</cfcatch>
							
							</cftry>
						
						</cfloop>
						
					</cfloop>
					
				</cfif>
			</cfif>
			
			
			<!--- check for callback url params --->
			<cfif structKeyExists(url, "denied")>
				<cflock scope="session" timeout="4" throwontimeout="no">
					<cfset session.twitter.user_authorized = false>
					<cfset session.twitter.user_denied_token = url.denied>
				</cflock>
			</cfif>
			
			<cfif structKeyExists(url, "oauth_token") and structKeyExists(url, "oauth_verifier")>
				<cflock scope="session" timeout="4" throwontimeout="no">
					<cfset session.twitter.user_authorized = true>
					<!--- store these credentials in the data-b for user postering later --->
					<cfset session.twitter.user_authorized_oauth_token = url.oauth_token>
					<cfset session.twitter.user_authorized_oauth_verifier = url.oauth_verifier>
				</cflock>
			</cfif>
			
			<!--- request user authorization if not already --->
			<cfif not len(session.twitter.user_authorized)>
			
				<div class="row">
					
					<cftry>
					
						<cfscript>
							/*
								Firstly we need to have the user grant access to our application.
								We do this (using OAuth) through the getAuthorisation() method.
								The callbackURL is optional. If not sent through, Twitter will use the callback URL it has stored for your application.
							*/
							authStruct = application.objMonkehTweet.getAuthorisation(callbackURL=session.twitter.callback_url);
							
							if (authStruct.success){
								//	Here, the returned information is being set into the session scope.
								//	You could also store these into a DB (if running an application for multiple users)
								session.twitter.access_token			= authStruct.token;
								session.twitter.access_token_secret	= authStruct.token_secret;
							}
						</cfscript>
						
						<div class="alert alert-success alert-dismissable">
							<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
							<strong>Success!</strong>
							<cfdump var="#authStruct#" label="getAuthorisation">
							
							<!--- Now, we need to relocate the user to Twitter to perform the authorisation for us --->
							<!--- <cflocation url="#authStruct.authURL#" addtoken="false" /> --->
							<a href="<cfoutput>#authStruct.authURL#</cfoutput>" type="button">click to authorize</a>
							
							<!--- if they deny, ?denied=some_token (BfEAUgHoRueeDG6zaV0ePrwr8aE8YrVn3HcmOzM5c) will be appended to the callback url --->
							<!--- if they approve, ?oauth_token=YvLvLZri2NSCyyGZAcS2WWMLEM0OhqQWGVAlh0c&oauth_verifier=X1U0X7KUvn35UVVQhUy7arXfVJUBzapOCByuv2Jx5k will be appended to the callback url --->
	
						</div>
						
						<cfcatch type="any">
							<div class="alert alert-danger alert-dismissable">
								<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
								<strong>Error!</strong>
								<cfdump var="#cfcatch#">
							</div>
						</cfcatch>
						
					</cftry>
					
				</div>
				
			<cfelse>
			
				<cfif not session.twitter.user_authorized>
					
					<div class="row">
						<h1>You have denied access for this application to use your Twitters. So sad.</h1>
					</div>
					
				<cfelse>
					
					<!--- <div class="row">
						<h1>You have granted this application permission to post tweeteets on your behalf. Enter you twwete in the box below and, after we moderate your content, we will post it to your Twieeters.</h1>
					
						<cfif not len(session.twitter.user.screen_name)>
						
							<h1>TRY GET TWITTER HANDLE</h1>
							
							<cftry>
							
								<cfscript>
									returnData	= application.objMonkehTweet.getAccessToken(  
																	requestToken	= 	session.twitter.access_token,
																	requestSecret	= 	session.twitter.access_token_secret,
																	verifier		=	session.twitter.user_authorized_oauth_verifier
																);
												
									if (returnData.success) {
										//Save these off to your database against your User so you can access their account in the future
										session.twitter.user['accessToken']	= returnData.token;
										session.twitter.user['accessSecret']	= returnData.token_secret;
										session.twitter.user['screen_name']	= returnData.screen_name;
										session.twitter.user['user_id']		= returnData.user_id;
										
										
										// We also need to set the values into the authentication class inside monkehTweets
										application.objMonkehTweet.setFinalAccessDetails(
											oauthToken			= 	session.twitter.user['accessToken'],
											oauthTokenSecret	=	session.twitter.user['accessSecret'],
											userAccountName		=	session.twitter.user['screen_name']
										);
									}
								</cfscript>
								
								<div class="alert alert-success alert-dismissable">
									<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
									<strong>Success!</strong>
									<cfdump var="#returnData#" label="getAccessToken returnData">									
								</div>
								
								<cfcatch type="any">
									<div class="alert alert-danger alert-dismissable">
										<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
										<strong>Error!</strong>
										<cfdump var="#cfcatch#" label="getAccessToken">
									</div>
								</cfcatch>
								
							</cftry>
							
						</cfif>
						
					</div>
					
					
					
					<!--- text box w/ 140 char limit (minus space + #BlameMucus) --->
					<div class="row">
						<form role="form" name="" id="" method="post">
							
							<p>Posting on behalf of @<cfoutput>#session.twitter.user.screen_name#</cfoutput></p>
							
							<div class="form-group">
								<label for="tweet">Say something about mucus (we will append the correct hash tag)</label>
								<input type="text" name="tweet" value="" maxlength="128" class="form-control">
							</div>
							
							<div id="message">
								<span class="user-body"></span> #BlameMucus
								<div id="wc"></div>
							</div>
							
							<button type="submit" class="btn btn-default">Submit</button>
							
						</form>
						
					</div>
					
					<!--- <cfscript>
						// We also need to set the values into the authentication class inside monkehTweets
						application.objMonkehTweet.setFinalAccessDetails(
							oauthToken			= 	'272471143-4EJu679tm5sdhbACoIicySQcelRg7i6oLqjozg',
							oauthTokenSecret	=	'NEjqF5OH78wFFtR2gDrs4o3oKluUeSkzO0EKBqpols',
							userAccountName		=	session.twitter.user['screen_name']
						);
					</cfscript>
					
					<cfdump var="#application.objMonkehTweet.getUserDetails(screen_name=session.twitter.user['screen_name'])#"> --->
					
					
					<cfset userIsStillAuthorized = application.objMonkehTweet.getUserDetails(screen_name=session.twitter.user['screen_name'])>
					<cfdump var="#userIsStillAuthorized#" label="userIsStillAuthorized">
					
					<cfif structKeyExists(userIsStillAuthorized, 'screen_name')>
						Yay! You're still authorized!
					<cfelse>
						Boo! It looks like you've revoked authorization.
					</cfif> --->
					
					
				</cfif>
				
			</cfif>
			
		</div>


		<!--- Placed at the end of the document so the pages load faster --->
		<script src="//promotions.mardenkane.com/common/bootstrap3/js/bootstrap.min.js"></script>
		
		<script>
			$(function(){
				
				$(document).on('change keyup paste', 'input[name=tweet]', function(){
					$('.user-body').text($(this).val()).change();
				});
				
				$(document).on('change', '.user-body', function(){
					$('#wc').text($(this).text().length+12);
				});
				
				$('.user-body').text($('input[name=tweet]').val()).change();
			});
		</script>

  </body>
</html>
