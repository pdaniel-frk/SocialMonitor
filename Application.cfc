<cfcomponent output="false" hint="I define the application settings and event handlers.">

	<!--- set up the application --->
	<cfset this.name = "MK_SocialMonitor">
	<cfset this.title = "Social Monitor">
	<cfset this.applicationTimeout = createtimespan(0,1,0,0)>
	<cfset this.adminEmail = "egrimm@mardenkane.com">
	<cfset this.sessionManagement = "true">
	<cfset this.sessionTimeout = createTimeSpan(0,0,20,0)>
	<cfset this.dsn = "SocialMonitor">
	<cfset this.cfcPath = "SocialMonitor.components">
	<cfset this.formats.date = "mm/dd/yyyy">
	<cfset this.formats.time = "hh:mm:ss TT">

	<cfset this.uid = 1348978015>
	<cfset init("Helpers","oHelpers","BaseComponents")>
	<cfset this.debugMode = oHelpers.isDevServer()>


	<cffunction name="onApplicationStart">

		<cfset application.initialized = now()>

		<cfset application.tzid = "EST">
		<cfif getTimeZoneInfo().isDSTOn eq "yes"><cfset application.tzid = "EDT"></cfif>

	</cffunction>


	<cffunction name="onSessionStart">

		<cfset session.loggedIn = false>
		<cfset session.customerId = "">
		<cfset session.userId = "">
		<cfset session.uName = "">
		<cfset session.emailAddress = "">
		<cfset session.accessLevel = "">
		<cfset session.stamp = hash(getTickCount(), "sha-1")>

	</cffunction>


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

		<!--- tring something a little differnet... --->
		<cfif structKeyExists(url, "programId") and len(url.programId) and isNumeric(url.programId)>
			<cfset init("Programs")>
			<cfset program = oPrograms.getPrograms (
				userId = session.userId,
				customerId = session.customerId,
				programId = url.programId
			)>
		</cfif>
		<cfif structKeyExists(url, "scheduleId") and len(url.scheduleId) and isNumeric(url.scheduleId)>
			<cfset init("Schedules")>
			<cfset schedule = oSchedules.getSchedules (
				userId = session.userId,
				customerId = session.customerId,
				scheduleId = url.scheduleId
			)>
		</cfif>


		<cfif not findNoCase(".cfc", arguments.template)
			and not findNoCase("chromeless", arguments.template)
			and not findNoCase("services", arguments.template)
			and not findNoCase("partials", arguments.template)
			and not findNoCase("tasks", arguments.template)>
			<cfinclude template="header.cfm">
		<cfelse>
			<cfsetting showdebugoutput="no">
		</cfif>

	</cffunction>


	<cffunction name="onRequest" access="public" output="yes">

		<cfargument name="template" required="yes" type="string">

		<!--- that user is logged in --->
		<cfif not session.loggedin
			and not findNoCase("login.cfm", arguments.template)
			and not findNoCase("forgot-", arguments.template)
			and not findNoCase("reset-", arguments.template)
			and compareNoCase("cfschedule", cgi.http_user_agent) is not 0>
			<cfset arguments.template = "login.cfm">
		</cfif>

		<cfinclude template="#arguments.template#">
	</cffunction>


	<cffunction name="onRequestEnd">

		<cfargument name="template" required="yes" type="string">


		<!--- if requested template is a cfc, do not display header or footer --->
		<cfif not findNoCase(".cfc", arguments.template)
			and not findNoCase("chromeless", arguments.template)
			and not findNoCase("services", arguments.template)
			and not findNoCase("partials", arguments.template)
			and not findNoCase("tasks", arguments.template)>
			<cfinclude template="footer.cfm">
		</cfif>

		<cfset init("Tracking", "oTracking", "BaseComponents")>

		<cfset endAt = getTickCount()>
		<cfset executionTime = endAt-startAt>

		<cftry>
			<cfset browserShort = oTracking.browserDetect(cgi.http_user_agent)>
			<cfcatch type="any">
				<cfset browserShort = "Unknown">
			</cfcatch>
		</cftry>

		<!--- <cfset oTracking.insertPageHit (
				userId = session.userId,
				template = left(trim(cgi.script_name), 255),
				executionTime = executionTime,
				queryString = left(trim(cgi.query_string), 1000),
				IPAddress = oHelpers.getClientIP(),
				referer = left(trim(cgi.http_referer), 1000),
				browser = left(trim(cgi.http_user_agent), 1000),
				browserShort = browserShort
			)> --->

	</cffunction>


	<cffunction name="onSessionEnd"></cffunction>


	<cffunction name="onMissingTemplate">

		<cfargument name="template" required="no" type="string" default="">

		<div class="error">
			Sorry, but the page you've requested, <cfoutput>#arguments.template#</cfoutput>, was not found on this server.
		</div>

	</cffunction>


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


	<!--- shortcut to initialize components --->
	<cffunction name="init">
		<cfargument name="component" required="yes">
		<cfargument name="objName" required="no" default="o#arguments.component#">
		<cfargument name="componentPath" required="no" default="#this.cfcPath#">
		<cfargument name="dsn" required="no" default="#this.dsn#">
		<cfif not isDefined("#arguments.objName#")>
			<cfset "#arguments.objName#" = createObject("component", "#arguments.componentPath#.#arguments.component#").init(arguments.dsn)>
		</cfif>
	</cffunction>


	<cffunction name="reRoute">
		<cfargument name="destination" required="yes">
		<cfargument name="message" required="no" default="">

		<cfif len(arguments.message)>
			<div class="alert alert-success">
				<button type="button" class="close" data-dismiss="alert">&times;</button>
				<cfoutput>#arguments.message#</cfoutput>
			</div>
		</cfif>

		<!--- show progress bar --->
		<div class="progress progress-striped progress-info active">
			<div class="progress-bar" style="width: 100%;"></div>
		</div>

		<script type="text/javascript">
			window.setTimeout( function() {  location='<cfoutput>#arguments.destination#</cfoutput>' }, 3000 );
		</script>

		<cfset onRequestEnd(cgi.script_name)>
		<cfabort>
	</cffunction>

</cfcomponent>