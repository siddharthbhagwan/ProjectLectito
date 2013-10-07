$(document).ready ->
	
	$("#profile_DoB").datepicker
  	  changeMonth: true
  	  changeYear: true
  	  yearRange: '1950:2000'
  	  inline: true
  	  dateFormat: 'dd-MM-yy'
  	  class: 'ui-widget-date'