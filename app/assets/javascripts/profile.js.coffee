# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
#	$('#profile_DoB').attr("class","ui-widget")

jQuery ->
	$("#profile_DoB").datepicker
  	  changeMonth: true
  	  changeYear: true
  	  yearRange: '1950:2000'
  	  inline: true
  	  dateFormat: 'dd-MM-yy'
