<cfset init("Facebook")>

<cfset pageId = "77366666650">

<p><cfoutput>getting page #pageId#</cfoutput></p>

<cfset page = oFacebook.getPage(pageId=pageId, access_token=credentials.facebook.page_access_token)>
<cfdump var="#page#">

<p>parsing page object</p>
<cfset page = oFacebook.parsePageObject(page)>
<cfdump var="#page#">

<p>getting page feed</p>
<cfset feed = oFacebook.getPageFeed(pageId=pageId, access_token=credentials.facebook.page_access_token)>
<cfdump var="#feed#">

<p>parsing feed.data[1] object</p>
<cfset feed = oFacebook.parsePageFeedObject(feed.data[1])>
<cfdump var="#feed#">

<p>getting feed comments</p>
<cfset comments = oFacebook.getComments(id=feed.id, access_token=credentials.facebook.page_access_token)>
<cfdump var="#comments#">

<p>parsing comments.data[1] object</p>
<cfset comment = oFacebook.parseCommentObject(comments.data[1])>
<cfdump var="#comment#">

<p>getting comment.from user</p>
<cfset user = oFacebook.getUser(id=comment.from.id, access_token=credentials.facebook.page_access_token)>
<cfdump var="#user#">

<p>parsing user object</p>
<cfset user = oFacebook.parseUserObject(user)>
<cfdump var="#user#">