<cfparam name="url.scheduleId" default="">
<cfparam name="url.type" default="add-page"><!--- edit-page,add-post,edit-post,remove-page,remove-post --->
<cfparam name="form.scheduleId" default="#url.scheduleId#">
<cfparam name="form.type" default="#url.type#">

<cfif not len(form.scheduleId) or not len(form.type)>
	<cflocation url="index.cfm" addtoken="no">
</cfif>

<!--- get schedule details --->
<cfset init("Schedules")>
<cfset schedule = oSchedules.getSchedules(scheduleId=form.scheduleId)>
<cfif not schedule.recordCount>
	<cflocation url="index.cfm" addtoken="no">
</cfif>
<cfparam name="form.pageId" default="#schedule.monitor_page_id#">
<cfparam name="form.postId" default="#schedule.monitor_post_id#">
<cfparam name="form.pageName" default="#schedule.pageName#">

<h1 class="page-header">
	Schedules &raquo; Edit <small><cfoutput>#schedule.name#</cfoutput></small><br>
	<small>
		<cfswitch expression="#form.type#">
			<cfcase value="add-page">Add Facebook Page</cfcase>
			<cfcase value="edit-page">Change Facebook Page</cfcase>
			<cfcase value="remove-page">Remove Facebook Page</cfcase>

			<cfcase value="add-post">Add Facebook Post</cfcase>
			<cfcase value="edit-post">Change Facebook Post</cfcase>
			<cfcase value="remove-post">Remove Facebook Post</cfcase>
		</cfswitch>
		<cfif not findNoCase("remove", form.type)>
			<a href="edit-schedule.cfm?scheduleId=<cfoutput>#form.scheduleId#</cfoutput>" class="btn btn-sm btn-warning">Cancel</a>
		</cfif>
	</small>
</h1>

<cfif not findNoCase("remove", form.type)>

	<cfif findNoCase("page", form.type) and len(form.pageName)>
		<!--- lookup pages --->
		<cfset init("Facebook")>
		<cfset pages = oFacebook.getPage (
			searchTerm = form.pageName,
			access_token = credentials.facebook.page_access_token
		)>
	</cfif>

	<cfif (structKeyExists(form, "getPosts") and form.getPosts eq "true") or (findNoCase("post", form.type) and len(form.pageId))>
		<!--- lookup posts --->
		<cfset init("Facebook")>
		<cfset posts = oFacebook.getPageFeed (
			pageId = form.pageId,
			access_token = credentials.facebook.page_access_token
		)>
	</cfif>

	<cfif structKeyExists(form, "finalSubmit") and form.finalSubmit eq "true">

		<cfif findNoCase("page", form.type)>
			<cfset init("Schedules")>
			<cfset oSchedules.updateSchedule(
				scheduleId = form.scheduleId,
				monitor_page_id = form.pageId
			)>
			<cfset oFacebook.getPage(
				scheduleId = form.scheduleId,
				pageId = form.pageId,
				access_token = credentials.facebook.page_access_token,
				save_results = true
			)>
			<!--- <cflocation url="edit-schedule.cfm?scheduleId=#form.scheduleId#" addtoken="no"> --->
			<cfset reRoute(destination="edit-schedule.cfm?scheduleId=#form.scheduleId#", message="Your monitored page has been updated.")>
		</cfif>

		<cfif findNoCase("post", form.type)>
			<cfset init("Schedules")>
			<cfset oSchedules.updateSchedule(
				scheduleId = form.scheduleId,
				monitor_post_id = form.postId
			)>
			<cfset oFacebook.getPost(
				scheduleId = form.scheduleId,
				postId = form.postId,
				access_token = credentials.facebook.page_access_token,
				save_results = true
			)>
			<!--- <cflocation url="edit-schedule.cfm?scheduleId=#form.scheduleId#" addtoken="no"> --->
			<cfset reRoute(destination="edit-schedule.cfm?scheduleId=#form.scheduleId#", message="Your monitored post has been updated.")>
		</cfif>

	</cfif>

	<div class="panel panel-primary">

		<div class="panel-heading">
			<p class="panel-title"><strong>Look up page</strong></p>
		</div>

		<div class="panel-body">
			<form name="pageForm" action="edit-page.cfm" method="post">
				<div class="form-group">
					<label for="pageName">Page name</label>
					<div class="input-group">
						<input type="text" class="form-control" id="pageName" name="pageName" value="<cfoutput>#HTMLEditFormat(form.pageName)#</cfoutput>">
						<span class="input-group-btn">
							<input type="submit" class="btn btn-default" value="Search">
						</span>
					</div>
				</div>

				<div class="form-group page-results">
					<cfif isDefined("pages")>
						<div class="table-responsive">
							<table class="table table-condensed">
								<thead>
									<tr>
										<th>#</th>
										<th>Name</th>
										<th>Category</th>
										<th>Likes</th>
										<th>Actions</th>
									</tr>
								</thead>
								<tbody>
									<cfloop from="1" to="#arrayLen(pages.data)#" index="i">
										<cfset page = structGet("pages.data[#i#]")>
										<cfset page = oFacebook.parsePageObject(page)>
										<cfoutput>
											<tr>
												<td>#i#</td>
												<td><a href="#page.link#" target="_blank">#page.name#</a></td>
												<td>#page.category#</td>
												<td>#numberFormat(page.likes, ",")#</td>
												<td>
													<button class="btn btn-success btn-xs monitor-page" data-pageid="#page.id#" data-toggle="tooltip" data-placement="bottom" title="Monitor this page">
														<span class="glyphicon glyphicon-eye-open"></span>
													</button>

														<button class="btn btn-primary btn-xs get-posts" data-pageid="#page.id#" data-toggle="tooltip" data-placement="bottom" title="Get posts on this page">
															<span class="glyphicon glyphicon-list"></span>
														</button>
													<cfif findNoCase("post", form.type)></cfif>
												</td>
											</tr>
										</cfoutput>
									</cfloop>
								</tbody>
							</table>
						</div>
					</cfif>
				</div>

				<div class="form-group post-results">
					<cfif isDefined("posts")>
						<div class="table-responsive">
							<table class="table table-condensed">
								<thead>
									<tr>
										<th>Date</th>
										<th>From</th>
										<th>Message</th>
										<th>Likes</th>
										<th>Shares</th>
										<th>Actions</th>
									</tr>
								</thead>
								<tbody>
									<cfloop from="1" to="#arrayLen(posts.data)#" index="i">
										<cfset post = structGet("posts.data[#i#]")>
										<cfset post = oFacebook.parsePostObject(post)>
										<cfoutput>
											<cfif len(post.message)>
												<tr>
													<td>#oFacebook.convertCreatedTimeToString(post.created_time)#</td>
													<td>#post.from.name#</td>
													<td>#post.message#</td>
													<td>#numberFormat(post.likes.count, ",")#</td>
													<td>#numberFormat(post.shares.count, ",")#</td>
													<td>
														<button class="btn btn-success btn-xs monitor-post" data-postid="#post.id#" data-toggle="tooltip" data-placement="bottom" title="Monitor this post">
															<span class="glyphicon glyphicon-eye-open"></span>
														</button>
													</td>
												</tr>
											</cfif>
										</cfoutput>
									</cfloop>
								</tbody>
							</table>
						</div>
					</cfif>
				</div>
				<!--- csrf --->
				<input type="hidden" name="__token" id="__token" value="<cfoutput>#session.stamp#</cfoutput>">
				<input type="hidden" name="scheduleId" value="<cfoutput>#form.scheduleId#</cfoutput>">
				<input type="hidden" name="type" value="<cfoutput>#form.type#</cfoutput>">
				<input type="hidden" name="pageId" value="<cfoutput>#form.pageId#</cfoutput>">
				<input type="hidden" name="postId" value="<cfoutput>#form.postId#</cfoutput>">
				<input type="hidden" name="finalSubmit" value="false">
				<input type="hidden" name="getPosts" value="false">
			</form>
		</div>

	</div>

