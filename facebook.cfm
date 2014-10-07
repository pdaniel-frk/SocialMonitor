<!--- KEEP THIS FOR POSTERITY, CAUSE ITS A GOOD EXAMPLE AS OF 10302013 --->
<!--- https://developers.facebook.com/tools/explorer?method=GET&path=search%3Fq%3D%22Jethro%20Tull%22%26type%3Dpost%26updated_time%3E1347494400 --->

<!--- I PROBABLY NEED A PAGE ACCESS TOKEN, AS THEY ARE NON-EXPIRING --->
<!--- Marden Kane, Inc. PAGE ACCESS TOKEN: --->
<!--- DID THIS: went to https://developers.facebook.com/tools/explorer; created access token w/ extended permissions - manage_pages; called /get/user-id/accounts; copied access token for Marden Kane FB page --->

<!--- NOT TRUE BY DEFAULT! THEY EXPIRE AFTER 1 OR 2 HOURS; NEED TO LOOK INTO GENERATING A NON-EXPIRING TOKEN --->
<!--- GOOD STARTING INFO HERE: --->
<!--- http://stackoverflow.com/questions/7696372/facebook-page-access-tokens-do-these-expire --->
<!--- follow steps in this post (which involves a lot of cut-and-paste URL munging) --->
<!--- http://stackoverflow.com/questions/10183625/extending-facebook-page-access-token/13477999#13477999 --->

<!---
1: https://graph.facebook.com/oauth/authorize?client_id=173323626157418&scope=manage_pages&redirect_uri=http://www.facebook.com/connect/login_success.html
1b: this is tricky, cause FB blanks the address bar, so you need to be ready to select all and copy
    http://www.facebook.com/connect/login_success.html?code=AQBedV_aWRQHkH4_CabKiUsLvyNAz_B_rik5VxQ0KMTFl3Jw7jzzi4ci0foW72OYTRMbGdHPD1iv4UDmAANYO-IIw6-gs8kc2A-U98NLKL3Lc7mJPp0xgUCX7-4sv7oFDEgNRhhEMZef4AlR2F8wxaM8BgYhB_1DtmgkgQu9PPDTyrcUQKOkNS10tZvwHFrN7e-bLLzeb-5g2Z_zeSXqBH2x-xbgIZMqbWKSB5lJmNvZYRuAJLPsehQKdha9PoT6u4uqoa0z9ScKZ8Qln0IfGS04r9vJ-775R74rP8pUEarwDm80v7Znys06Et5Mw69pFfk#_=_
    https://www.facebook.com/connect/login_success.html?code=AQDQBgvfiC_gM2UgHMvWsRABTFvFyRd-HSU5gSJvuCmSNyJAPkm2_14RZKSK6ZUwz8xdAZ3xOD-Y7twxLe7saCfFQPBcyO4dJN3Tt9nJnPkS67JPjqROTOJ5OF1Dtzl3LEmYL-JHtaMJwY8oY2eVZL-1mMxVJc9TF7icxW1ZmfiYLopEc5aPt3Tx4mE-wAji6Zf8PvyqVR6kla0NdLl3qkTB6KiNAxet2tUBigWoY_Jx4h8tSXQr1EpiMFbOWoRfCc04Cz8iX739dpJ_l75d1eUn8lyix8KkxCxRk_F_nrG_JvkZUwDmGnDOD42hX0qEgSY#_=_
2: https://graph.facebook.com/oauth/access_token?client_id=173323626157418&redirect_uri=http://www.facebook.com/connect/login_success.html&client_secret=72ccc33faaab61f18a27e7ebcb0cec2e&code=AQBedV_aWRQHkH4_CabKiUsLvyNAz_B_rik5VxQ0KMTFl3Jw7jzzi4ci0foW72OYTRMbGdHPD1iv4UDmAANYO-IIw6-gs8kc2A-U98NLKL3Lc7mJPp0xgUCX7-4sv7oFDEgNRhhEMZef4AlR2F8wxaM8BgYhB_1DtmgkgQu9PPDTyrcUQKOkNS10tZvwHFrN7e-bLLzeb-5g2Z_zeSXqBH2x-xbgIZMqbWKSB5lJmNvZYRuAJLPsehQKdha9PoT6u4uqoa0z9ScKZ8Qln0IfGS04r9vJ-775R74rP8pUEarwDm80v7Znys06Et5Mw69pFfk#_=_
3: copy/paste the access token from this page and hope for the best

 --->

