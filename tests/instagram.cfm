<p>looking up friends</p>

<cfset userIds = "249422808,
823063352">

<cfloop list="#userIds#" index="userId">

	<p>
	<cfoutput>#userId#: </cfoutput>
	<cfhttp method="get" url="https://api.instagram.com/v1/users/#userId#/follows">
		<cfhttpparam type="url" name="client_id" value="#credentials.instagram.client_id#">
		<cfhttpparam type="url" name="count" value="100">
	</cfhttp>

	<cftry>

		<cfset follows = deserializeJson(cfhttp.fileContent)>
		<cfoutput><strong>#arrayLen(follows.data)#</strong> 'follows' found</cfoutput>

		<cfloop from="1" to="#arrayLen(follows.data)#" index="i">
			<cfset user = structGet('follows.data[#i#]')>
			<!--- <cfdump var="#user#"> --->
			<cfif compareNoCase(user.full_name, "office") eq 0 or compareNoCase(user.username, "office") eq 0>
				<strong>office found in this users friends</strong>
				<cfbreak>
			</cfif>
		</cfloop>



		<cfcatch type="any">
			<cfdump var="#cfhttp#">
		</cfcatch>

	</cftry>


	</p>

	<!--- Your credentials do not allow access to this resource (can only get this information on behalf of authenticated users) --->
	<!--- <cfset result = application.objMonkehTweet.getFriendshipsLookup(user_id=userId)> --->

	<!--- <cfdump var="#result#">
	<cfabort> --->


</cfloop>

<cfabort>

<cfprocessingdirective pageencoding="utf-8">
<cfparam name="form.searchTerm" default="">

<h1 class="page-header">
	Instagram
	<span class="pull-right">
		<button class="btn btn-success btn-sm monitor-instagram-term-button" data-scheduleid="" data-searchterm="" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor new search term">
			<span class="glyphicon glyphicon-plus"></span>
		</button>
		<a href="schedules.cfm?service=Instagram"><button class="btn btn-sm btn-warning">Monitored</button></a>
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
				<input type="text" class="form-control" id="searchTerm" name="searchTerm" placeholder="Currently only one tag/term at a time is supported" value="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>">
			</div>
			<button type="submit" class="btn btn-default">Submit</button>
			<cfif len(form.searchTerm)>
				<button class="btn btn-success btn-xs monitor-instagram-term-button" data-scheduleid="" data-searchterm="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor this term">
					<span class="glyphicon glyphicon-eye-open"></span>
				</button>
			</cfif>
		</form>
	</div>

</div>

<cfif len(form.searchTerm)>
	<!--- lop off hash --->
	<cfset form.searchTerm = replace(form.searchTerm, '##', '', 'All')><!--- using # or %23 leads to a 404; --->
	<!--- with no since_id, it'll crawl back FOREVER, so give it something reasonable as a minimum' --->
	<!--- <cfset since_id = "1405036800000"> ---><!--- select cast(abs(dateDiff(s, '2014-07-11', '1970-01-01')) as bigint)*1000 --->

	<cfset init("Instagram")>
	<cfset since_id = oInstagram.getSinceId(searchTerm=form.searchTerm)>

	<cfset min_tag_id = "#since_id#">
	<cfset max_tag_id = "">
	<cfset EOF = false>
	<cfset sanityCheck = 10>
	<cfset loopCount = 0>
	<cfset searchCount = 0>
	<cfset counter = 1>

	<!--- http://instagram.com/developer/endpoints/tags/
PARAMETERS
COUNT	Count of tagged media to return.
MIN_TAG_ID	Return media before this min_tag_id.
MAX_TAG_ID	Return media after this max_tag_id. --->

	<div class="table-responsive">
		<table class="table table-striped" id="lookup-results-table">
			<caption id="lookup-results-count"></caption>
			<thead>
				<tr>
					<th>#</th>
					<th>Created</th>
					<th>Name</th>
					<th>Thumb</th>
					<th>Caption/Tags</th>
				</tr>
			</thead>
			<tbody>

				<cfloop condition="NOT EOF">

					<!--- the call will return up to 20(30?) of the most recently-tagged items, so we may need to work backward until were at or before the min_tag_id parameter --->
					<cfset url_to_call = "https://api.instagram.com/v1/tags/#form.searchTerm#/media/recent?client_id=#credentials.instagram.client_id#&min_tag_id=#min_tag_id#&max_tag_id=#max_tag_id#&count=50">
					<cfhttp method="get" url="#url_to_call#"></cfhttp>

					<!--- <cfdump var="#cfhttp#"> --->

					<cfset result = deserializeJson(cfhttp.fileContent)>

					<cfif not structKeyExists(result, "error") and not structKeyExists(result.meta, "error_message")>

						<cfif arrayLen(result.data)>

							<cfloop from="1" to="#arrayLen(result.data)#" index="ndx">

								<cfset thisResult = structGet("result.data[#ndx#]")>
								<cfset instagram = oInstagram.parseInstagramObject(instagram=thisResult)>

								<cftry>

									<cfset createdTime = dateAdd('s', instagram.created_time, createDateTime(1970, 1, 1, 0, 0, 0))>

									<cfoutput>
										<tr>
											<td>#counter#</td>
											<td style="white-space:nowrap;">
												#dateFormat(createdTime, 'yyyy-mm-dd')#<br>#timeFormat(createdTime, 'hh:mm:ss TT')#
											</td>
											<td>#instagram.user.full_name#</td>
											<td>
												<a href="#instagram.link#" target='_blank'><!---
													 ---><img src="#instagram.images.thumbnail.url#" style="width:100px;height:100px;border-radius:25%;">
												</a>
											</td>
											<td>
												#instagram.caption.text#<br>
												#instagram.tags#
											</td>
										</tr>
									</cfoutput>

									<cfcatch type="any">
										<cfdump var="#cfcatch#">
										<cfdump var="#instagram#">
										<cfabort>
									</cfcatch>

								</cftry>

								<cfset counter += 1>

							</cfloop>

							<cfset loopCount += 1>
							<cfif loopCount gte sanityCheck>
								<cfset EOF = true>

								<div class="alert alert-warning">
									 <button type="button" class="close" data-dismiss="alert">&times;</button>
									 <cfoutput>Loop count exceeded sanity check for term #form.searchTerm#</cfoutput>
								</div>
							</cfif>

							<cfif structKeyExists(result.pagination, "next_max_id")>

								<cfset max_tag_id = result.pagination['next_max_id']>

								<cfif numberFormat(max_tag_id) LTE numberFormat(min_tag_id)>

									<cfset EOF = true>

								</cfif>

							<cfelse>

								<cfset EOF = true>

							</cfif>

						<cfelse>

							<cfset EOF = true>

						</cfif><!--- </cfif arrayLen(result.data)> --->

					<cfelse>

						<!--- handle errors as you see fit --->
						<!--- <cfdump var="#result#"> --->
						<tr><td colspan="100"><cfif structKeyExists(result, "error")><cfoutput>#result.error#</cfoutput><cfelseif structKeyExists(result.meta, "error_message")><cfoutput>#result.meta.error_message#</cfoutput></cfif></td></tr>
						<cfset EOF = true>

					</cfif><!--- </cfif not structKeyExists(result, "error")> --->

				</cfloop><!--- </cfloop condition="NOT EOF"> --->

			</tbody>
		</table>
	</div>

</cfif>
