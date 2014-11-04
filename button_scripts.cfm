<script>
	$(function(){
		$(document).on('click', '.monitor-facebook-term-button', function(e){
			e.preventDefault();
			var scheduleId = $(this).data('scheduleid');
			var searchTerm = $(this).data('searchterm');
			$('#myModal .modal-dialog .modal-content').empty();
			$.get('services/monitor-facebook-term-form.cfm?scheduleId='+scheduleId+'&searchTerm='+encodeURIComponent(searchTerm), function(data){
				$('#myModal .modal-dialog .modal-content').html(data);
				$('#myModal').modal();
			});
		});

		$(document).on('click', '.btn-save-facebook-term-monitor', function(e){
			e.preventDefault();
			$.post('services/monitor-facebook-term.cfm', $('form[name=monitorForm]').serialize(), function(response){
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
			$('.btn-save-facebook-term-monitor').click();
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

		$(document).on('click', '.monitor-instagram-term-button', function(e){
			e.preventDefault();
			var scheduleId = $(this).data('scheduleid');//js converts these to lowercase (from scheduleId) so watch out!
			var searchTerm = $(this).data('searchterm');//js converts these to lowercase (from searchTerm) so watch out!
			$('#myModal .modal-dialog .modal-content').empty();
			$.get('services/monitor-instagram-term-form.cfm?scheduleId='+scheduleId+'&searchTerm='+searchTerm, function(data){
				$('#myModal .modal-dialog .modal-content').html(data);
				$('#myModal').modal();
			});
		});

		$(document).on('click', '.btn-save-instagram-term-monitor', function(e){
			e.preventDefault();
			$.post('services/monitor-instagram-term.cfm', $('form[name=monitorForm]').serialize(), function(response){
			})
			.done(function(){
				$('#myModal').modal('hide');
				location.reload();
			})
			.fail(function(){})
			.always(function(){});
		});

		$(document).on('click', '.btn-stop-instagram-term-monitor', function(e){
			e.preventDefault();
			$('input[name=stopMonitor]').val('true');
			$('.btn-save-instagram-term-monitor').click();
		});

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

		$(document).on('click', '.btn-stop-twitter-term-monitor', function(e){
			e.preventDefault();
			$('input[name=stopMonitor]').val('true');
			$('.btn-save-twitter-term-monitor').click();
		});
	});
</script>