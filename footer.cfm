					<!---<cfhttp url="https://api-read.facebook.com/restserver.php?method=fql.query&query=select%20page_id,%20name,%20username,%20type,%20fan_count,%20page_url%20from%20page%20where%20page_id%20=%2021716485677%20order%20by%20fan_count%20desc&access_token=CAABcIZBWnspgBAAffy3B4YHAM7QdjLkI8UV3thZCVNYzD68tDRO0AOXrh9HHnbh1DMOKI2csPUGQEh6k14HStZAvu28PxHPQw34CQ2oSRC0HcdnbZA01UAj1ZCtt4m5H4RMxyuMqL49W5iFZABI9NaELrKNTOFJiF5UHucvKGsPWU31wp9ZCpKQxYele4Q6iajrNItQTwQilAiZA518bko2z&api_key=101309246583448&return_ssl_resources=1&format=json-strings&pretty=1"></cfhttp>
					<cfdump var="#cfhttp#">
					<cfdump var="#cfhttp.fileContent#">
					<cfdump var="#deserializeJson(cfhttp.fileContent)#">--->
				</div>
			</div>
		</div>
	</div>

	<!--- Placed at the end of the document so the pages load faster --->
	<!--- <script src="//promotions.mardenkane.com/common/bootstrap3/js/bootstrap.min.js"></script> --->
	<!-- Latest compiled and minified JavaScript -->
	<script src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
	<script src="<cfoutput>#request.webRoot#scripts/docs.min.js</cfoutput>"></script>


	<!--- modals for setting/editing monitoring durations --->
	<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">

			</div>
		</div>
	</div>

	<cfif findNoCase("facebook", cgi.script_name) or findNoCase("schedules", cgi.script_name)>
		<cfinclude template="facebook_scripts.cfm">
	</cfif>
	<cfif findNoCase("instagram", cgi.script_name) or findNoCase("schedules", cgi.script_name)>
		<cfinclude template="instagram_scripts.cfm">
	</cfif>
	<cfif findNoCase("twitter", cgi.script_name) or findNoCase("schedules", cgi.script_name)>
		<cfinclude template="twitter_scripts.cfm">
	</cfif>
	<cfif findNoCase("vine", cgi.script_name) or findNoCase("schedules", cgi.script_name)>
		<cfinclude template="vine_scripts.cfm">
	</cfif>

	<script>
		$(function(){
			<!--- this works on dynamically-added elements, yo (such as the ajax-y populated modal form) --->
			$('body').on('focus', '.datepicker', function(){
				$(this).datepicker({
					changeMonth: true,
					changeYear: true,
					showAnim: 'slideDown',
					dateFormat: 'mm/dd/yy'
				});
			});
			<!--- tooltips --->
			$(document).tooltip({
				selector: '[data-toggle=tooltip]'
			});

			<!--- this works on dynamically-added elements, yo (such as the ajax-y populated modal form) --->
			$(document).on('keyup', '#name', function(){

				$(this).autocomplete({
			    	source:'<cfoutput>#request.webRoot#services/autosuggest.cfm</cfoutput>',
			    	minLength: 3,
			    	<!--- append the autocomplete to the modal, otherwise results aint be displayered --->
					appendTo: "#myModal",
			    	select : function(event, ui){
			    		console.log(ui.item.value);
			    	}
			    });

		    });

			$(document).on('click', '.run-schedule', function(e){

				var scheduleid = $(this).data('scheduleid');
				var service = $(this).data('service');

				$('.run-schedule').each(function(){
					$(this).hide();
				});
				$('.progress').show();

				$.get('<cfoutput>#request.webRoot#</cfoutput>tasks/' + service + '_automated.cfm?scheduleId=' + scheduleid, function(response){
				})
				.done(function(){
					location.reload();
				})
				.fail(function(){})
				.always(function(){});
			});

			$(document).on('click', '.download-entries', function(e){

				var scheduleid = $(this).data('scheduleid');
				var service = $(this).data('service');

				window.open('<cfoutput>#request.webRoot#</cfoutput>tasks/export_entries.cfm?scheduleId=' + scheduleid);

			});
		});
	</script>

</body>

</html>