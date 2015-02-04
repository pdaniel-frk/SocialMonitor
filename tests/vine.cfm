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
		<a href="schedules.cfm?service=Vine"><button class="btn btn-sm btn-warning">Monitored</button></a>
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
	<cfset init("Vine")>

	<cftry>

		<div class="alert alert-warning">Note: This works on localhost and mk02, but fails on production server.</div>

		<cfset searchResult = oVine.searchVine(searchTerm=form.searchTerm)>

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

						<cfset pageResult = oVine.searchVine(searchTerm=form.searchTerm, page=page)>
						<cfset pageCount = arrayLen(pageResult.data.records)>

						<cfloop from="1" to="#pageCount#" index="ndx">

							<cftry>

								<cfset thisResult = structGet('pageResult.data.records[#ndx#]')>
								<cfset obj = oVine.parseVineObject(vine=thisResult)>
								<cfset user = oVine.parseUserObject(oVine.getVineUser(userId=obj.userId))>

								<cfdump var="#obj#">

								<cfdump var="#user#">

								<cfoutput>

									<tr <cfif obj.explicitContent>class="danger"</cfif>>
										<td>#ndx + ((page-1)*20)#</td>
										<cfif not structIsEmpty(obj)>
											<!--- <td><video preload="auto" src="#thisResult.videoUrl#" width="535" height="535"></video></td> --->
											<td><img src="#user.avatarUrl#" alt="#user.username#" style="width: 38px;height: 38px;border-radius: 50%;"></td>
											<td>#obj.userId#</td>
											<td>#obj.created#</td>
											<td>#obj.description#</td>
											<td><a href="#obj.permalinkUrl#" target="_blank"><img src="#obj.thumbnailUrl#" style="width:50px;height:50px;"></a></td>
										</cfif>
									</tr>

								</cfoutput>

								<cfcatch type="any">
									<cfdump var="#cfcatch#">
									<cfdump var="#obj#">
									<cfdump var="#user#">
									<cfabort>
								</cfcatch>

							</cftry>

						</cfloop>

					</cfloop>

				</tbody>

			</table>

		</div>

		<cfcatch type="any">
			<cfdump var="#cfhttp#" label="cfhttp">
			<cfdump var="#cfhttp.fileContent#" label="cfhttp.filecontent">
			<cfdump var="#cfcatch#" label="cfcatch">
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