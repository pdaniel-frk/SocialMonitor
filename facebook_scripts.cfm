<!--- get everything on the schedule --->
<cfquery name="getSchedule" datasource="#this.dsn#">
	select 
		s.scheduleId,
		s.name,
		s.monitor_page_id,
		s.monitor_post_id,
		s.startDate,
		s.endDate,
		page.name as pageName,
		post.[message] as postMessage
	from Schedules s
	left join FacebookPages page on s.scheduleId = page.scheduleId and s.monitor_page_id = page.page_id
	left join FacebookPagePosts post on s.scheduleId = post.scheduleId and s.monitor_post_id = post.post_id
	where s.service = 'Facebook'
	and isdate(s.deleteDate) = 0
	order by s.service,
		s.startDate,
		s.endDate
</cfquery>

<div id="fb-root"></div>
<script>
	
	function showMonitorButton(type, id, text){
		return '<button class="btn btn-success btn-small monitor-'+type+'-button" data-scheduleid="" data-pagename="'+text+'" data-postmessage="'+text+'" data-'+type+'id="'+id+'" data-name="'+text+'" data-message="'+text+'" data-toggle="tooltip" data-placement="bottom" title="Monitor this '+type+'"><span class="glyphicon glyphicon-eye-open"></span></button>';
	}
	
	function showEditButton(type, id, text){
		return '<button class="btn btn-warning btn-small monitor-'+type+'-button" data-scheduleid="" data-pagename="'+text+'" data-postmessage="'+text+'" data-'+type+'id="'+id+'" data-name="'+text+'" data-message="'+text+'" data-toggle="tooltip" data-placement="bottom" title="Edit '+type+' monitor"><span class="glyphicon glyphicon-wrench"></span></button>';
	}
	
	$(function(){
		var uid, accessToken, page_id, page_name, post_id = null;
		<!--- loading via jquery --->
		$.ajaxSetup({ cache: true });
		$.getScript('//connect.facebook.net/en_US/all.js', function(){
			FB.init({
				appId: '<cfoutput>#credentials.facebook.appId#</cfoutput>',
				//channelUrl: '//promotions.mardenkane.com/common/channel.html',
				status: true, 
				cookie: true,
				xfbml: true,
			});
			
			
			/************ VALIDATING LOGIN STATUS ******************/
			
			FB.getLoginStatus(function(response) {
				if (response.status === 'connected') {
					uid = response.authResponse.userID;
					accessToken = response.authResponse.accessToken;
				} 
				else if (response.status === 'not_authorized') {
					fblogin();
				} 
				else {
					fblogin();
				}
			});
			
			FB.Event.subscribe('auth.statusChange', function(response) {
				if (response.status === 'connected') {
					uid = response.authResponse.userID;
					accessToken = response.authResponse.accessToken;
				} 
				else if (response.status === 'not_authorized') {
					fblogin();
				} 
				else {
					fblogin();
				}
			});
			
		});
		
		
		/************ LOGGING IN AND SUCHLIKE ******************/
		
		function fblogin(){
			$('#facebook-logged-out').show();
			FB.login(function(response) {
				if(response.authResponse){
					$('#facebook-logged-out').hide();
					uid = response.authResponse.userID;
					accessToken = response.authResponse.accessToken;
				}
				else{
				}
			}, {scope:'email,user_likes,read_stream,manage_pages'});
		}
		
		
		/************ FORM HIJACKS ******************/
		
		$('form[name=lookup-page]').submit(function(e){
			e.preventDefault();
			if($('input[name=managed_pages]').is(':checked'))
			{
				lookupUserManagedPages($('input[name=pageId]').val());
			}
			else
			{
				lookupPage($('input[name=pageId]').val());
			}
			
		});
		
		$('form[name=lookup-post]').submit(function(e){
			e.preventDefault();
			searchPagePosts(page_id, $('input[name=query]').val());
		});
		
				
		/************ CLICK HIJACKS ******************/
		
		$(document).on('click', '.page-button', function(e){
			e.preventDefault();
			page_id = $(this).data('pageid');
			$('form[name=lookup-post]').show();
			lookupPagePosts(page_id);
		});
		
		$(document).on('click', '.post-button', function(e){
			e.preventDefault();
			post_id = $(this).data('postid');
			lookupPostComments(post_id);
			lookupPostLikes(post_id);
		});
		
		$(document).on('click', '#fb-login', function(e){
			fblogin();
		});
		
		$(document).on('click', '.monitor-page-button', function(e){
			e.preventDefault();
			var scheduleId = $(this).data('scheduleid');
			var pageId = $(this).data('pageid');
			var pageName = $(this).data('pagename');
			$('#myModal .modal-dialog .modal-content').empty();
			$.get('services/monitor-page-form.cfm?scheduleId='+scheduleId+'&pageId='+pageId+'&pageName='+pageName, function(data){
				$('#myModal .modal-dialog .modal-content').html(data);
				$('#myModal').modal();
			});
		});
		
		$(document).on('click', '.btn-save-page-monitor', function(e){
			e.preventDefault();
			$.post('services/monitor-page.cfm', $('form[name=monitorPageForm]').serialize(), function(response){
			})
			.done(function(){})
			.fail(function(){})
			.always(function(){});
			
			$('#myModal').modal('hide');
		});
		
		$(document).on('click', '.btn-stop-page-monitor', function(e){
			e.preventDefault();
			$('input[name=stopMonitor]').val('true');
			$('.btn-save-page-monitor').click();
		});
		
		$(document).on('click', '.monitor-post-button', function(e){
			e.preventDefault();
			var scheduleId = $(this).data('scheduleid');
			var postId = $(this).data('postid');
			var postMessage = $(this).data('postmessage');
			$('#myModal .modal-dialog .modal-content').empty();
			$.get('services/monitor-post-form.cfm?scheduleId='+scheduleId+'&postId='+postId+'&postMessage='+postMessage, function(data){
				$('#myModal .modal-dialog .modal-content').html(data);
				$('#myModal').modal();
			});
		});
		
		$(document).on('click', '.btn-save-post-monitor', function(e){
			e.preventDefault();
			$.post('services/monitor-post.cfm', $('form[name=monitorPostForm]').serialize(), function(response){
			})
			.done(function(){})
			.fail(function(){})
			.always(function(){});
			
			$('#myModal').modal('hide');
		});
		
		$(document).on('click', '.btn-stop-post-monitor', function(e){
			e.preventDefault();
			$('input[name=stopMonitor]').val('true');
			$('.btn-save-post-monitor').click();
		});
		
		
		/************ FQL CALLS ******************/
		
		<!--- this is misleading, cause im actually using a search term, not an actual pageId... --->
		<!--- this also occasionally stops working cause FACEBOOK! --->
		function lookupPage(pageId){
			pageId = pageId.replace("'", "\\\'");
			FB.api({
				method: 'fql.query',
				query: 'select page_id, name, username, type, fan_count, page_url from page where contains(\''+pageId+'\') order by fan_count desc',
				return_ssl_resources: 1,
			}, function(response){
				$('#lookup-page-results-count').text(''+response.length+' pages found matching "'+pageId+'"');
				populatePageList(response);
			});
		}
		
		function lookupUserManagedPages(pageId){
			pageId = pageId.replace("'", "\\\'");
			
			var query2 = 'select page_id, name, username, type, fan_count, page_url from page where page_id in (select page_id from #query1)';
			if(pageId.length)
			{
				// 'contains' is ignored with the page_id in () clause
				//query2 += ' and contains(\''+pageId+'\')';
				query2 += ' and strpos(lower(name), lower(\''+pageId+'\')) > 0';
			}
			query2 += ' order by fan_count desc';
			
			FB.api({
				method: 'fql.multiquery',
				queries:{
					'query1': 'select page_id from page_admin where uid = ' + uid,
					'query2': query2,
				},
				return_ssl_resources: 1,
			}, function(queries){
				response = queries[1].fql_result_set;
				$('#lookup-page-results-count').text(''+response.length+' pages found matching "'+pageId+'"');
				populatePageList(response);
			});
		}
		
		function lookupPagePosts(pageId){
			FB.api({
				<!--- https://developers.facebook.com/docs/reference/fql/stream/ --->
				method: 'fql.query',
				query: 'select post_id, message, created_time, type, share_count, comment_info.comment_count, like_info.like_count from stream where source_id = ' + pageId + ' and actor_id = ' + pageId,
				return_ssl_resources: 1,
			}, function(response){
				$('#lookup-posts-results-count').text(''+response.length+' posts found for page');
				populatePostList(pageId, response);
			});
		}
		
		function searchPagePosts(pageId, query){
			<!--- https://developers.facebook.com/docs/reference/fql/stream/ --->
			FB.api({
				method: 'fql.query',
				query: 'select post_id, message, created_time, type, share_count, comment_info.comment_count, like_info.like_count from stream where source_id = ' + pageId + ' and actor_id = ' + pageId + ' and strpos(lower(message), lower(\''+query+'\')) > 0',
				return_ssl_resources: 1,
			}, function(response){
				$('#lookup-posts-results-count').text(''+response.length+' posts found for page');
				populatePostList(pageId, response);
			});
		}
		
		function lookupPostComments(postId){
			<!--- https://developers.facebook.com/docs/reference/fql/comment/ --->
			FB.api({
				method: 'fql.query',
				query: 'select text, id, post_fbid, fromid, time from comment where post_id = \''+postId+'\' limit 1000',
				return_ssl_resources: 1,
			},function(response){
				populateCommentList(postId, response);
			});
		}
		
		
		function lookupPostLikes(postId){
			<!--- https://developers.facebook.com/docs/reference/fql/like/ --->
			FB.api({
				method: 'fql.query',
				query: 'select user_id from like where post_id = \''+postId+'\' limit 1000',
				return_ssl_resources: 1,
			},function(response){
				populateLikeList(postId, response);
			});
		}
		
		function lookupUser(userId){
			<!--- https://developers.facebook.com/docs/reference/fql/user/ --->
			FB.api({
				method: 'fql.query',
				query: 'select email, first_name, last_name, name, username, uid, timezone, locale, profile_url, age_range, birthday_date from user where uid = ' + userId,
				return_ssl_resources: 1,
			}, function(response){
				showUserName(response);					
			});
		}
		
		/************ RESULTS DISPLAYANCE ******************/
		
		function showUserName(response){
			var html = '<a class="btn btn-link" href="'+response[0].profile_url+'" target="_blank">'+response[0].name+'</a>';
			$('.user-'+response[0].uid).html(html);
		}
		
		function populatePageList(response){
			$('#lookup-page-results-table tbody').empty();
			$('#lookup-posts-results-table tbody').empty();
				$('#lookup-posts-results-wrapper').hide();
			$('#lookup-comments-results-table tbody').empty();
				$('#lookup-comments-results-wrapper').hide();
			$('#lookup-likes-results-table tbody').empty();
				$('#lookup-likes-results-wrapper').hide();
			for(i=0;i<response.length;i++){
						
				$pageId = response[i].page_id;
				$pageName = response[i].name;
				$pageURL = response[i].page_url;
				$username = response[i].username;
				$type = response[i].type;
				
				var html = '<tr>';
					html += '<td>';
						html += '<button class="btn btn-primary btn-sm page-button" data-pageid="'+$pageId+'">'+$pageName+'</button>';
					html += '</td>';
					
					html += '<td>';
						if($pageURL.length)
							html += '<a href="'+$pageURL+'" target="_blank">visit page</a>';
					html += '</td>';
					
					html += '<td>';
						if($.inArray($pageId, monitored_page_ids) > -1) {
							html += showEditButton('page', $pageId, $pageName);
						}
						else {
							html += showMonitorButton('page', $pageId, $pageName);
						}
						
					html += '</td>';
				
				html += '</tr>';
				
				$('#lookup-page-results-table tbody').append(html);
				
			}
			$('#lookup-page-results-wrapper').show();
			location.href = '#pages';
		}
		
		function populatePostList(pageId, response){
			$('#lookup-posts-results-table tbody').empty();
			$('#lookup-comments-results-table tbody').empty();
				$('#lookup-comments-results-wrapper').hide();
			$('#lookup-likes-results-table tbody').empty();
				$('#lookup-likes-results-wrapper').hide();
			for(i=0;i<response.length;i++){
				if(response[i].message.length){
					
					$pageId = pageId;
					$postId = response[i].post_id;
					$message = response[i].message;
					$created_time = response[i].created_time;
					$type = response[i].type;
					$commentCount = response[i].comment_info.comment_count;
					$likeCount = response[i].like_info.like_count;
					$shareCount = response[i].share_count;
					
					var html = '<tr>';
						html += '<td>';
							html += '<button class="btn btn-info btn-sm post-button" data-postid="'+$postId+'">'+$message.substr(0,100)+'...</button>';
						html += '</td>';
						
						html += '<td>';
							html += $commentCount;
						html += '</td>';
						
						html += '<td>';
							html += $likeCount;
						html += '</td>';
						
						html += '<td>';
							html += $shareCount;
						html += '</td>';
						
						html += '<td>';
							if($.inArray($postId, monitored_post_ids) > -1) {
								html += showEditButton('post', $postId, $message);
							}
							else {
								html += showMonitorButton('post', $postId, $message);
							}
							
						html += '</td>';
					html += '</tr>';
					
					$('#lookup-posts-results-table tbody').append(html);
					
				}
			}
			$('#lookup-posts-results-wrapper').show();
			location.href = '#posts';
		}
		
		function populateCommentList(postId, response){
			$('#lookup-comments-results-count').text(''+response.length+' comments found for post');
			$('#lookup-comments-results-table tbody').empty();
			for(i=0;i<response.length;i++){
				
				var html = '<tr>';
					
					html += '<td>';
						html += '<button class="btn btn-default btn-sm comment-button" data-id="'+response[i].id+'">'+response[i].text.substr(0,100)+'...</button>';
					html += '</td>';
					
					html += '<td class="user-'+response[i].fromid+'">';
						lookupUser(response[i].fromid);//this is hacky, but the function looks up the user name and then populates the td with it								
					html += '</td>';
					
					html += '<td>';
						var d = new Date(response[i].time * 1000);
						html += d;
					html += '</td>';
					
				html += '</tr>';
				
				$('#lookup-comments-results-table tbody').append(html);
			}
			$('#lookup-comments-results-wrapper').show();
			location.href = '#comments';
		}
		
		function populateLikeList(postId, response){
			$('#lookup-likes-results-count').text(''+response.length+' likes found for post');
			$('#lookup-likes-results-table tbody').empty();
			for(i=0;i<response.length;i++){
								
				var html = '<tr>';
					html += '<td>';
						html += response[i].user_id;
					html += '</td>';
					
					html += '<td class="user-'+response[i].user_id+'">';
						lookupUser(response[i].user_id);//this is hacky, but the function looks up the user name and then populates the td with it								
					html += '</td>';
				html += '</tr>';
								
				$('#lookup-likes-results-table tbody').append(html);
			}
			$('#lookup-likes-results-wrapper').show();
		}
		
		
		/************ SAVORIES ******************/
		
		// the L stands for Value
		function savePage(pageId,pageName,pageUrl,userName,pageType){
			$.post('services/save-page.cfm', {
								pageId: pageId,
								pageName: pageName,
								pageUrl: pageUrl,
								userName: userName,
								pageType: pageType,
								userId: uid
							}, function(response){
			})
			.done(function(){})
			.fail(function(){})
			.always(function(){});
		}
		
		function savePagePost(pageId,postId,message,created_time,postType){
			$.post('services/save-page-post.cfm', {
								pageId: pageId,
								postId: postId,
								message: message,
								created_time: created_time,
								postType: postType,
								userId: uid
							}, function(response){
			})
			.done(function(){})
			.fail(function(){})
			.always(function(){});
		}
		
		function savePostComments(postId,fromid,postFBId,id,commentText,commentTime){
			$.post('services/save-post-comments.cfm', {
								postId: postId,
								fromid: fromid,
								postFBId: postFBId,
								id: id,
								commentText: commentText,
								commentTime: commentTime,
								userId: uid
							}, function(response){
			})
			.done(function(){})
			.fail(function(){})
			.always(function(){});
		};
		
		function savePostLikes(postId, user_id){
			$.post('services/save-post-likes.cfm', {
								postId: postId,
								user_id: user_id,
								userId: uid
							}, function(response){
			})
			.done(function(){})
			.fail(function(){})
			.always(function(){});
		};
		
		function saveFacebookUser(user_id, email, first_name, last_name, username, timezone, locale, profile_url, birthday_date){
			$.post('services/save-facebook-user.cfm', {
								user_id: user_id,
								email: email,
								first_name: first_name,
								last_name: last_name,
								username: username,
								timezone: timezone,
								locale: locale,
								profile_url: profile_url,
								birthday_date: birthday_date,
								userId: uid
							}, function(response){
			})
			.done(function(){})
			.fail(function(){})
			.always(function(){});
		};
		
						
		/************ MISS ALLANY ******************/
		
		// create arrays of pages and posts being monitored
		var monitored_page_ids = [];
		var monitored_post_ids = [];
		<cfif getSchedule.recordCount>
			<cfloop query="getSchedule">
				<cfif len(getSchedule.monitor_page_id)>
					monitored_page_ids.push("<cfoutput>#getSchedule.monitor_page_id#</cfoutput>");
				</cfif>
				<cfif len(getSchedule.monitor_post_id)>
					monitored_post_ids.push("<cfoutput>#getSchedule.monitor_post_id#</cfoutput>");
				</cfif>
			</cfloop>
		</cfif>
	});
</script>