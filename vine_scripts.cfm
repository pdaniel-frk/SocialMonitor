<script>
	$(function(){
		$(document).on('click', '.monitor-vine-term-button', function(e){
			e.preventDefault();
			var scheduleId = $(this).data('scheduleid');//js converts these to lowercase (from scheduleId) so watch out!
			var searchTerm = $(this).data('searchterm');//js converts these to lowercase (from searchTerm) so watch out!
			$('#myModal .modal-dialog .modal-content').empty();
			$.get('services/monitor-vine-term-form.cfm?scheduleId='+scheduleId+'&searchTerm='+searchTerm, function(data){
				$('#myModal .modal-dialog .modal-content').html(data);
				$('#myModal').modal();
			});
		});

		$(document).on('click', '.btn-save-vine-term-monitor', function(e){
			e.preventDefault();
			$.post('services/monitor-vine-term.cfm', $('form[name=monitorForm]').serialize(), function(response){
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
			$('.btn-save-vine-term-monitor').click();
		});
	});
</script>