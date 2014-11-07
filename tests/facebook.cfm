<!--- KEEP THIS FOR POSTERITY, CAUSE ITS A GOOD EXAMPLE AS OF 10302013 --->
<!--- https://developers.facebook.com/tools/explorer?method=GET&path=search%3Fq%3D%22Jethro%20Tull%22%26type%3Dpost%26updated_time%3E1347494400 --->

<cfparam name="form.searchTerm" default="">

<h1 class="page-header">
	Facebook
	<span class="pull-right">
		<button class="btn btn-success btn-sm monitor-facebook-term-button" data-scheduleid="" data-searchterm="" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor new search term">
			<span class="glyphicon glyphicon-plus"></span>
		</button>
		<a href="schedules.cfm?service=Facebook"><button class="btn btn-sm btn-warning">Monitored</button></a>
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
				<input type="text" class="form-control" id="searchTerm" name="searchTerm" placeholder="Hash tags are not allowed, and will be stripped out, but multiple terms are OK" value="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>">
			</div>
			<button type="submit" class="btn btn-default">Submit</button>
			<cfif len(form.searchTerm)>
				<button class="btn btn-success btn-xs monitor-facebook-term-button" data-scheduleid="" data-searchterm="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor this term">
					<span class="glyphicon glyphicon-eye-open"></span>
				</button>
			</cfif>
		</form>
	</div>

</div>

