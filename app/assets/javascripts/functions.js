function render(src, target, engine) {
  try {
    result = Viz(src, "svg", engine);
  } catch(e) {
    result = inspect(e.toString());
  }

  $(target).html(result);

  // alert(result);

}


function UpdateMap() {
	$('.autorefresh').reloadSrc();
  setTimeout(UpdateMap, 1000);
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
			// Update the progress value
			theBar.css("width", data['percent']);
			theBar.html(data['percent']);
			theDetails.html(data['details']);
			// We're all set, call me back in 5s
			theProgress.removeClass('progress-striped');
			//theGroup.effect('highlight', {}, 200);
		  setTimeout(function(){UpdateSystemStatus(theGroup, data_url)}, 2000);
			}
		});
	}

function UpdateRefreshable(thePanel, data_url, seconds) {
	// Init
	//thePanel.fadeTo(0, .5);
	thePanel.addClass("updating");

	// Query the source URL to get data
	$.ajax({
		url: data_url,
		type: 'GET',
		data: {ajax:true},
		dataType: "html",
		success: function(data){
			thePanel.html(data);
			//thePanel.fadeTo(0, 1);
			thePanel.removeClass("updating");
		  setTimeout(function(){UpdateRefreshable(thePanel, data_url, seconds)}, seconds*1000);
			}
		});
	}
