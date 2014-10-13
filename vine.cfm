<!---
https://github.com/starlock/vino/wiki/API-Reference
--->

<cfparam name="form.searchTerm" default="">

<h1 class="page-header">
	Vine
	<span class="pull-right">
		<button class="btn btn-success btn-sm monitor-vine-term-button" data-scheduleid="" data-searchterm="" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor new search term">
			<span class="glyphicon glyphicon-plus"></span>
		</button>
		<a href="vine_monitored.cfm"><button class="btn btn-sm btn-warning">Monitored</button></a>
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
				<input type="text" class="form-control" id="searchTerm" name="searchTerm" placeholder="" value="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>">
			</div>
			<button type="submit" class="btn btn-default">Submit</button>
			<cfif len(form.searchTerm)>
				<button class="btn btn-success btn-xs monitor-vine-term-button" data-scheduleid="" data-searchterm="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor this term">
					<span class="glyphicon glyphicon-eye-open"></span>
				</button>
			</cfif>
		</form>
	</div>

</div>

<cfif len(form.searchTerm)>

	<cfset q = URLEncodedFormat(form.searchTerm)>
	<cfset since_id = "">

	<cftry>

		<cfhttp method="get" url="https://api.vineapp.com/timelines/tags/#form.searchTerm#" charset="utf-8"></cfhttp>
		<cfset searchResult = deserializeJson(cfhttp.fileContent)>

		<!---
		avatarUrl
		created
		description
		explicitContent
		permalinkUrl
		postId
		thumbnailUrl
		userId
		username
		videoLowUrl
		videoUrl
		--->


		<!--- <cfset userid = searchResult.data.records[1].userid><!--- 914755310672035840 --->
		<cfoutput>
			<p>userid: #userid#</p><!--- 9.14755310672E+017 --->
			<p>numberformat(#userid#, #repeatString('9', 20)#): #numberFormat(userid, repeatString('9', 20))#</p><!--- 914755310672035840 --->
			<p>numberformat(#userid#): #numberFormat(userid)#</p><!--- 914,755,310,672,035,840 --->
			<p>precisionEvaluate(#userid#).toPlainString(): #precisionEvaluate(userid).toPlainString()#</p><!--- 914755310672000000 --->
			<p>createObject('java', 'java.math.BigDecimal').init(#userid#): #createObject('java', 'java.math.BigDecimal').init(userid)#</p><!--- 914755310672035840 --->
			<p>convertNum(#userid#): #convertNum(userid)#</p>
		</cfoutput> --->


		<!--- only returns 20 records at a time --->
		<cfset searchCount = 0>
		<cfset searchCount += searchResult.data.count>
		<cfset pages = ceiling(searchCount / 20)>

		<div class="table-responsive">
			<table class="table table-striped" id="lookup-results-table">
				<caption id="lookup-results-count"></caption>
				<thead>
					<tr>
						<th>#</th>
						<!--- <th>Video</th> --->
						<th>User</th>
						<th>User Id</th>
						<th>Created</th>
						<th>Description</th>
						<th>Permalink</th>
						<!--- <th>raw</th> --->
					</tr>
				</thead>
				<tbody>

					<cfloop from="1" to="#pages#" index="page">

						<cfhttp method="get" url="https://api.vineapp.com/timelines/tags/#form.searchTerm#?page=#page#" charset="utf-8"></cfhttp>
						<cfset pageResult = deserializeJson(cfhttp.fileContent)>
						<cfset pageCount = arrayLen(pageResult.data.records)>

						<cfloop from="1" to="#pageCount#" index="ndx">

							<cftry>

								<cfset thisResult = structGet('pageResult.data.records[#ndx#]')>

								<cfoutput>

									<tr <cfif thisResult.explicitContent>class="danger"</cfif>>
										<td>#ndx + ((page-1)*20)#</td>
										<cfif not structIsEmpty(thisResult)>
											<!--- <td><video preload="auto" src="#thisResult.videoUrl#" width="535" height="535"></video></td> --->
											<td><img src="#thisResult.avatarUrl#" alt="#thisResult.username#" style="width: 38px;height: 38px;border-radius: 50%;"></td>
											<td>#convertNum(thisResult.userId)#</td>
											<td>#getToken(thisResult.created, 1, 'T')#</td><!--- eg 2014-07-03T01:50:52.000000 --->
											<td>#thisResult.description#</td>
											<td><a href="#thisResult.permalinkUrl#" target="_blank"><img src="#thisResult.thumbnailUrl#" style="width:50px;height:50px;"></a></td>
										</cfif>
										<!--- <td class="view-raw"><div style="display:none;"><cfdump var="#thisResult#"></div></td> --->
									</tr>

								</cfoutput>

								<cfcatch type="any">
									<cfdump var="#cfcatch#">
									<cfdump var="#thisResult#">
									<cfabort>
								</cfcatch>

							</cftry>

						</cfloop>

					</cfloop>

				</tbody>

			</table>

		</div>

		<cfcatch type="any">
			<cfdump var="#cfcatch#">
		</cfcatch>

	</cftry>

</cfif>

<script>
	$(function(){
		$(document).on('click', '.view-raw', function(){
			$(this).find('div').show();
		});
	});
</script>

<!--- convert the scientific notation number of the long user/post/whatever ids to the actual value --->
<cffunction name="convertNum" returntype="string">
	<cfargument name="num" required="yes">
	<cfset bigD = createObject('java', 'java.math.BigDecimal')>
	<cfreturn bigD.init(arguments.num)>
</cffunction>


<cffunction name="getVineUser" returntype="struct">
	<cfargument name="userId" required="yes"><!--- userId should first be passed to the convertNum function when calling this function --->
	<cfhttp method="get" url="https://api.vineapp.com/users/profiles/#arguments.userId#"></cfhttp>
	<cfreturn deserializeJson(cfhttp.fileContent).data>
</cffunction>