<cfif len(form.searchTerm)>

	<!--- lop off hash --->
	<cfset form.searchTerm = replace(form.searchTerm, '##', '', 'All')>

	<!--- "random" search --->


	<!--- get page --->
	<!--- get page feed (this may actually be the endpoint i want, as 'posts' is basically a filtered version of this) --->
	<!--- get page posts --->
	<!--- get post comments --->
	<!--- get page likes --->
	<!--- get post likes --->
	<!--- get post comment likes --->
	<!--- get post object comments ( --->


	<!--- (#11) Post search has been deprecated --->
	<!--- <cfhttp method="get" url="https://graph.facebook.com/v2.1/search">
		<cfhttpparam type="url" name="q" value="#form.searchTerm#">
		<cfhttpparam type="url" name="access_token" value="#credentials.facebook.page_access_token#">
		<cfhttpparam type="url" name="type" value="post">
	</cfhttp> --->


	<cfset init("Facebook")>
	<cfset since = oFacebook.getSince()>

	<cfset search_result = oFacebook.searchFacebook (
		searchTerm = form.searchTerm,
		since = since,
		access_token = credentials.facebook.page_access_token
	)>
	<!--- <cfdump var="#search_result#"> --->

	<cfdump var="#oFacebook.parseSearchObject(search_result.data[1])#">


	<!--- <cfset page_result = oFacebook.getPage(searchTerm=form.searchTerm, since=since, access_token=credentials.facebook.page_access_token)>
	<cfif structKeyExists(page_result, 'data')>
		<h1>Pages</h1>
		<div class="table-responsive">
			<table class="table table-condensed table-striped">
				<thead>
					<tr>
						<th></th>
						<th>id</th>
						<th>name</th>
						<th>likes</th>
					</tr>
				</thead>
				<tbody>
					<cfloop from="1" to="#arrayLen(page_result.data)#" index="ndx">
						<!--- <cfdump var="#page_result.data[ndx]#"> --->
						<cfset page = structGet('page_result.data[#ndx#]')>
						<cfset id = page.id>
						<!--- <cfset name = oFacebook.getPageName(pageId=id, access_token=credentials.facebook.page_access_token)> --->
						<cfset name = page.name>
						<cfset likes = 0>
						<cfif structKeyExists(page, 'likes')>
							<cfset likes = page.likes>
						</cfif>
						<cfoutput>
							<tr>
								<td>#ndx#</td>
								<td>#id#</td>
								<td>#name#</td>
								<td>#numberFormat(likes, ",")#</td>
							</tr>

							<cfif ndx eq 1>

								<cfset feed_result = oFacebook.getPageFeed(pageId=id, since=since, access_token=credentials.facebook.page_access_token)>
								<tr>
									<td>&nbsp;</td>
									<td colspan="3">

										<h1>Page Feed</h1>
										<div class="table-responsive">
											<table class="table table-condensed table-striped">
												<thead>
													<tr>
														<th></th>
														<th>id</th>
														<th>from</th>
														<th>message</th>
														<th>type</th>
														<th>created_time</th>
													</tr>
												</thead>
												<tbody>
													<cfloop from="1" to="#arrayLen(feed_result.data)#" index="i">
														<cfset feed = structGet('feed_result.data[#i#]')>
														<tr>
															<td>#i#</td>
															<td>#feed.id#</td>
															<td>#feed.from.name#</td>
															<td>#feed.message#</td>
															<td>#feed.type#</td>
															<td>#feed.created_time#</td>
														</tr>
													</cfloop>
												</tbody>
											</table>
										</div>

									</td>
								</tr>

							</cfif>

						</cfoutput>
					</cfloop>
				</tbody>
			</table>
		</div>
	</cfif> --->
	<!--- <cfdump var="#page_result#"> --->

	<!--- <cfset feed_result = oFacebook.getPageFeed(pageId=page_result.data[1].id, access_token=credentials.facebook.page_access_token)>
	<cfdump var="#feed_result#">

	<cfset post_result = oFacebook.getPost(postId=feed_result.data[1].id, access_token=credentials.facebook.page_access_token)>
	<cfdump var="#post_result#"> --->

	<!--- <cfhttp method="get" url="https://graph.facebook.com/search">
		<cfhttpparam type="url" name="q" value="#form.searchTerm#">
		<cfhttpparam type="url" name="access_token" value="#credentials.facebook.page_access_token#">
		<cfhttpparam type="url" name="type" value="post">
	</cfhttp>

	<cfset searchResult = deserializeJson(cfhttp.fileContent)>
	<cfloop from="1" to="#arrayLen(searchResult.data)#" index="ndx">
		<cfset thisResult = structGet('searchResult.data[#ndx#]')>
		<cfset id = "">
		<cfset from.name = "">
		<cfset from.id = "">
		<cfset message = "">
		<cfset type = "">
		<cfset status_type = "">
		<cfset object_id = "">
		<cfset created_time = "">
		<cfset shares.count = "">
		<cfset likes.count = "">

		<cfset id = thisResult.id>
		<cfset from.name = thisResult.from.name>
		<cfset from.id = thisResult.from.id>
		<cfset type = thisResult.type>
		<cfset created_time = thisResult.created_time>

		<cfif structKeyExists(thisResult, 'message')>
			<cfset message = thisResult.message>
		</cfif>
		<cfif structKeyExists(thisResult, 'status_type')>
			<cfset status_type = thisResult.status_type>
		</cfif>
		<cfif structKeyExists(thisResult, 'object_id')>
			<cfset object_id = thisResult.object_id>
		</cfif>
		<cfif structKeyExists(thisResult, 'shares.count')>
			<cfset shares.count = thisResult.shares.count>
		</cfif>
		<cfif structKeyExists(thisResult, 'likes')>
			<cfset likes.count = arrayLen(thisResult.likes.data)>
		</cfif>

		<cfdump var="#thisResult#">
	</cfloop> --->

</cfif>




<cfset onRequestEnd(cgi.script_name)>
<cfabort>









<div class="panel panel-primary">

	<div class="panel-heading">
		<p class="panel-title"><strong>Look up page</strong></p>
	</div>

	<div class="panel-body">
		<form name="lookup-page">
			<div class="form-group">
				<label for="pageId">Page name</label>
				<input type="text" class="form-control" id="pageId" name="pageId">
			</div>
			<div class="checkbox">
				<label>
					<input type="checkbox" name="managed_pages" id="managed_pages" value="1">
					Only show pages I manage
				</label>
			</div>
			<button type="submit" class="btn btn-default">Submit</button>
		</form>
	</div>

	<!--- <div class="panel-body">

		<div id="lookup-page-results-wrapper" style="display:none;">
			<!--- <div id="lookup-page-results-count"></div> --->
			<div id="lookup-page-results">
				<div class="table-responsive">
					<a name="pages"></a>
					<table class="table table-striped" id="lookup-page-results-table">
						<caption id="lookup-page-results-count"></caption>
						<thead>
							<tr>
								<th>Page</th>
								<th>Link</th>
								<th>Actions</th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
				</div>
			</div>
		</div>

	</div> --->


	<div class="panel-body">

		<a name="pages" class="anchor"></a>
		<div id="lookup-page-results-wrapper" style="display:none;">
			<!--- <div id="lookup-page-results-count"></div> --->
			<div id="lookup-page-results">
				<div class="table-responsive">
					<table class="table table-striped" id="lookup-page-results-table">
						<caption id="lookup-page-results-count"></caption>
						<thead>
							<tr>
								<th>Page</th>
								<th>Link</th>
								<th>Actions</th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
				</div>
			</div>
		</div>

		<a name="posts" class="anchor"></a>
		<div id="lookup-posts-results-wrapper" style="display:none;">
			<!--- <div id="lookup-posts-results-count"></div> --->
			<div id="lookup-posts-results">
				<div class="table-responsive">
					<table class="table table-striped" id="lookup-posts-results-table">
						<caption id="lookup-posts-results-count"></caption>
						<thead>
							<tr>
								<th>
									Post
									<div class="pull-right">

										<form name="lookup-post" style="display:none;" class="form-inline">
											<div class="form-group">
												<label for="query" class="sr-only">Post contains&hellip;</label>
												<input type="text" class="form-control input-sm" id="query" name="query">
											</div>
											<button type="submit" class="btn btn-default btn-xs">Search</button>
										</form>

									</div>
								</th>
								<th>Comments</th>
								<th>Likes</th>
								<th>Shares</th>
								<th>Actions</th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
				</div>
			</div>
		</div>

		<a name="comments" class="anchor"></a>
		<div id="lookup-comments-results-wrapper" style="display:none;">
			<!--- <div id="lookup-comments-results-count"></div> --->
			<div id="lookup-comments-results">
				<div class="table-responsive">
					<table class="table table-striped" id="lookup-comments-results-table">
						<caption id="lookup-comments-results-count"></caption>
						<thead>
							<tr>
								<th>Comment</th>
								<th>From</th>
								<th>When</th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
				</div>
			</div>
		</div>


		<a name="likes" class="anchor"></a>
		<div id="lookup-likes-results-wrapper" style="display:none;">
			<!--- <div id="lookup-likes-results-count"></div> --->
			<div id="lookup-likes-results">
				<div class="table-responsive">
					<table class="table table-striped" id="lookup-likes-results-table">
						<caption id="lookup-likes-results-count"></caption>
						<thead>
							<tr>
								<th>Id</th>
								<th>Name</th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
				</div>
			</div>
		</div>

	</div>

</div>