<cfelse>

	<cfif form.type eq "remove-page">

		<h2><cfoutput>#schedule.pageName#</cfoutput></h2>

		<button class="btn btn-sm btn-danger delete-confirm">Yes, I want to stop monitoring this page.</button>
		<a href="edit-schedule.cfm?scheduleId=<cfoutput>#form.scheduleId#</cfoutput>" class="btn btn-lg btn-info">No way! Get me out of here!</a>

		<script>
			$(function(){
				$(document).on('click', '.delete-confirm', function(e){
					e.preventDefault();
					$.post('<cfoutput>#request.webRoot#</cfoutput>services/cancel-page.cfm', {
						scheduleid: '<cfoutput>#form.scheduleId#</cfoutput>',
						__token: '<cfoutput>#session.stamp#</cfoutput>'
					}, function(response){
					})
					.done(function(){
						window.location = 'index.cfm';
					})
					.fail(function(){})
					.always(function(){});
				});
			});
		</script>

	<cfelseif form.type eq "remove-post">

		<p><cfoutput>#schedule.postMessage#</cfoutput></p>

		<button class="btn btn-sm btn-danger delete-confirm">Yes, I want to stop monitoring this post.</button>
		<a href="edit-schedule.cfm?scheduleId=<cfoutput>#form.scheduleId#</cfoutput>" class="btn btn-lg btn-info">No way! Get me out of here!</a>

		<script>
			$(function(){
				$(document).on('click', '.delete-confirm', function(e){
					e.preventDefault();
					$.post('<cfoutput>#request.webRoot#</cfoutput>services/cancel-post.cfm', {
						scheduleid: '<cfoutput>#form.scheduleId#</cfoutput>',
						__token: '<cfoutput>#session.stamp#</cfoutput>'
					}, function(response){
					})
					.done(function(){
						window.location = 'index.cfm';
					})
					.fail(function(){})
					.always(function(){});
				});
			});
		</script>

	</cfif>

</cfif>

<script>
	$(function(){
		$(document).on('click', '.monitor-page', function(e){
			e.preventDefault();
			$('input[name=pageId]').val($(this).data('pageid'));
			$('input[name=finalSubmit]').val('true');
			$('form[name=pageForm]').submit();
		});

		$(document).on('click', '.monitor-post', function(e){
			e.preventDefault();
			$('input[name=postId]').val($(this).data('postid'));
			$('input[name=finalSubmit]').val('true');
			$('form[name=pageForm]').submit();
		});

		$(document).on('click', '.get-posts', function(e){
			e.preventDefault();
			$('input[name=getPosts]').val('true');
			$('input[name=pageId]').val($(this).data('pageid'));
			$('form[name=pageForm]').submit();
		});
	});
</script>