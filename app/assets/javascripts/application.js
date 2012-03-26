// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .

$.fn.reloadSrc = function(){
var $this = $(this);
var src = $this.attr("src");
if(src != undefined){
//$this.attr("src", src + (src.indexOf('?') >= 0 ? "&" : "?") + "tq=" + (new Date()).getTime());
$this.attr("src", src);
}
}


function UpdateMap() {
	$('.autorefresh').reloadSrc();
	//alert('ok');
  setTimeout(UpdateMap, 500);
	}

function UpdateSystemStatus(theGroup, data_url) {
	// Init
	var theDetails = 	theGroup.find('.details')
	var theProgress = 	theGroup.find('.progress')
	var theBar = 	theGroup.find('.bar')
	theProgress.addClass('progress-striped');
	
	// Query the source URL to get data
	$.ajax({
		url: data_url,
		type: 'GET',
		data: {ajax:true},
		dataType: "html",
		success: function(json){
		  // Parse the response
			data = eval('(' + json + ')');
			//alert(result);
			//alert(data['percent']);

			// Update the progress value
			theBar.css("width", data['percent']);
			theBar.html(data['percent']);
			theDetails.html(data['details']);

			// We're all set, call me back in 5s
			theProgress.removeClass('progress-striped');
		  setTimeout(function(){UpdateSystemStatus(theGroup, data_url)}, 2000);
			}
		});
	
	
	}

$(document).ready(function() {

	// Try to update the workflow map if present
	UpdateMap();

	// Bind a refresh task on each system status
	$('.systemstatus').each(function(index, value) {
		source = $(this).attr('data-source')
		UpdateSystemStatus($(this), source);
	});

});



