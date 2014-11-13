<cfprocessingdirective suppressWhitespace="true">
<div class="modal-header">
	<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
	<h4 class="modal-title" id="myModalLabel">Find a page to monitor</h4>
</div>
<div class="modal-body">
	<div class="form-group">
		<label for="pageId">Page name</label>
		<div class="input-group">
			<input type="text" class="form-control" id="pageSearch" name="pageSearch">
			<span class="input-group-btn">
				<button type="button" class="btn btn-default btn-search">Search</button>
			</span>
		</div>
	</div>
	<div id="page-results"></div>
</div>
<div class="modal-footer"></div>
<script>
	$(function(){
		$(document).on('click', '.btn-search', function(e){
			e.preventDefault();
			var pageSearch = $('input[name=pageSearch]').val();
			$.get('<cfoutput>#request.webRoot#</cfoutput>services/lookup-facebook-page.cfm?searchTerm=' + pageSearch, function(data){
				$('#page-results').html(data);
			});
		});
	});
</script>
</cfprocessingdirective>