<cfparam name="form.searchTerm" default="">

<h1 class="page-header">
	Facebook
	<span class="pull-right"><a href="facebook_monitored.cfm"><button class="btn btn-sm btn-warning">Monitored</button></a></span>
</h1>

<div id="facebook-logged-out" style="position:absolute;top:0;right:0;left:0;bottom:0;padding:10em;background-color:rgba(0,0,0,.4);z-index:2;display:none;">

	<div class="alert alert-danger">
		Please log in to Facebook and grant this application the requested permissions to continue.
	</div>
	<button class="btn btn-primary" id="fb-login">Log in to Facebook</button>

</div>

<cfif structKeyExists(form, "searchKey")>
	<cfif structKeyExists(form, "searchTerm") and len(form.searchTerm)>
		<!--- lop off hash --->
		<cfset form.searchTerm = replace(form.searchTerm, '##', '', 'All')><!---  --->
		<!--- <cfhttp method="get" url="https://graph.facebook.com/search?q=""#form.searchTerm#""&type=post&access_token=#credentials.facebook.page_access_token#"></cfhttp> --->
		<!--- <cfdump var="#cfhttp#"> --->
		<!--- <cfdump var="#cfhttp.fileContent#"> --->

		<cfhttp method="get" url="https://graph.facebook.com/search">
			<cfhttpparam type="url" name="q" value="#form.searchTerm#">
			<cfhttpparam type="url" name="access_token" value="#credentials.facebook.page_access_token#">
			<cfhttpparam type="url" name="type" value="post">
		</cfhttp>
		<cfset search_result = deserializeJson(cfhttp.fileContent)>
		<cfdump var="#search_result#" label="Yes, I know these results are fugly."><!---  --->
		<!--- <cfdump var="#result.data[1]#"> --->
		<!--- <cfabort> --->

		<cfloop from="1" to="#arrayLen(search_result.data)#" index="i">
			<cfoutput>
				<cfif search_result.data[i].type neq "link">
					object_id = #search_result.data[i].object_id#<br>
					name = #search_result.data[i].name#<br>
					result_url = #search_result.data[i].link#<br>
					caption = #search_result.data[i].caption#<br>
					user_id = #search_result.data[i].from.id#<br>
					type = #search_result.data[i].type#<br>
				</cfif>
			</cfoutput>
		</cfloop>


	</cfif>
</cfif>


<!--- <div class="row" style="padding:2em 0;">
	<div class="col-sm-8 col-sm-offset-2">
		<div class="progress">
			<div class="progress-bar progress-bar-info" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%">
				<span class="sr-only">0% Complete</span>
			</div>
		</div>
	</div>
</div> --->

<div class="panel panel-primary">

	<div class="panel-heading">
		<p class="panel-title"><strong>Search</strong></p>
	</div>

	<div class="panel-body">
		<form name="lookup-term" method="post">
			<div class="form-group">
				<label for="searchTerm">Search Term</label>
				<input type="text" class="form-control" id="searchTerm" name="searchTerm" placeholder="Hash tags are not allowed, and will be stripped out" value="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>">
			</div>
			<button type="submit" class="btn btn-default">Submit</button>
			<cfif len(form.searchTerm)>
				<button class="btn btn-success btn-small monitor-facebook-term-button" data-scheduleid="" data-searchterm="<cfoutput>#HTMLEditFormat(form.searchTerm)#</cfoutput>" data-message="" data-toggle="tooltip" data-placement="bottom" title="Monitor this term">
					<span class="glyphicon glyphicon-eye-open"></span>
				</button>
			</cfif>
		</form>
	</div>

</div>

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
											<button type="submit" class="btn btn-default btn-sm">Search</button>
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






