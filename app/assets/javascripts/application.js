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
  setTimeout(UpdateMap, 1000);
	}

$(document).ready(function() {
	UpdateMap();
  //setTimeout(UpdateMap, 2000);
});
