<cfparam name="scheduleId" default="">
<cfif len(trim(scheduleId))>
	<cfset init("Schedules")>
	<cfset init("Entries")>
	<cfset scheduleDetails = oSchedules.getSchedules(scheduleId=scheduleId)>
	<cfif scheduleDetails.recordCount>
		<cfoutput query="scheduleDetails">
			<tr class="<cfif len(endDate) and dateCompare(endDate, now()) lt 0>finished warning</cfif>">
				<td>#lc#</td>
				<td>#name#</td>
				<cfif service eq "Facebook">
					<td>
						<cfif len(monitor_page_id)>
							<cfquery name="getPage" datasource="#this.dsn#">
								select *
								from FacebookPages
								where id = <cfqueryparam value="#monitor_page_id#" cfsqltype="cf_sql_varchar">
								<!--- and scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer"> --->
							</cfquery>
							#getPage.name#
						</cfif>
					</td>
					<td>
						<cfif len(monitor_post_id)>
							<cfquery name="getPost" datasource="#this.dsn#">
								select *
								from FacebookPosts
								where id = <cfqueryparam value="#monitor_post_id#" cfsqltype="cf_sql_varchar">
								<!--- and scheduleId = <cfqueryparam value="#scheduleId#" cfsqltype="cf_sql_integer"> --->
							</cfquery>
							#left(getPost.message, 250)#<cfif len(getPost.message) gt 250>&hellip;</cfif>
						</cfif>
					</td>
				</cfif>
				<td>#searchTerm#</td>
				<td>#dateFormat(startDate, 'mm/dd/yyyy')# #timeFormat(startDate, 'h:mm TT')#</td>
				<td>#dateFormat(endDate, 'mm/dd/yyyy')# #timeFormat(endDate, 'h:mm TT')#</td>
				<td>#numberFormat(oEntries.getEntryCount(scheduleId=scheduleId, service=service))#</td>
				<!--- <cfif service eq "Facebook">
					<td>#numberFormat(getEntryCount.comment_count, ",")#</td>
					<td>#numberFormat(getEntryCount.like_count, ",")#</td>
				</cfif> --->
				<td nowrap>
					<!--- <cfif service eq "Facebook">
						<cfif len(monitor_page_id)>
							<button class="btn btn-warning btn-xs monitor-page-button" data-scheduleid="#scheduleId#" data-pageid="#monitor_page_id#" data-pagename="#getPage.name#" data-toggle="tooltip" data-placement="bottom" title="Edit Page Monitor">
								<span class="glyphicon glyphicon-edit"></span>
							</button>
						<cfelseif len(monitor_post_id)>
							<button class="btn btn-warning btn-xs monitor-post-button" data-scheduleid="#scheduleId#" data-postid="#monitor_post_id#" data-postmessage="#getPost.message#" data-toggle="tooltip" data-placement="bottom" title="Edit Page Monitor">
								<span class="glyphicon glyphicon-edit"></span>
							</button>
						<cfelse>
							<button class="btn btn-warning btn-xs monitor-facebook-term-button" data-scheduleid="#scheduleId#" data-searchterm="#searchTerm#" data-toggle="tooltip" data-placement="bottom" title="Edit Term Monitor">
								<span class="glyphicon glyphicon-edit"></span>
							</button>
						</cfif>
					</cfif>
					<cfif service eq "Instagram">
						<button class="btn btn-warning btn-xs monitor-instagram-term-button" data-scheduleid="#scheduleId#" data-searchterm="#searchTerm#" data-toggle="tooltip" data-placement="bottom" title="Edit Term Monitor">
							<span class="glyphicon glyphicon-edit"></span>
						</button>
					</cfif>
					<cfif service eq "Twitter">
						<button class="btn btn-warning btn-xs monitor-twitter-term-button" data-scheduleid="#scheduleId#" data-searchterm="#searchTerm#" data-toggle="tooltip" data-placement="bottom" title="Edit Term Monitor">
							<span class="glyphicon glyphicon-edit"></span>
						</button>
					</cfif>
					<cfif service eq "Vine">
						<button class="btn btn-warning btn-xs monitor-vine-term-button" data-scheduleid="#scheduleId#" data-searchterm="#searchTerm#" data-toggle="tooltip" data-placement="bottom" title="Edit Term Monitor">
							<span class="glyphicon glyphicon-edit"></span>
						</button>
					</cfif> --->
					<a href="#request.webRoot#schedules/edit-schedule.cfm?scheduleId=#scheduleId#"><!---
						 ---><button class="btn btn-warning btn-xs" data-toggle="tooltip" data-placement="bottom" title="Edit schedule">
							<span class="glyphicon glyphicon-edit"></span>
						</button>
					</a>
					<button class="btn btn-info btn-xs run-schedule" data-scheduleid="#scheduleId#" data-service="#lcase(service)#" data-toggle="tooltip" data-placement="bottom" title="Run this task">
						<span class="glyphicon glyphicon-play-circle"></span>
					</button>
					<a href="#request.webRoot#entries/view.cfm?scheduleId=#scheduleId#"><!---
						 ---><button class="btn btn-primary btn-xs view-entries" data-scheduleid="#scheduleId#" data-service="#lcase(service)#" data-toggle="tooltip" data-placement="bottom" title="View collected entries">
							<span class="glyphicon glyphicon-eye-open"></span>
						</button>
					</a>
					<button class="btn btn-default btn-xs download-entries" data-scheduleid="#scheduleId#" data-service="#lcase(service)#" data-toggle="tooltip" data-placement="bottom" title="Download collected entries">
						<span class="glyphicon glyphicon-download-alt"></span>
					</button>
				</td>
			</tr>
		</cfoutput>
	</cfif>
</cfif>