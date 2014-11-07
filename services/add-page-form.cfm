<cfprocessingdirective suppressWhitespace="true">
<!--- display form that will appear in a modal --->
<cfoutput>
<form name="lookup-page" action="<cfoutput>#request.webRoot#</cfoutput>services/add-page-form.cfm">
	<div class="modal-header">
		<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
		<h4 class="modal-title" id="myModalLabel">Find a page to monitor</h4>
	</div>
	<div class="modal-body">
		<div class="form-group">
			<label for="pageId">Page name</label>
			<input type="text" class="form-control" id="searchTerm" name="searchTerm">
		</div>
		<button type="button" class="btn btn-default btn-search">Search</button>
	</div>
	<div class="modal-footer"></div>
</form>
</cfoutput>
<script>
	$(function(){
		$(document).on('click', '.btn-search', function(e){
			e.preventDefault();
			console.log('serchr');
			var searchTerm = $('form[name=lookup-page] input[name=searchTerm]').val();
			console.log('st: ' + searchTerm);
			$.get('<cfoutput>#request.webRoot#</cfoutput>services/lookup-facebook-page.cfm?searchTerm=' + searchTerm, function(data){
				console.log(data);
			});
		});
	});
</script>
</cfprocessingdirective>