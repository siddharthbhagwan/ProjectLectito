$(document).ready ->
	
	$("#profile_DoB").datepicker
  	  changeMonth: true
  	  changeYear: true
  	  yearRange: '1950:2000'
  	  inline: true
  	  dateFormat: 'dd-MM-yy'
  	  class: 'ui-widget-date'

  $(document).on "click", "a[id^='public_rating_']", ->
    tr_id = "872"
    $.ajax
      url: "/profile/public_rating/" + tr_id
      type: "get"
      context: "this"
      dataType: "html"

      success: (msg) ->
        $("#display_public_profile").dialog "open"
        $("#amnb").html(msg)

      complete: (jqXHR, textStatus) ->

      error: (jqXHR, textStatus, errorThrown) ->
        setTimeout $.unblockUI
        $("#error_message").dialog "open"


  $("#display_public_profile").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    buttons:
      "Ok": ->
        $(this).dialog "close"