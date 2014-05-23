$(document).ready(function() {

	// Try to update the workflow map if present
	// UpdateMap();

	// Bind a refresh task on each system status
	$('#dashboard .systemstatus').each(function(index, value) {
		source = $(this).attr('data-source')
		UpdateSystemStatus($(this), source);
	});

// Activate every refreshable panel
	$('.refreshable').each(function(index, value) {

		source = $(this).attr('data-source')
		seconds = $(this).attr('data-period')
		//alert(seconds);
		UpdateRefreshable($(this), source, seconds);
	});



});
