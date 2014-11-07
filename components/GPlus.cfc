<cfcomponent displayname="Google+ Components" output="no" hint="Mostly for saving FB search results">

	<cffunction name="init" output="no">

		<!--- define arguments --->
		<cfargument name="dsn" required="true" type="string">

		<!--- set variables scope --->
		<cfset variables.dsn = arguments.dsn>
		<cfset variables.api_url = "https://www.googleapis.com/plus/v1/">

		<!--- some usefuls --->
		<!--- https://developers.google.com/+/api/ --->
		<!--- https://console.developers.google.com/project/plucky-courier-740/apiui/credential --->

		<cfreturn this>

	</cffunction>


	<!--- https://developers.google.com/+/api/latest/people#resource --->
	<cffunction name="getPeople" output="no">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="userId" required="no" default="">
		<cfargument name="searchTerm" required="no" default="">
		<cfargument name="api_key" required="no" default="">
		<cfargument name="nextPageToken" required="no" default="">
		<cfargument name="maxResults" required="no" default=20>
		<cfargument name="save_results" required="no" default=false>

		<cftry>

			<cfif len(arguments.userId)>

				<!--- get a specific person --->
				<cfhttp url="#variables.api_url#people/#arguments.userId#" method="get">
					<cfhttpparam type="url" name="key" value="#arguments.api_key#">
				</cfhttp>

				<cfset people_result = deserializeJson(cfhttp.fileContent)>

				<cfif arguments.save_results></cfif>

			<cfelseif len(arguments.searchTerm)>

				<!--- search for a person --->
				<cfhttp url="#variables.api_url#people" method="get">
					<cfhttpparam type="url" name="query" value="#arguments.searchTerm#">
					<cfhttpparam type="url" name="key" value="#arguments.api_key#">
					<cfhttpparam type="url" name="pageToken" value="#arguments.nextPageToken#">
					<cfhttpparam type="url" name="maxResults" value="#arguments.maxResults#">
					<cfhttpparam type="url" name="orderBy" value="recent">
				</cfhttp>

				<cfset people_result = deserializeJson(cfhttp.fileContent)>

				<cfif arguments.save_results></cfif>

			</cfif>

			<cfcatch type="any">
				<cfset people_result = '{"error": true}'>
			</cfcatch>

		</cftry>

		<cfreturn people_result>

	</cffunction>


	<!--- https://developers.google.com/+/api/latest/activities#resource --->
	<cffunction name="getActivities" output="yes">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="searchTerm" required="no" default="">
		<cfargument name="activityId" required="no" default="">
		<cfargument name="userId" required="no" default="">
		<cfargument name="api_key" required="no" default="">
		<cfargument name="nextPageToken" required="no" default="">
		<cfargument name="maxResults" required="no" default=20>
		<cfargument name="save_results" required="no" default=false>

		<cftry>

			<cfif len(arguments.activityId)>

				<!--- get a specific activity --->
				<cfhttp url="#variables.api_url#activities/#arguments.activityId#" method="get">
					<cfhttpparam type="url" name="key" value="#arguments.api_key#">
				</cfhttp>

				<cfset activity_result = deserializeJson(cfhttp.fileContent)>

				<cfif arguments.save_results></cfif>

			<cfelseif len(arguments.userId)>

				<!--- get a persons activites --->
				<!--- https://developers.google.com/+/api/latest/activities/list --->
				<cfhttp url="#variables.api_url#people/#arguments.userId#/activities/public" method="get">
					<cfhttpparam type="url" name="key" value="#arguments.api_key#">
					<cfhttpparam type="url" name="pageToken" value="#arguments.nextPageToken#">
					<cfhttpparam type="url" name="maxResults" value="#arguments.maxResults#">
					<cfhttpparam type="url" name="orderBy" value="recent">
				</cfhttp>

				<cfset activity_result = deserializeJson(cfhttp.fileContent)>

				<cfif arguments.save_results></cfif>

			<cfelseif len(arguments.searchTerm)>

				<!--- search for an activity --->
				<!--- https://developers.google.com/+/api/latest/activities/search --->
				<cfhttp url="#variables.api_url#activities" method="get">
					<cfhttpparam type="url" name="query" value="#arguments.searchTerm#">
					<cfhttpparam type="url" name="key" value="#arguments.api_key#">
					<cfhttpparam type="url" name="pageToken" value="#arguments.nextPageToken#">
					<cfhttpparam type="url" name="maxResults" value="#arguments.maxResults#">
					<cfhttpparam type="url" name="orderBy" value="recent">
				</cfhttp>

				<cfset activity_result = deserializeJson(cfhttp.fileContent)>

				<cfif arguments.save_results>

					<cfif structKeyExists(activity_result, "items")>

						<cfif arrayLen(activity_result.items)>

							<cfloop from="1" to="#arrayLen(activity_result.items)#" index="i">

								<cftry>

									<!--- if searchTerm is found... --->
									<cfif findNoCase(arguments.searchTerm, activity_result.items[i].object.content)>

										<cfset activity = parseActivityObject(activity_result.items[i])>

										<cfset insertActivity (
											programId = arguments.programId,
											scheduleId = arguments.scheduleId,
											activity = activity
										)>

										<cfset user = getPeople(userId=activity.actor.id, api_key=arguments.api_key)>
										<cfset user = parseUserObject(user)>
										<cfset insertUser(user=user)>

									</cfif>

									<cfcatch type="any">
										<cfdump var="#cfcatch#">
									</cfcatch>

								</cftry>

							</cfloop>

						</cfif>

					</cfif>

				</cfif>

			</cfif>

			<cfcatch type="any">
				<cfdump var="#cfcatch#">
				<cfset activity_result = '{"error": true}'>
			</cfcatch>

		</cftry>

		<cfreturn activity_result>

	</cffunction>


	<!--- https://developers.google.com/+/api/latest/comments#resource --->
	<cffunction name="getComments" output="yes">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="searchTerm" required="no" default="">
		<cfargument name="commentId" required="no" default="">
		<cfargument name="activityId" required="no" default="">
		<cfargument name="api_key" required="no" default="">
		<cfargument name="nextPageToken" required="no" default="">
		<cfargument name="maxResults" required="no" default=500>
		<cfargument name="save_results" required="no" default=false>

		<cftry>

			<cfif len(arguments.commentId)>

				<!--- get details on a comment --->
				<!--- https://developers.google.com/+/api/latest/comments/get --->
				<cfhttp url="#variables.api_url#comments/#arguments.commentId#" method="get">
					<cfhttpparam type="url" name="key" value="#arguments.api_key#">
				</cfhttp>

				<cfset comment_result = deserializeJson(cfhttp.fileContent)>

				<cfif arguments.save_results>

					<cfset comment = parseCommentObject(comment_result)>

					<cfif not len(arguments.searchTerm) or findNoCase(arguments.searchTerm, comment.object.content)>

						<cfset insertComment (
							programId = arguments.programId,
							scheduleId = arguments.scheduleId,
							comment = comment
						)>

						<!--- get this comments author --->
						<cfset getPeople (
							userId = comment.actor.id,
							api_key = arguments.api_key,
							save_results = arguments.save_results
						)>

					</cfif>

				</cfif>

			<cfelseif len(arguments.activityId)>

				<!--- get comments on an activity --->
				<!--- https://developers.google.com/+/api/latest/comments/list --->
				<cfhttp url="#variables.api_url#activities/#arguments.activityId#/comments" method="get">
					<cfhttpparam type="url" name="key" value="#arguments.api_key#">
					<cfhttpparam type="url" name="pageToken" value="#arguments.nextPageToken#">
					<cfhttpparam type="url" name="maxResults" value="#arguments.maxResults#">
					<cfhttpparam type="url" name="sortOrder" value="descending">
				</cfhttp>

				<cfset comment_result = deserializeJson(cfhttp.fileContent)>

				<cfif arguments.save_results>

					<cfloop from="1" to="#arrayLen(comment_result.items)#" index="ci">

						<cfset comment = parseCommentObject(comment_result.items[ci])>

						<cfif not len(arguments.searchTerm) or findNoCase(arguments.searchTerm, comment.object.content)>

							<cfset insertComment (
								programId = arguments.programId,
								scheduleId = arguments.scheduleId,
								comment = comment
							)>

							<!--- get this comments author --->
							<cfset getPeople (
								userId = comment.actor.id,
								api_key = arguments.api_key,
								save_results = arguments.save_results
							)>

						</cfif>

					</cfloop>

				</cfif>

			</cfif>

			<cfcatch type="any">
				<cfdump var="#cfcatch#">
				<cfset comment_result = '{"error": true}'>
			</cfcatch>

		</cftry>

		<cfreturn comment_result>

	</cffunction>


	<cffunction name="getMoments" output="no">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="userId" required="no" default="">
		<cfargument name="api_key" required="no" default="">
		<cfargument name="nextPageToken" required="no" default="">
		<cfargument name="maxResults" required="no" default=20>
		<cfargument name="save_results" required="no" default=false>

		<cftry>

			<cfif len(arguments.userId)>

				<!--- get a users moments --->
				<!--- https://developers.google.com/+/api/latest/moments/list --->
				<cfhttp url="#variables.api_url#people/#arguments.userId#/moments/vault" method="get">
					<cfhttpparam type="url" name="key" value="#arguments.api_key#">
					<cfhttpparam type="url" name="pageToken" value="#arguments.nextPageToken#">
					<cfhttpparam type="url" name="maxResults" value="#arguments.maxResults#">
					<cfhttpparam type="url" name="orderBy" value="recent">
				</cfhttp>

				<cfset moment_result = deserializeJson(cfhttp.fileContent)>

				<cfif arguments.save_results></cfif>

			</cfif>

			<cfcatch type="any">
				<cfset moment_result = '{"error": true}'>
			</cfcatch>

		</cftry>

		<cfreturn moment_result>

	</cffunction>


	<cffunction name="insertActivity" output="yes" returntype="void">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" default="">
		<cfargument name="activity" required="yes" type="struct">

		<cfquery datasource="#variables.dsn#">

			if not exists (
				select 1
				from GoogleActivities
				where id = <cfqueryparam value="#arguments.activity.id#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.programId)>
					and programId = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
				<cfelseif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin

				insert into GoogleActivities (
					programId,
					scheduleId,
					id,
					kind,
					verb,
					title,
					url,
					[object.content],
					[object.originalContent],
					[object.objectType],
					[object.id],
					annotation,
					[actor.id],
					[actor.displayName],
					placeName,
					published
				)
				values (
					<cfqueryparam value="#arguments.programId#" null="#not len(arguments.programId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.activity.id#" null="#not len(arguments.activity.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.activity.kind#" null="#not len(arguments.activity.kind)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.activity.verb#" null="#not len(arguments.activity.verb)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.activity.title#" null="#not len(arguments.activity.title)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.activity.url#" null="#not len(arguments.activity.url)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.activity.object.content#" null="#not len(arguments.activity.object.content)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.activity.object.originalContent#" null="#not len(arguments.activity.object.originalContent)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.activity.object.objectType#" null="#not len(arguments.activity.object.objectType)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.activity.object.id#" null="#not len(arguments.activity.object.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.activity.annotation#" null="#not len(arguments.activity.annotation)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.activity.actor.id#" null="#not len(arguments.activity.actor.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.activity.actor.displayName#" null="#not len(arguments.activity.actor.displayName)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.activity.placeName#" null="#not len(arguments.activity.placeName)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.activity.published#" null="#not len(arguments.activity.published)#" cfsqltype="cf_sql_timestamp">
				)

			end

		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="insertUser" output="yes" returntype="void">

		<cfargument name="user" required="yes" type="struct">

		<cfquery datasource="#variables.dsn#">

			if not exists (
				select 1
				from GoogleUsers
				where id = <cfqueryparam value="#arguments.user.id#" cfsqltype="cf_sql_varchar">
			)
			begin

				insert into GoogleUsers (
					id,
					kind,
					displayName,
					[image.url],
					[name.familyName],
					[name.givenName],
					objectType,
					url
				)
				values (
					<cfqueryparam value="#arguments.user.id#" null="#not len(arguments.user.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user.kind#" null="#not len(arguments.user.kind)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user.displayName#" null="#not len(arguments.user.displayName)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user.image.url#" null="#not len(arguments.user.image.url)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user.name.familyName#" null="#not len(arguments.user.name.familyName)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user.name.givenName#" null="#not len(arguments.user.name.givenName)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user.objectType#" null="#not len(arguments.user.objectType)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.user.url#" null="#not len(arguments.user.url)#" cfsqltype="cf_sql_varchar">
				)

			end

		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="insertComment" output="yes" returntype="void">

		<cfargument name="programId" required="no" default="">
		<cfargument name="scheduleId" default="">
		<cfargument name="comment" required="yes" type="struct">

		<cfquery datasource="#variables.dsn#">

			if not exists (
				select 1
				from GoogleComments
				where id = <cfqueryparam value="#arguments.comment.id#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.programId)>
					and programId = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
				<cfelseif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin

				insert into GoogleComments (
					programId,
					scheduleId,
					id,
					kind,
					verb,
					[actor.id],
					[actor.displayName],
					[object.content],
					[object.objectType],
					[inReplyTo.id],
					[inReplyTo.url],
					published
				)
				values (
					<cfqueryparam value="#arguments.programId#" null="#not len(arguments.programId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.comment.id#" null="#not len(arguments.comment.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.comment.kind#" null="#not len(arguments.comment.kind)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.comment.verb#" null="#not len(arguments.comment.verb)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.comment.actor.id#" null="#not len(arguments.comment.actor.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.comment.actor.displayName#" null="#not len(arguments.comment.actor.displayName)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.comment.object.content#" null="#not len(arguments.comment.object.content)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.comment.object.objectType#" null="#not len(arguments.comment.object.objectType)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.comment.inReplyTo.id#" null="#not len(arguments.comment.inReplyTo.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.comment.inReplyTo.url#" null="#not len(arguments.comment.inReplyTo.url)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.comment.published#" null="#not len(arguments.comment.published)#" cfsqltype="cf_sql_timestamp">
				)

			end

		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="parseActivityObject" output="yes" returntype="struct">

		<cfargument name="activity" required="yes" type="struct">

		<!--- set up defaults --->
		<cfset local.activity.id = "">
		<cfset local.activity.kind = "">
		<cfset local.activity.verb = "">
		<cfset local.activity.title = "">
		<cfset local.activity.url = "">
		<cfset local.activity.object.content = "">
		<cfset local.activity.object.originalContent = "">
		<cfset local.activity.object.objectType = "">
		<cfset local.activity.object.id = "">
		<cfset local.activity.annotation = "">
		<cfset local.activity.actor.id = "">
		<cfset local.activity.actor.displayName = "">
		<cfset local.activity.placeName = "">
		<cfset local.activity.published = "">

		<!--- check for existence in activity object --->
		<cfif structKeyExists(arguments.activity, "id")>
			<cfset local.activity.id = arguments.activity.id>
		</cfif>
		<cfif structKeyExists(arguments.activity, "kind")>
			<cfset local.activity.kind = arguments.activity.kind>
		</cfif>
		<cfif structKeyExists(arguments.activity, "verb")>
			<cfset local.activity.verb = arguments.activity.verb>
		</cfif>
		<cfif structKeyExists(arguments.activity, "title")>
			<cfset local.activity.title = arguments.activity.title>
		</cfif>
		<cfif structKeyExists(arguments.activity, "url")>
			<cfset local.activity.url = arguments.activity.url>
		</cfif>
		<cfif structKeyExists(arguments.activity, "object")>
			<cfset local.activity.object.content = arguments.activity.object.content>
			<cfif structKeyExists(arguments.activity.object, "originalContent")>
				<cfset local.activity.object.originalContent = arguments.activity.object.originalContent>
			</cfif>
			<cfset local.activity.object.objectType = arguments.activity.object.objectType>
			<cfif structKeyExists(arguments.activity.object, "id")>
				<cfset local.activity.object.id = arguments.activity.object.id>
			</cfif>
		</cfif>
		<cfif structKeyExists(arguments.activity, "annotation")>
			<cfset local.activity.annotation = arguments.activity.annotation>
		</cfif>
		<cfif structKeyExists(arguments.activity, "actor")>
			<cfset local.activity.actor.id = arguments.activity.actor.id>
			<cfset local.activity.actor.displayName = arguments.activity.actor.displayName>
		</cfif>
		<cfif structKeyExists(arguments.activity, "placeName")>
			<cfset local.activity.placeName = arguments.activity.placeName>
		</cfif>
		<cfif structKeyExists(arguments.activity, "published")>
			<cfset myDateTime = convertPublishedToDateTime(arguments.activity.published)>
			<cfset local.activity.published = myDateTime>
		</cfif>

		<cfreturn local.activity>

	</cffunction>


	<cffunction name="parseUserObject" output="no" returntype="struct">

		<cfargument name="user" required="yes" type="struct">

		<!--- set up defaults --->
		<cfset local.user.id = "">
		<cfset local.user.displayName = "">
		<cfset local.user.image.url = "">
		<cfset local.user.kind = "">
		<cfset local.user.name.familyName = "">
		<cfset local.user.name.givenName = "">
		<cfset local.user.objectType = "">
		<cfset local.user.url = "">

		<!--- check for existence in user object --->
		<cfif structKeyExists(arguments.user, "id")>
			<cfset local.user.id = arguments.user.id>
		</cfif>
		<cfif structKeyExists(arguments.user, "displayName")>
			<cfset local.user.displayName = arguments.user.displayName>
		</cfif>
		<cfif structKeyExists(arguments.user, "image")>
			<cfset local.user.image.url = arguments.user.image.url>
		</cfif>
		<cfif structKeyExists(arguments.user, "kind")>
			<cfset local.user.kind = arguments.user.kind>
		</cfif>
		<cfif structKeyExists(arguments.user, "name")>
			<cfset local.user.name.familyName = arguments.user.name.familyName>
			<cfset local.user.name.givenName = arguments.user.name.givenName>
		</cfif>
		<cfif structKeyExists(arguments.user, "objectType")>
			<cfset local.user.objectType = arguments.user.objectType>
		</cfif>
		<cfif structKeyExists(arguments.user, "url")>
			<cfset local.user.url = arguments.user.url>
		</cfif>

		<cfreturn local.user>

	</cffunction>


	<cffunction name="parseCommentObject" output="yes" returntype="struct">

		<cfargument name="comment" required="yes" type="struct">

		<!--- set up defaults --->
		<cfset local.comment.id = "">
		<cfset local.comment.kind = "">
		<cfset local.comment.published = "">
		<cfset local.comment.actor.id = "">
		<cfset local.comment.actor.displayName = "">
		<cfset local.comment.verb = "">
		<cfset local.comment.object.content = "">
		<cfset local.comment.object.objectType = "">
		<cfset local.comment.inReplyTo.id = "">
		<cfset local.comment.inReplyTo.url = "">

		<!--- check for existence in comment object --->
		<cfif structKeyExists(arguments.comment, "id")>
			<cfset local.comment.id = arguments.comment.id>
		</cfif>
		<cfif structKeyExists(arguments.comment, "kind")>
			<cfset local.comment.kind = arguments.comment.kind>
		</cfif>
		<cfif structKeyExists(arguments.comment, "published")>
			<cfset myDateTime = convertPublishedToDateTime(arguments.comment.published)>
			<cfset local.comment.published = myDateTime>
		</cfif>
		<cfif structKeyExists(arguments.comment, "actor")>
			<cfset local.comment.actor.id = arguments.comment.actor.id>
			<cfset local.comment.actor.displayName = arguments.comment.actor.displayName>
		</cfif>
		<cfif structKeyExists(arguments.comment, "verb")>
			<cfset local.comment.verb = arguments.comment.verb>
		</cfif>
		<cfif structKeyExists(arguments.comment, "object")>
			<cfset local.comment.object.content = arguments.comment.object.content>
			<cfset local.comment.object.objectType = arguments.comment.object.objectType>
		</cfif>
		<cfif structKeyExists(arguments.comment, "inReplyTo") and arrayLen(comment.inReplyTo)>
			<cfset local.comment.inReplyTo.id = arguments.comment.inReplyTo[1].id>
			<cfset local.comment.inReplyTo.url = arguments.comment.inReplyTo[1].url>
		</cfif>

		<cfreturn local.comment>

	</cffunction>


	<cffunction name="convertPublishedToDateTime" output="no">

		<cfargument name="published" required="yes" type="string">

		<!--- 2014-10-29T10:25:31.279Z is an invalid date or time string. --->

		<cftry>

			<cfset myDate = listFirst(arguments.published, 'T')>
			<cfset myTime = listLast(listFirst(arguments.published, '.'), 'T')>
			<cfset myDateTime = createDateTime(year(myDate), month(myDate), day(myDate), hour(myTime), minute(myTime), second(myTime))>

			<cfreturn myDateTime>

			<cfcatch type="any">
				<cfreturn arguments.published>
			</cfcatch>

		</cftry>

	</cffunction>

</cfcomponent>