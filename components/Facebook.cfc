<cfcomponent displayname="Facebook Components" output="no" hint="Mostly for saving FB search results">

	<cffunction name="init" output="no">

		<!--- define arguments --->
		<cfargument name="dsn" required="true" type="string">

		<!--- set variables scope --->
		<cfset variables.dsn = arguments.dsn>
		<cfset variables.api_url = "https://graph.facebook.com/v2.1/">
		<!--- note this version will be completely deprecated on or about 2015-04-01 --->
		<cfset variables.legacy_api_url = "https://graph.facebook.com/v1.0/">
		<cfset variables.unversioned_api_url = "https://graph.facebook.com/">

		<!--- some usefuls --->
		<!--- https://developers.facebook.com/docs/graph-api/using-graph-api/v2.1#paging --->

		<cfreturn this>

	</cffunction>


	<cffunction name="getPage" output="no">

		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="pageId" required="no" default="">
		<cfargument name="searchTerm" required="no" default="">
		<cfargument name="until" required="no" default="">
		<cfargument name="limit" required="no" default=25>
		<cfargument name="access_token" required="no" default="">
		<cfargument name="save_results" required="no" default=false>

		<cfif len(arguments.pageId)>

			<cfhttp url="#variables.api_url##arguments.pageId#" method="get" charset="utf-8">
				<cfhttpparam type="url" name="access_token" value="#arguments.access_token#">
				<cfhttpparam type="url" name="until" value="#arguments.until#">
				<cfhttpparam type="url" name="limit" value="#arguments.limit#">
				<cfhttpparam type="url" name="fields" value="id,category,checkins,description,likes,link,name,username">
			</cfhttp>

			<cfset page_result = deserializeJson(cfhttp.fileContent)>

			<cfif arguments.save_results>

				<cfif not structKeyExists(page_result, 'error')>

					<cfset id = "">
					<cfset category = "">
					<cfset checkins = "">
					<cfset description = "">
					<cfset likes = "">
					<cfset link = "">
					<cfset name = "">
					<cfset username = "">

					<cfif structKeyExists(page_result, 'id')>
						<cfset id = page_result.id>
					</cfif>
					<cfif structKeyExists(page_result, 'category')>
						<cfset category = page_result.category>
					</cfif>
					<cfif structKeyExists(page_result, 'checkins')>
						<cfset checkins = page_result.checkins>
					</cfif>
					<cfif structKeyExists(page_result, 'description')>
						<cfset description = page_result.description>
					</cfif>
					<cfif structKeyExists(page_result, 'likes')>
						<cfset likes = page_result.likes>
					</cfif>
					<cfif structKeyExists(page_result, 'link')>
						<cfset link = page_result.link>
					</cfif>
					<cfif structKeyExists(page_result, 'name')>
						<cfset name = page_result.name>
					</cfif>
					<cfif structKeyExists(page_result, 'username')>
						<cfset username = page_result.username>
					</cfif>

					<cfset insertFacebookPage (
						scheduleId = arguments.scheduleId,
						id = id,
						category = category,
						checkins = checkins,
						description = description,
						likes = likes,
						link = link,
						name = name,
						username = username
					)>

				</cfif>

			</cfif>

		<cfelseif len(arguments.searchTerm)>

			<cfhttp url="#variables.api_url#search/" method="get" charset="utf-8">
				<cfhttpparam type="url" name="access_token" value="#arguments.access_token#">
				<cfhttpparam type="url" name="q" value="#arguments.searchTerm#">
				<cfhttpparam type="url" name="until" value="#arguments.until#">
				<cfhttpparam type="url" name="limit" value="#arguments.limit#">
				<cfhttpparam type="url" name="type" value="page">
				<cfhttpparam type="url" name="fields" value="id,category,checkins,description,likes,link,name,username">
			</cfhttp>

			<cfset page_result = deserializeJson(cfhttp.fileContent)>

		<cfelse>
			<cfreturn "{}">
		</cfif>

		<cftry>

			<cfreturn page_result>

			<cfcatch type="any">
				<cfreturn "{'error':true}">
			</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="getPageName" output="no">

		<cfargument name="pageId" required="yes">
		<cfargument name="access_token" required="no" default="">

		<cfhttp url="#variables.api_url##arguments.pageId#" method="get" charset="utf-8">
			<cfhttpparam type="url" name="access_token" value="#arguments.access_token#">
			<cfhttpparam type="url" name="fields" value="name">
		</cfhttp>

		<cftry>

			<cfreturn deserializeJson(cfhttp.fileContent).name>

			<cfcatch type="any">
				<cfreturn "">
			</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="getPageFeed" output="yes">

		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="pageId" required="yes">
		<cfargument name="searchTerm" required="no" default="">
		<cfargument name="until" required="no" default="">
		<cfargument name="limit" required="no" default=25>
		<cfargument name="access_token" required="no" default="">
		<cfargument name="save_results" required="no" default=false>

		<cfhttp url="#variables.api_url##arguments.pageId#/feed" method="get" charset="utf-8">
			<cfhttpparam type="url" name="access_token" value="#arguments.access_token#">
			<cfhttpparam type="url" name="until" value="#arguments.until#">
			<cfhttpparam type="url" name="limit" value="#arguments.limit#">
			<cfhttpparam type="url" name="fields" value="id,from,message,type,status_type,object_id,created_time,shares,likes">
		</cfhttp>

		<cftry>

			<cfset feed_result = deserializeJson(cfhttp.fileContent)>

			<cfif arguments.save_results and len(arguments.searchTerm)>
				<!--- save feed results that have a message includeing the search term --->
				<cfloop from="1" to="#arrayLen(feed_result.data)#" index="i">
					<cfset thisFeed = structGet('feed_result.data[#i#]')>
					<cfif structKeyExists(thisFeed, 'message')>
						<cfif findNoCase(arguments.searchTerm, thisFeed.message)>

							<!--- defaults --->
							<cfset id = "">
							<cfset from_name = "">
							<cfset from_id = "">
							<cfset message = thisFeed.message>
							<cfset type = "">
							<cfset link = "">
							<cfset name = "">
							<cfset caption = "">
							<cfset created_time = "">

							<cfif structKeyExists(thisFeed, "id")>
								<cfset id = thisFeed.id>
							</cfif>
							<cfif structKeyExists(thisFeed, "from")>
								<cfif structKeyExists(thisFeed.from, "name")>
									<cfset from_name = thisFeed.from.name>
								</cfif>
								<cfif structKeyExists(thisFeed.from, "id")>
									<cfset from_id = thisFeed.from.id>
								</cfif>
							</cfif>
							<cfif structKeyExists(thisFeed, "type")>
								<cfset type = thisFeed.type>
							</cfif>
							<cfif structKeyExists(thisFeed, "link")>
								<cfset link = thisFeed.link>
							</cfif>
							<cfif structKeyExists(thisFeed, "name")>
								<cfset name = thisFeed.name>
							</cfif>
							<cfif structKeyExists(thisFeed, "caption")>
								<cfset caption = thisFeed.caption>
							</cfif>
							<cfif structKeyExists(thisFeed, "created_time")>
								<cfset created_time = convertCreatedTimeToBigint(thisFeed.created_time)>
							</cfif>

							<cfset insertFacebookPageFeed (
								scheduleId = arguments.scheduleId,
								pageId = arguments.pageId,
								id = id,
								from_name = from_name,
								from_id = from_id,
								message = message,
								type = type,
								link = link,
								name = name,
								caption = caption,
								created_time = created_time
							)>

							<cfset getUser (
								id = from_id,
								access_token = arguments.access_token,
								save_results = arguments.save_results
							)>

						</cfif>
					</cfif>
				</cfloop>
			</cfif>

			<cfreturn feed_result>

			<cfcatch type="any">
				<cfdump var="#cfcatch#">
				<cfreturn "{'error':true}">
			</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="getPost" output="yes">

		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="postId" required="yes">
		<cfargument name="until" required="no" default="">
		<cfargument name="limit" required="no" default=25>
		<cfargument name="access_token" required="no" default="">
		<cfargument name="save_results" required="no" default=false>

		<cfhttp url="#variables.api_url##arguments.postId#" method="get" charset="utf-8">
			<cfhttpparam type="url" name="access_token" value="#arguments.access_token#">
			<cfhttpparam type="url" name="until" value="#arguments.until#">
			<cfhttpparam type="url" name="limit" value="#arguments.limit#">
			<cfhttpparam type="url" name="fields" value="id,from,message,type,status_type,object_id,created_time,shares,likes">
		</cfhttp>

		<cftry>

			<cfset post_result = deserializeJson(cfhttp.fileContent)>

			<cfif arguments.save_results>

				<cfif not structKeyExists(post_result, 'error')>

					<p><cfoutput>saving post</cfoutput></p>
					<cfdump var="#post_result#">

					<cfset pageId = listFirst(arguments.postId, "_")>
					<cfset from_name = ''>
					<cfset from_id = ''>
					<cfset message = ''>
					<cfset type = ''>
					<cfset status_type = ''>
					<cfset object_id = ''>
					<cfset created_time = ''>
					<cfset shares_count = ''>
					<cfset likes_count = ''>

					<cfif structKeyExists(post_result, "from")>
						<cfif structKeyExists(post_result.from, "name")>
							<cfset from_name = post_result.from.name>
						</cfif>
						<cfif structKeyExists(post_result.from, "id")>
							<cfset from_id = post_result.from.id>
						</cfif>
					</cfif>
					<cfif structKeyExists(post_result, 'message')>
						<cfset message = post_result.message>
					</cfif>
					<cfif structKeyExists(post_result, 'type')>
						<cfset type = post_result.type>
					</cfif>
					<cfif structKeyExists(post_result, 'status_type')>
						<cfset status_type = post_result.status_type>
					</cfif>
					<cfif structKeyExists(post_result, 'object_id')>
						<cfset object_id = post_result.object_id>
					</cfif>
					<cfif structKeyExists(post_result, 'created_time')>
						<cfset created_time = convertCreatedTimeToBigint(post_result.created_time)>
					</cfif>
					<cfif structKeyExists(post_result, 'shares')>
						<cfset shares_count = post_result.shares.count>
					</cfif>
					<cfif structKeyExists(post_result, 'likes')>
						<cfset likes_count = arrayLen(post_result.likes.data)>
					</cfif>

					<cfset insertFacebookPost (
						scheduleId = arguments.scheduleId,
						pageId = pageId,
						id =  arguments.postId,
						from_name = from_name,
						from_id = from_id,
						message = message,
						type = type,
						status_type = status_type,
						object_id = object_id,
						likes_count = likes_count,
						shares_count = shares_count,
						created_time = created_time
					)>


					<cfset getUser (
						id = from_id,
						access_token = arguments.access_token,
						save_results = arguments.save_results
					)>

				</cfif>

			</cfif>

			<cfreturn post_result>

			<cfcatch type="any">
				<cfdump var="#cfcatch#">
				<cfreturn "{'error':true}">
			</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="getComments" output="yes">

		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="searchTerm" required="no" default="">
		<cfargument name="id" required="yes">
		<cfargument name="until" required="no" default="">
		<cfargument name="limit" required="no" default=25>
		<cfargument name="access_token" required="no" default="">
		<cfargument name="save_results" required="no" default=false>

		<cfhttp url="#variables.api_url##arguments.id#/comments" method="get" charset="utf-8">
			<cfhttpparam type="url" name="access_token" value="#arguments.access_token#">
			<cfhttpparam type="url" name="until" value="#arguments.until#">
			<cfhttpparam type="url" name="limit" value="#arguments.limit#">
			<cfhttpparam type="url" name="fields" value="id,from,message,created_time,like_count">
		</cfhttp>

		<cftry>

			<cfset comment_result = deserializeJson(cfhttp.fileContent)>

			<cfif arguments.save_results and len(arguments.searchTerm)>
				<!--- save feed results that have a message includeing the search term --->
				<cfloop from="1" to="#arrayLen(comment_result.data)#" index="i">
					<cfset thisComment = structGet('comment_result.data[#i#]')>
					<cfif structKeyExists(thisComment, 'message')>
						<cfif findNoCase(arguments.searchTerm, thisComment.message)>

							<!--- defaults --->
							<cfset id = "">
							<cfset from_name = "">
							<cfset from_id = "">
							<cfset message = thisComment.message>
							<cfset like_count = "">
							<cfset comment_count = "">
							<cfset created_time = "">

							<cfif structKeyExists(thisComment, "id")>
								<cfset id = thisComment.id>
							</cfif>
							<cfif structKeyExists(thisComment, "from")>
								<cfif structKeyExists(thisComment.from, "name")>
									<cfset from_name = thisComment.from.name>
								</cfif>
								<cfif structKeyExists(thisComment.from, "id")>
									<cfset from_id = thisComment.from.id>
								</cfif>
							</cfif>
							<cfif structKeyExists(thisComment, "like_count")>
								<cfset like_count = thisComment.like_count>
							</cfif>
							<cfif structKeyExists(thisComment, "comment_count")>
								<cfset comment_count = thisComment.comment_count>
							</cfif>
							<cfif structKeyExists(thisComment, "created_time")>
								<cfset created_time = convertCreatedTimeToBigint(thisComment.created_time)>
							</cfif>

							<cfset insertFacebookPostComment (
								scheduleId = arguments.scheduleId,
								id = id,
								from_name = from_name,
								from_id = from_id,
								message = message,
								like_count = like_count,
								comment_count = comment_count,
								created_time = created_time
							)>

							<cfset getUser (
								id = from_id,
								access_token = arguments.access_token,
								save_results = arguments.save_results
							)>

						</cfif>
					</cfif>
				</cfloop>
			</cfif>

			<cfreturn comment_result>

			<cfcatch type="any">
				<cfdump var="#cfcatch#">
				<cfreturn "{'error':true}">
			</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="getUser" output="yes">

		<cfargument name="Id" required="yes">
		<cfargument name="access_token" required="no" default="">
		<cfargument name="save_results" required="no" default=false>

		<cfhttp url="#variables.legacy_api_url##arguments.Id#" method="get" charset="utf-8">
			<cfhttpparam type="url" name="access_token" value="#arguments.access_token#">
		</cfhttp>

		<cftry>

			<cfset user_result = deserializeJson(cfhttp.fileContent)>

			<cfif arguments.save_results>

				<cfset id = arguments.Id>
				<cfset age_range_min = "">
				<cfset age_range_max = "">
				<cfset birthday = "">
				<cfset email = "">
				<cfset first_name = "">
				<cfset gender = "">
				<cfset last_name = "">
				<cfset link = "">
				<cfset locale = "">
				<cfset middle_name = "">
				<cfset name = "">
				<cfset timezone = "">

				<cfif structKeyExists(user_result, "age_range")>
					<cfif structKeyExists(user_result.age_range, "min")>
						<cfset age_range_min = user_result.age_range.min>
					</cfif>
					<cfif structKeyExists(user_result.age_range, "max")>
						<cfset age_range_max = user_result.age_range.max>
					</cfif>
				</cfif>
				<cfif structKeyExists(user_result, "birthday")>
					<cfset birthday = user_result.birthday>
				</cfif>
				<cfif structKeyExists(user_result, "email")>
					<cfset email = user_result.email>
				</cfif>
				<cfif structKeyExists(user_result, "first_name")>
					<cfset first_name = user_result.first_name>
				</cfif>
				<cfif structKeyExists(user_result, "gender")>
					<cfset gender = user_result.gender>
				</cfif>
				<cfif structKeyExists(user_result, "last_name")>
					<cfset last_name = user_result.last_name>
				</cfif>
				<cfif structKeyExists(user_result, "link")>
					<cfset link = user_result.link>
				</cfif>
				<cfif structKeyExists(user_result, "locale")>
					<cfset locale = user_result.locale>
				</cfif>
				<cfif structKeyExists(user_result, "middle_name")>
					<cfset middle_name = user_result.middle_name>
				</cfif>
				<cfif structKeyExists(user_result, "name")>
					<cfset name = user_result.name>
				</cfif>
				<cfif structKeyExists(user_result, "timezone")>
					<cfset timezone = user_result.timezone>
				</cfif>

				<cfset insertFacebookUser (
					id = arguments.Id,
					age_range_min = age_range_min,
					age_range_max = age_range_max,
					birthday = birthday,
					email = email,
					first_name = first_name,
					gender = gender,
					last_name = last_name,
					link = link,
					locale = locale,
					middle_name = middle_name,
					name = name,
					timezone = timezone
				)>

			</cfif>

			<cfreturn user_result>

			<cfcatch type="any">
				<cfreturn "{'error':true}">
			</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="getLikes" output="no">

		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="id" required="yes">
		<cfargument name="until" required="no" default="">
		<cfargument name="limit" required="no" default=25>
		<cfargument name="access_token" required="no" default="">
		<cfargument name="save_results" required="no" default=false>

		<cfhttp url="#variables.api_url##arguments.id#/likes" method="get" charset="utf-8">
			<cfhttpparam type="url" name="access_token" value="#arguments.access_token#">
			<cfhttpparam type="url" name="until" value="#arguments.until#">
			<cfhttpparam type="url" name="limit" value="#arguments.limit#">
			<cfhttpparam type="url" name="fields" value="id,name">
		</cfhttp>

		<cftry>

			<cfreturn deserializeJson(cfhttp.fileContent)>

			<cfcatch type="any">
				<cfreturn "{'error':true}">
			</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="searchFacebook" output="yes">

		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="searchTerm" required="yes">
		<cfargument name="until" required="no" default="">
		<cfargument name="limit" required="no" default=25>
		<cfargument name="access_token" required="no" default="">
		<cfargument name="save_results" required="no" default=false>

		<!--- note this uses a different api version, as current versions return (#11) Post search has been deprecated --->
		<!--- https://graph.facebook.com/ --->
		<cfhttp method="get" url="#variables.unversioned_api_url#search">
			<cfhttpparam type="url" name="q" value="#arguments.searchTerm#">
			<cfhttpparam type="url" name="access_token" value="#arguments.access_token#">
			<cfhttpparam type="url" name="type" value="post">
			<cfhttpparam type="url" name="until" value="#arguments.until#">
			<cfhttpparam type="url" name="limit" value="#arguments.limit#">
			<cfhttpparam type="url" name="fields" value="id,from,story,picture,link,name,caption,type,status_type,object_id,created_time">
		</cfhttp>

		<cftry>

			<cfset search_result = deserializeJson(cfhttp.fileContent)>

			<cfif arguments.save_results>

				<cfif structKeyExists(search_result, 'data')>

					<cfloop from="1" to="#arrayLen(search_result.data)#" index="i">

						<cfset thisResult = structGet('search_result.data[#i#]')>
						<cfset id = thisResult.id>
						<cfset from_id = thisResult.from.id>
						<cfset from_name = thisResult.from.name>
						<cfset type = thisResult.type>
						<cfset created_time = thisResult.created_time><!--- sometimes this is bigint, sometimes its a string (2014-10-23T20:47:58+0000) --->

						<cfset link = "">
						<cfset name = "">
						<cfset caption = "">
						<cfset story = "">
						<cfset picture = "">
						<cfset status_type = "">
						<cfset object_id = "">

						<cfif structKeyExists(thisResult, "link")>
							<cfset link = thisResult.link>
						</cfif>
						<cfif structKeyExists(thisResult, "name")>
							<cfset name = thisResult.name>
						</cfif>
						<cfif structKeyExists(thisResult, "caption")>
							<cfset caption = thisResult.caption>
						</cfif>
						<cfif structKeyExists(thisResult, "story")>
							<cfset story = thisResult.story>
						</cfif>
						<cfif structKeyExists(thisResult, "picture")>
							<cfset picture = thisResult.picture>
						</cfif>
						<cfif structKeyExists(thisResult, "status_type")>
							<cfset status_type = thisResult.status_type>
						</cfif>
						<cfif structKeyExists(thisResult, "object_id")>
							<cfset object_id = thisResult.object_id>
						</cfif>

						<cfset created_time = convertCreatedTimeToBigint(created_time)>

						<cfset insertFacebookSearchResult (
							scheduleId = arguments.scheduleId,
							id = id,
							from_id = from_id,
							from_name = from_name,
							story = story,
							picture = picture,
							link = link,
							name = name,
							caption = caption,
							type = type,
							status_type = status_type,
							object_id = object_id,
							created_time = created_time
						)>

						<cfset getUser (
							id = from_id,
							access_token = arguments.access_token,
							save_results = arguments.save_results
						)>

					</cfloop>

				</cfif>

			</cfif>

			<cfreturn search_result>

			<cfcatch type="any">
				<cfdump var="#thisResult#">
				<cfdump var="#cfcatch#">
				<cfreturn "{'error':true}">
			</cfcatch>

		</cftry>

	</cffunction>


	<cffunction name="getSince" output="no" returntype="numeric">

		<cfargument name="scheduleId" required="no" default="">
		<cfargument name="searchTerm" required="no" default="">

		<cfquery name="getSince" datasource="#variables.dsn#">
			select coalesce(
				datediff(s, '1970-01-01', max(entryDate)),
				<cfif len(arguments.scheduleId)>
				(
					select datediff(s, '1970-01-01', startDate)
					from Schedules
					where scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				)
				<cfelse>
				0
				</cfif>
			) as since
			from uvwSelectFacebookEntries
			where 1=1
			<cfif len(arguments.scheduleId)>
				and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif len(arguments.searchTerm)>
				and searchTerm = <cfqueryparam value="#arguments.searchTerm#" cfsqltype="cf_sql_varchar">
			</cfif>
		</cfquery>

		<cfreturn getSince.since>

	</cffunction>


	<cffunction name="insertFacebookPostComment" output="no" returntype="void">

		<cfargument name="scheduleId" default="">
		<cfargument name="id" default="">
		<cfargument name="from_id" default="">
		<cfargument name="from_name" default="">
		<cfargument name="message" default="">
		<cfargument name="created_time" default="">
		<cfargument name="like_count" default="">
		<cfargument name="comment_count" default="">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from FacebookComments
				where id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin

				insert into FacebookComments (
					scheduleId,
					id,
					[from.id],
					[from.name],
					message,
					created_time,
					like_count,
					comment_count
				)
				values (
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.id#" null="#not len(arguments.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.from_id#" null="#not len(arguments.from_id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.from_name#" null="#not len(arguments.from_name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.message#" null="#not len(arguments.message)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.created_time#" null="#not len(arguments.created_time)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.like_count#" null="#not len(arguments.like_count)#" cfsqltype="cf_sql_int">,
					<cfqueryparam value="#arguments.comment_count#" null="#not len(arguments.comment_count)#" cfsqltype="cf_sql_int">
				)

			end

		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="insertFacebookLike" output="no" returntype="void">

		<cfargument name="scheduleId" default="">
		<cfargument name="pageId" default="#getToken(arguments.postId, 1, '_')#">
		<cfargument name="postId" default="">
		<cfargument name="id" default="">
		<cfargument name="name" default="">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from FacebookLikes
				where post_id = <cfqueryparam value="#arguments.postId#" cfsqltype="cf_sql_varchar">
				and user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin
				insert into FacebookLikes (
					scheduleId,
					pageId,
					postId,
					id,
					name
				)
				values (
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.pageId#" null="#not len(arguments.pageId)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.postId#" null="#not len(arguments.postId)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.id#" null="#not len(arguments.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.name#" null="#not len(arguments.name)#" cfsqltype="cf_sql_varchar">
				)
			end
		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="insertFacebookSearchResult" output="no" returntype="void">

		<cfargument name="scheduleId" default="">
		<cfargument name="id" default="">
		<cfargument name="from_id" default="">
		<cfargument name="from_name" default="">
		<cfargument name="story" default="">
		<cfargument name="picture" default="">
		<cfargument name="link" default="">
		<cfargument name="name" default="">
		<cfargument name="caption" default="">
		<cfargument name="type" default="">
		<cfargument name="status_type" default="">
		<cfargument name="object_id" default="">
		<cfargument name="created_time" default="">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from FacebookSearches
				where id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin

				insert into FacebookSearches (
					scheduleId,
					id,
					[from.id],
					[from.name],
					story,
					picture,
					link,
					name,
					caption,
					type,
					status_type,
					object_id,
					created_time
				)
				values (
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.id#" null="#not len(arguments.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.from_id#" null="#not len(arguments.from_id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.from_name#" null="#not len(arguments.from_name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.story#" null="#not len(arguments.story)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.picture#" null="#not len(arguments.picture)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.link#" null="#not len(arguments.link)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.name#" null="#not len(arguments.name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.caption#" null="#not len(arguments.caption)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.type#" null="#not len(arguments.type)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.status_type#" null="#not len(arguments.status_type)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.object_id#" null="#not len(arguments.object_id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.created_time#" null="#not len(arguments.created_time)#" cfsqltype="cf_sql_bigint">
				)

			end

		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="insertFacebookPage" output="no" returntype="void">

		<cfargument name="scheduleId" default="">
		<cfargument name="id" default="">
		<cfargument name="category" default="">
		<cfargument name="checkins" default="">
		<cfargument name="description" default="">
		<cfargument name="likes" default="">
		<cfargument name="link" default="">
		<cfargument name="name" default="">
		<cfargument name="username" default="">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from FacebookPages
				where id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin

				insert into FacebookPages (
					scheduleId,
					id,
					category,
					checkins,
					description,
					likes,
					link,
					name,
					username
				)
				values (
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.id#" null="#not len(arguments.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.category#" null="#not len(arguments.category)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.checkins#" null="#not len(arguments.checkins)#" cfsqltype="cf_sql_int">,
					<cfqueryparam value="#arguments.description#" null="#not len(arguments.description)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.likes#" null="#not len(arguments.likes)#" cfsqltype="cf_sql_int">,
					<cfqueryparam value="#arguments.link#" null="#not len(arguments.link)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.name#" null="#not len(arguments.name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.username#" null="#not len(arguments.username)#" cfsqltype="cf_sql_varchar">
				)

			end

		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="insertFacebookPageFeed" output="no" returntype="void">

		<cfargument name="scheduleId" default="">
		<cfargument name="pageId" default="">
		<cfargument name="id" default="">
		<cfargument name="from_name" default="">
		<cfargument name="from_id" default="">
		<cfargument name="message" default="">
		<cfargument name="type" default="">
		<cfargument name="link" default="">
		<cfargument name="name" default="">
		<cfargument name="caption" default="">
		<cfargument name="created_time" default="">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from FacebookPageFeeds
				where id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin

				insert into FacebookPageFeeds (
					scheduleId,
					pageId,
					id,
					[from.name],
					[from.id],
					message,
					type,
					link,
					name,
					caption,
					created_time
				)
				values (
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.pageId#" null="#not len(arguments.pageId)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.id#" null="#not len(arguments.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.from_name#" null="#not len(arguments.from_name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.from_id#" null="#not len(arguments.from_id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.message#" null="#not len(arguments.message)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.type#" null="#not len(arguments.type)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.link#" null="#not len(arguments.link)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.name#" null="#not len(arguments.name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.caption#" null="#not len(arguments.caption)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.created_time#" null="#not len(arguments.created_time)#" cfsqltype="cf_sql_bigint">
				)

			end

		</cfquery>

	</cffunction>


	<cffunction name="insertFacebookPost" output="yes" returntype="void">

		<cfargument name="scheduleId" default="">
		<cfargument name="pageId" default="">
		<cfargument name="id" default="">
		<cfargument name="from_name" default="">
		<cfargument name="from_id" default="">
		<cfargument name="message" default="">
		<cfargument name="type" default="">
		<cfargument name="status_type" default="">
		<cfargument name="object_id" default="">
		<cfargument name="created_time" default="">
		<cfargument name="shares_count" default="">
		<cfargument name="likes_count" default="">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from FacebookPosts
				where id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar">
				<cfif len(arguments.scheduleId)>
					and scheduleId = <cfqueryparam value="#arguments.scheduleId#" cfsqltype="cf_sql_integer">
				</cfif>
			)
			begin

				insert into FacebookPosts (
					scheduleId,
					pageId,
					id,
					[from.name],
					[from.id],
					message,
					type,
					status_type,
					object_id,
					created_time,
					[shares.count],
					[likes.count]
				)
				values (
					<cfqueryparam value="#arguments.scheduleId#" null="#not len(arguments.scheduleId)#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#arguments.pageId#" null="#not len(arguments.pageId)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.id#" null="#not len(arguments.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.from_name#" null="#not len(arguments.from_name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.from_id#" null="#not len(arguments.from_id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.message#" null="#not len(arguments.message)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.type#" null="#not len(arguments.type)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.status_type#" null="#not len(arguments.status_type)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.object_id#" null="#not len(arguments.object_id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.created_time#" null="#not len(arguments.created_time)#" cfsqltype="cf_sql_bigint">,
					<cfqueryparam value="#arguments.shares_count#" null="#not len(arguments.shares_count)#" cfsqltype="cf_sql_int">,
					<cfqueryparam value="#arguments.likes_count#" null="#not len(arguments.likes_count)#" cfsqltype="cf_sql_int">
				)

			end

		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="insertFacebookUser" output="no" returntype="void">

		<cfargument name="id" required="yes">
		<cfargument name="age_range_min" default="">
		<cfargument name="age_range_max" default="">
		<cfargument name="birthday" default="">
		<cfargument name="email" default="">
		<cfargument name="first_name" default="">
		<cfargument name="gender" default="">
		<cfargument name="last_name" default="">
		<cfargument name="link" default="">
		<cfargument name="locale" default="">
		<cfargument name="middle_name" default="">
		<cfargument name="name" default="">
		<cfargument name="timezone" default="">

		<cfquery datasource="#variables.dsn#">
			if not exists (
				select 1
				from FacebookUsers
				where id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar">
			)
			begin

				insert into FacebookUsers (
					id,
					[age_range.min],
					[age_range.max],
					birthday,
					email,
					first_name,
					gender,
					last_name,
					link,
					locale,
					middle_name,
					name,
					timezone
				)
				values (
					<cfqueryparam value="#arguments.id#" null="#not len(arguments.id)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.age_range_min#" null="#not len(arguments.age_range_min)#" cfsqltype="cf_sql_int">,
					<cfqueryparam value="#arguments.age_range_max#" null="#not len(arguments.age_range_max)#" cfsqltype="cf_sql_int">,
					<cfqueryparam value="#arguments.birthday#" null="#not len(arguments.birthday)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.email#" null="#not len(arguments.email)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.first_name#" null="#not len(arguments.first_name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.gender#" null="#not len(arguments.gender)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.last_name#" null="#not len(arguments.last_name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.link#" null="#not len(arguments.link)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.locale#" null="#not len(arguments.locale)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.middle_name#" null="#not len(arguments.middle_name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.name#" null="#not len(arguments.name)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.timezone#" null="#not len(arguments.timezone)#" cfsqltype="cf_sql_int">
				)

			end

		</cfquery>

		<cfreturn>

	</cffunction>


	<cffunction name="convertCreatedTimeToBigint" output="no" returntype="numeric">
		<cfargument name="created_time" required="yes" type="string">
		<!--- I take a FB created_time (either as a string () or as a bigint()) and return the bigint representation for consistency --->
		<cfif findNoCase('T', arguments.created_time)>
			<cfset created_date = listFirst(arguments.created_time, 'T')>
			<cfset created_time = listLast(listFirst(arguments.created_time, '+'), 'T')>
			<cfset created_date_time = createDateTime(year(created_date), month(created_date), day(created_date), hour(created_time), minute(created_time), second(created_time))>
			<cfreturn dateDiff('s', '1970-01-01', created_date_time)>
		</cfif>
		<cfreturn arguments.created_time>
	</cffunction>


	<cffunction name="convertCreatedTimeToString" output="no" returntype="string">
		<cfargument name="created_time" required="yes" type="string">
		<cfargument name="toLocalTime" required="no" default=false>
		<cfset created_time = convertCreatedTimeToBigint(arguments.created_time)>
		<cfset created_date_time = dateAdd('s', created_time, '1970-01-01')>
		<cfif toLocalTime>
			<cfset created_date_time = dateConvert('utc2local', created_date_time)>
		</cfif>
		<cfreturn "#dateFormat(created_date_time, 'yyyy-mm-dd')# #timeFormat(created_date_time, 'HH:mm:ss')#">
	</cffunction>


</cfcomponent>