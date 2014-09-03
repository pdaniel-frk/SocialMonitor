<h1 class="page-header">Instagram</h1>
<h2>Coming Soon!</h2>
<cfset onRequestEnd(cgi.script_name)>
<cfabort>



<cfapplication name="instagramtesting" sessionmanagement="yes" sessiontimeout="#createtimespan(0,0,20,0)#">
<cfset credentials.instagram = {
	application_name = "test-app",
	client_id = "8c3817a2509a458d873de1ae5bf9f765",
	client_secret = "9799865ededb43e2b14842b93196506a",
	website_url = "http://localhost/egrimm/testing/apis/instagram.cfm",
	redirect_uri = "http://localhost/egrimm/testing/apis/instagram.cfm"
}>
<!-- credit here: http://eduvoyage.com/instagram-search-app.html -->
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title>Instagram API Testing</title>
		<meta name="description" content="">
		<meta name="author" content="">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
		
		<link href="//<cfoutput>#cgi.server_name#</cfoutput>/common/bootstrap3/css/bootstrap.min.css" rel="stylesheet">
		<style type="text/css">
			<!--- #photos-wrap {
			  width: 810px;
			  margin: 70px auto 40px auto;
			  position: relative;
			  z-index: 1;
			} --->
			
			.photo .avatar {
			  width: 40px;
			  height: 40px;
			  padding: 2px;
			  position: absolute;
			  bottom: 11px;
			  right: 8px;
			  background: white;
			}
			
			.photo  {
			  margin-bottom: 20px;
			  float: left;
			  position: relative;
			  width: 250px;
			  height: 250px;
			  border-radius: 5px;
			  background: white;
			  padding: 5px;
			  margin: 5px;
			  box-shadow: 0 0 5px rgba(0, 0, 0, 0.3);
			}
			
			.photo .heart {
			  height: 16px;
			  position: absolute;
			  left: 13px;
			  bottom: 16px;
			  padding: 0 5px 0 22px;
			  font-size: 12px;
			  font-weight: bold;
			  line-height: 16px;
			  border-radius: 2px;
			  border: 1px solid #ddd;
			  background: white; /*url('../images/fav.png') no-repeat 2px 0;*/
			}
			
			.paginate {
			  display: block;
			  clear: both;
			  margin: 10px;
			  text-align: center;
			  margin: 0 auto;
			  padding: 20px 0;
			  height: 100px;
			}
		</style>
		
		<!--[if IE]>
			<script src="//html5shiv.googlecode.com/svn/trunk/html5.js"></script>
		<![endif]-->
		
		<script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
		<script src='http://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.4.4/underscore-min.js'></script>
		<script type="text/javascript">
			// Instantiate an empty object.
			var Instagram = {};
			
			// Small object for holding important configuration data.
			Instagram.Config = {
			  clientID: '<cfoutput>#credentials.instagram.client_id#</cfoutput>',
			  apiHost: 'https://api.instagram.com'
			};
			
			
			// ************************
			// ** Main Application Code
			// ************************
			(function(){
			  var photoTemplate, resource;
			
			  function init(){
			    bindEventHandlers();
			    photoTemplate = _.template($('#photo-template').html());
			  }
			
			  function toTemplate(photo){
			    photo = {
			      count: photo.likes.count,
			      avatar: photo.user.profile_picture,
			      photo: photo.images.low_resolution.url,
			      url: photo.link
			    };
			
			    return photoTemplate(photo);
			  }
			
			  function toScreen(photos){
			    var photos_html = '';
			
			    $('.paginate a').attr('data-max-tag-id', photos.pagination.next_max_id)
			                    .fadeIn();
			
			    $.each(photos.data, function(index, photo){
			      photos_html += toTemplate(photo);
			    });
			
			    $('div#photos-wrap').append(photos_html);
			  }
			
			  function generateResource(tag){
			    var config = Instagram.Config, url;
			
			    if(typeof tag === 'undefined'){
			      throw new Error("Resource requires a tag. Try searching for cats.");
			    } else {
			      // Make sure tag is a string, trim any trailing/leading whitespace and take only the first 
			      // word, if there are multiple.
			      tag = String(tag).trim().split(" ")[0];
			    }
			
			    url = config.apiHost + "/v1/tags/" + tag + "/media/recent?callback=?&client_id=" + config.clientID;
			
			    return function(max_id){
			      var next_page;
			      if(typeof max_id === 'string' && max_id.trim() !== '') {
			        next_page = url + "&max_id=" + max_id;
			      }
			      return next_page || url;
			    };
			  }
			
			  function paginate(max_id){    
			    $.getJSON(generateUrl(tag), toScreen);
			  }
			
			  function search(tag){
			    resource = generateResource(tag);
			    $('.paginate a').hide();
			    $('#photos-wrap *').remove();
			    fetchPhotos();
			  }
			
			  function fetchPhotos(max_id){
			    $.getJSON(resource(max_id), toScreen);
			  }
			
			  function bindEventHandlers(){
			    $('body').on('click', '.paginate a.btn', function(){
			      var tagID = $(this).attr('data-max-tag-id');
			      fetchPhotos(tagID);
			      return false;
			    });
			
			    // Bind an event handler to the `submit` event on the form
			    $('form').on('submit', function(e){
			
			      // Stop the form from fulfilling its destinty.
			      e.preventDefault();
			
			      // Extract the value of the search input text field.
			      var tag = $('input.search-tag').val().trim();
			
			      // Invoke `search`, passing `tag` (unless tag is an empty string).
			      if(tag) {
			        search(tag);
			      };
			
			    });
			
			  }
			
			  function showPhoto(p){
			    $(p).fadeIn();
			  }
			
			  // Public API
			  Instagram.App = {
			    search: search,
			    showPhoto: showPhoto,
			    init: init
			  };
			}());
			
			$(function(){
			  Instagram.App.init();
			  
			  // Start with a search on cats; we all love cats.
			  //Instagram.App.search('cats');  
			});
						
		</script>
	
	</head>
	
	
	
	<body>
		
		<div class="container">
			
			<cfinclude template="nav.cfm">
		
			<div class="jumbotron">
				<h1>Instagram API Testing</h1>
			</div>
			
			<div class="col-md-8 col-md-offset-2">
				
				<form class="form-inline" id="search">
					
					<div class="input-group">
						<input type="text" class="form-control search-tag" name="searchTerm" id="searchTerm">
						<span class="input-group-btn">
							<button type="submit" class="btn btn-primary" id="search-button">Search</button>
						</span>
					</div>
				
					<input type="hidden" name="searchKey" value="<cfoutput>#hash(getTickCount(), 'SHA-1')#</cfoutput>">
				</form>
				
			</div>
			
		
			<div id='photos-wrap'>
			</div>
			
			<div class='paginate'>
				<a class='btn'  style='display:none;' data-max-tag-id='' href='#'>View More&hellip;</a>
			</div>
			
		</div>


		<!--- Placed at the end of the document so the pages load faster --->
		<script src="//<cfoutput>#cgi.server_name#</cfoutput>/common/bootstrap3/js/bootstrap.min.js"></script>
	
		<script type="text/template" id="photo-template">
			<div class='photo'>
				<a href='<%= url %>' target='_blank'>
					<img class='main' src='<%= photo %>' width='250' height='250' style='display:none;' onload='Instagram.App.showPhoto(this);' />
				</a>
				<img class='avatar' width='40' height='40' src='<%= avatar %>' />
				<div class='heart'><div class='pull-left'><span class='glyphicon glyphicon-heart'></span></div><strong><%= count %></strong></div>
			</div>
		</script>
	
	</body>
</html>
