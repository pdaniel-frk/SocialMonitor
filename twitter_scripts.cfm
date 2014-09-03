<script>
	$(function(){
		$(document).on('click', '.monitor-twitter-term-button', function(e){
			e.preventDefault();
			var scheduleId = $(this).data('scheduleid');
			var searchTerm = $(this).data('searchterm');
			$('#myModal .modal-dialog .modal-content').empty();
			$.get('services/monitor-twitter-term-form.cfm?scheduleId='+scheduleId+'&searchTerm='+encodeURIComponent(searchTerm), function(data){
				$('#myModal .modal-dialog .modal-content').html(data);
				$('#myModal').modal();
			});
		});
		
		$(document).on('click', '.btn-save-twitter-term-monitor', function(e){
			e.preventDefault();
			$.post('services/monitor-twitter-term.cfm', $('form[name=monitorForm]').serialize(), function(response){
			})
			.done(function(){
				$('#myModal').modal('hide');
				location.reload();
			})
			.fail(function(){})
			.always(function(){});
		});
		
		$(document).on('click', '.btn-stop-term-monitor', function(e){
			e.preventDefault();
			$('input[name=stopMonitor]').val('true');
			$('.btn-save-twitter-term-monitor').click();
		});
	});
</script>