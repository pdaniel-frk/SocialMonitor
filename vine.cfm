<!---
https://github.com/starlock/vino/wiki/API-Reference

--->

<cfparam name="form.searchTerm" default="">

<h1 class="page-header">
	Vine
	<span class="pull-right">
		<button class="btn btn-success btn-small monitor-vine-term-button" data-scheduleid="" data-searchterm="" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor new search term">
			<span class="glyphicon glyphicon-eye-open"></span>
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
				<button class="btn btn-success btn-small monitor-twitter-term-button" data-scheduleid="" data-searchterm="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor this term">
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

		<cfhttp method="get" url="https://api.vineapp.com/timelines/tags/#form.searchTerm#"></cfhttp>
		<cfset searchResult = deserializeJson(cfhttp.fileContent)>
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
						<!--- <th></th> --->
						<th>User</th>
						<th>User Id</th>
						<th>Created</th>
						<th>Description</th>
						<th>Permalink</th>
						<th>raw</th>
					</tr>
				</thead>
				<tbody>

					<cfloop from="1" to="#pages#" index="page">

						<cfhttp method="get" url="https://api.vineapp.com/timelines/tags/#form.searchTerm#?page=#page#" charset="utf-8"></cfhttp>
						<cfset pageResult = deserializeJson(cfhttp.fileContent)>
						<cfset pageCount = arrayLen(pageResult.data.records)>

						<cfloop from="1" to="#pageCount#" index="ndx">

							<cftry>

								<cfset record = structGet('pageResult.data.records[#ndx#]')>

								<tr <cfif record.explicitContent>class="danger"</cfif>>
									<td><cfoutput>#ndx + ((page-1)*20)#</cfoutput></td>
									<cfif not structIsEmpty(record)>
										<!--- <td><video preload="auto" src="<cfoutput>#record.videoUrl#</cfoutput>" width="535" height="535"></video></td> --->
										<td><cfoutput><img src="#record.avatarUrl#" alt="#record.username#" style="width: 38px;height: 38px;border-radius: 50%;"></cfoutput></td>
										<td><cfoutput>#record.userId#</cfoutput></td>
										<td><cfoutput>#getToken(record.created, 1, 'T')#</cfoutput></td><!--- eg 2014-07-03T01:50:52.000000 --->
										<td><cfoutput>#record.description#</cfoutput></td>
										<td><cfoutput><a href="#record.permalinkUrl#" target="_blank"><img src="#record.thumbnailUrl#" style="width:50px;height:50px;"></a></cfoutput></td>
									</cfif>
									<td class="view-raw"><div style="display:none;"><cfdump var="#record#"></div></td>
								</tr>

								<cfcatch type="any">
									<cfdump var="#cfcatch#">
									<cfdump var="#record#">
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

