<cfcomponent output="false" hint="I define the application settings and event handlers.">

	<!--- set up the application --->
	<cfset this.name = "MK_SocialMonitor">
	<cfset this.title = "Social Monitor">
	<cfset this.applicationTimeout = createtimespan(0,1,0,0)>
	<cfset this.adminEmail = "egrimm@mardenkane.com">
	<cfset this.sessionManagement = "true">
	<cfset this.sessionTimeout = createTimeSpan(0,0,20,0)>
	<cfset this.dsn = "SocialMonitor">
	<cfset this.cfcPath = "BaseComponents">
	
	<cfset this.uid = 1348978015>
	<!--- <cfif not findNoCase("localhost", cgi.server_name)>
		<cfset this.facebookAppId = "101309246583448"><!--- mksandbox --->
		<cfset this.uid = 1348978015>
		<cfset this.accessToken = "CAABcIZBWnspgBAMENEMSNUD7v5b4qp3Jfw4F5OzSxkTyilciZAbvvZApOJI2Scx0STZAEgyzExZAslTFMjPga4bdB7kciaTJYmc0HLlKHE5MEJoY0j59GRjbZAsTp9I0A56ucZCiScaAHTEVS4R4Tbg2i8631EEaKKYCUnVreSaJEeJHomZAUaa3KUNsJcw7hA8ZD">
	<cfelse>
		<cfset this.facebookAppId = "173323626157418"><!--- mk01testing --->
		<cfset this.uid = 1348978015>
		<cfset this.accessToken = "CAACdow0rFWoBALfKTccgsZBsfk2QyBP8ARIlMwbkYlXqvbUJGrcc2LtT25Y6yUjWAmnnyFwD7T1ZANZByjZAI0UXVFxPspv88FEXFsBjo8DfgypKP8Hn316EPqpt2vRtTPBjLgukQUcYmUeUaXWyvugF3X0rkIRrDucv8fZCIfX201fJUbnTzRt0YRVvmGhAZD">
	</cfif> --->
	
	<cfset this.debugMode = false>
	<cfif findNoCase("mk01", cgi.server_name)
		or findNoCase("localhost", cgi.server_name)>
		<cfset this.debugMode = true>
	</cfif>
		
	
	<!--- onApplicationStart --->
	<cffunction name="onApplicationStart">
			
		<cfset application.initialized = now()>
		
		<cfset application.tzid = "EST">
		<cfif getTimeZoneInfo().isDSTOn eq "yes"><cfset application.tzid = "EDT"></cfif>
		
	</cffunction>
	
	
	<!--- onSessionStart --->
	<cffunction name="onSessionStart">
		
        <cfset session.loginTrackingID = "">
		<cfset session.loggedin = false>
		<cfset session.loginID = "">
		<cfset session.uname = "">
		<cfset session.emailaddress = "">
		<cfset session.accesslevel = "">
		<cfset session.stamp = hash(getTickCount(), "sha-1")>
				
	</cffunction>
	
		
	<!--- onRequestStart --->
	<cffunction name="onRequestStart" output="yes">
		
		<cfargument name="template" required="yes" type="string">
            
		<cfsetting requesttimeout="999" showdebugoutput="false" enablecfoutputonly="false">
		
		<cfif not structKeyExists(session, "stamp")>
			<cfset session.stamp = hash(getTickCount(), "sha-1")>
		</cfif>
			
        <cfset startAt = getTickCount()>
		
		<cfset init("Helpers","oHelpers","BaseComponents")>
		
		<cftry>
			<cfset browserShort = oHelpers.browserDetect(cgi.http_user_agent)>
			<cfcatch type="any">
				<cfset browserShort = "Unknown">
			</cfcatch>
		</cftry>
		
		<!--- determine root url of site (am i really going back to this?) --->
		<cfset local = {}>
		<cfset local.basePath = getDirectoryFromPath(getCurrentTemplatePath())>
		<cfset local.targetPath = getDirectoryFromPath(expandPath(arguments.template))>
		<cfset local.requestDepth = (listLen(local.targetPath, "\/") - listLen(local.basePath, "\/"))>
		<cfset request.webRoot = repeatString("../", local.requestDepth)>
		
		<cfset request.siteURL = "http://#cgi.server_name#/SocialMonitor/">
		
		<cfif findNoCase("promotions", cgi.server_name)>
			
			<cfset request.siteURL = "https://promotions.mardenkane.com/SocialMonitor/">
			
		</cfif>
		
		<cfinclude template="credentials.cfm">
				
		<cfif not findNoCase(".cfc", arguments.template)
			and not findNoCase("chromeless", arguments.template)
			and not findNoCase("services", arguments.template)
			and not findNoCase("tasks", arguments.template)>
			<cfinclude template="header.cfm">
		<cfelse>
			<cfsetting showdebugoutput="no">
		</cfif>
		
	</cffunction>
	
	
	<!--- onRequest --->
	<cffunction name="onRequest" access="public" output="yes">
		
		<cfargument name="template" required="yes" type="string">			
			
		<!--- that user is logged in --->
		<cfif not session.loggedin
			and not findNoCase("login.cfm", arguments.template)
			and compareNoCase("cfschedule", cgi.http_user_agent) is not 0>			
			<cfset arguments.template = "login.cfm">		
		</cfif>				
		
		<cfinclude template="#arguments.template#">
	</cffunction>
	
	
	<!--- onRequestEnd --->
	<cffunction name="onRequestEnd">
		
		<cfargument name="template" required="yes" type="string">
		
		
		<!--- if requested template is a cfc, do not display header or footer --->
		<cfif not findNoCase(".cfc", arguments.template)
			and not findNoCase("chromeless", arguments.template)
			and not findNoCase("services", arguments.template)
			and not findNoCase("tasks", arguments.template)>
			<cfinclude template="footer.cfm">
		</cfif>

		<cfset init("Tracking","oTracking","BaseComponents")>
		
		<cfset endAt = getTickCount()>
		<cfset executionTime = endAt-startAt>
		
		<cftry>
			<cfset browserShort = oTracking.browserDetect(cgi.http_user_agent)>
			<cfcatch type="any">
				<cfset browserShort = "Unknown">
			</cfcatch>
		</cftry>
		
		<!--- <cfscript>
			oTracking.insertPageHit (
							loginTrackingID = session.loginTrackingID,
							loginID = session.loginID,
							template = left(trim(cgi.script_name), 255),
							executionTime = executionTime,
							queryString = left(trim(cgi.query_string), 1000),
							IPAddress = oHelpers.getClientIP(),
							referer = left(trim(cgi.http_referer), 1000),
							browser = left(trim(cgi.http_user_agent), 1000),
							browserShort = browserShort
						);
		</cfscript> --->

	</cffunction>
	
	
	<!--- onSessionEnd --->
	<cffunction name="onSessionEnd"></cffunction>
	
	<!--- onMissingTemplate --->
	<cffunction name="onMissingTemplate">
		
		<cfargument name="template" required="no" type="string" default="">
		
		<div class="error">
			Sorry, but the page you've requested, <cfoutput>#arguments.template#</cfoutput>, was not found on this server.
		</div>
		
	</cffunction>
	
	
	<!--- onError --->
	<cffunction name="onError">
		
		<cfargument name="Exception" type="any" required="no">
		
		<div class="alert alert-error alert-block error">An error was encountered, and a system administrator has been notified.</div>
		
		<!--- dont process cfaborts - these can be fired by cflocations, too --->
		<cfif exception.type eq "coldfusion.runtime.AbortException" or (isDefined("exception.rootcause.type") and exception.rootCause.type eq "coldfusion.runtime.AbortException")>
			<cfreturn>
		</cfif>
		
		<cfif this.debugMode>
			<cfoutput>#handleErrors(exception, true)#</cfoutput>
		</cfif>
		
		<cfif not this.debugMode>
			<cfmail from="mkexpert@gmail.com" to="#this.adminEmail#" subject="unhandled errors on #this.name#" type="html">
				<style>
					* {
						font-family:Georgia, "Times New Roman", Times, serif;
						color: ##444444;
						font-size: 85%;
					}
				</style>
				<p>Hello.</p>
				<p>An unhandled exception occurred at #dateFormat(now(), 'mm/dd/yy')# #timeFormat(now(), 'hh:mm:ss')#  in the #this.name# application.</p>
               	#handleErrors(exception, true)#
			</cfmail>
		</cfif>
		
		<!--- finish the page processing --->
		<cfset onRequestEnd(cgi.script_name)>
		
	</cffunction>
	
	
	<!--- handleErrors --->
	<cffunction name="handleErrors">
		<cfargument name="error" required="yes">
		<cfargument name="verbose" required="no" type="boolean" default=false>
		<cfsavecontent variable="errorOutput">
			<div class="error">
				<h1>Failed</h1>
				<cfoutput>
					<p>template: #arguments.error.TagContext[1].Template#</p>
					<p>line: #arguments.error.TagContext[1].Line#</p>
					<!--- <p>error: #arguments.error#</p> --->
					<cfif isDefined("arguments.error.cause.message") and len(arguments.error.cause.message)>
						<p>message: #arguments.error.cause.message#</p>
					<cfelse>
						<p>mesage: #arguments.error.Message#</p>
					</cfif>
					<p>detail: #arguments.error.Detail#</p>
				</cfoutput>
				<cfif arguments.verbose>
					<h2>Verbose Details</h2>
					<cfdump var="#arguments.error#" format="text" metainfo="false" label="EXCEPTION">
					<cfdump var="#cgi#" format="text" metainfo="false" label="CGI">
					<cfdump var="#session#" format="text" metainfo="false" label="SESSION">
					<cfif isStruct(form) and not structIsEmpty(form)>
						<cfdump var="#form#" format="text" metainfo="false" label="FORM">
					</cfif>
				</cfif>
			</div>
		</cfsavecontent>
		<cfreturn errorOutput>
	</cffunction>
	
	
	<!--- shortcut to init components - this is just a bit bril! --->
	<cffunction name="init">
		<cfargument name="component" required="yes">
		<cfargument name="objName" required="no" default="o#arguments.component#">
		<cfargument name="componentPath" required="no" default="#this.cfcPath#">
		<cfargument name="dsn" required="no" default="#this.dsn#">
		<cfif not isDefined("#arguments.objName#")>
			<cfset "#arguments.objName#" = createObject("component", "#arguments.componentPath#.#arguments.component#").init(arguments.dsn)>
		</cfif>
	</cffunction>
	
</cfcomponent>