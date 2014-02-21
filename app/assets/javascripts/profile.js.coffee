$(document).ready ->
	
	$('#profile_DoB').datepicker
    dateFormat: 'MM dd, yy'
    yearRange:  '1964:2007'
    defaultDate: 'January 01, 2000'
    class: 'ui-widget-date'
    changeMonth: true
    changeYear: true
    inline: true
    

#----------------------------------------------------------------------------------------------------------------------
  $(document).on "click", "i[id^='public_rating_']", ->
    tr_id = $(this).attr('id').substring(14).toString()
    $.ajax
      url: "/profile/public_rating/" + tr_id + ".json"
      type: "get"
      context: "this"
      dataType: "json"

      success: (msg) ->
        $("#display_public_profile").dialog("option","title",msg[0].name)
        $("#total_transactions b").text(msg[0].transactions)
        $("#total_books b").text(msg[0].books)
        $("#good_transactions b").text(msg[0].good)
        $("#neutral_transactions b").text(msg[0].neutral)
        $("#bad_transactions b").text(msg[0].bad)
        $("#full_profile").replaceWith("<u><a href='/profile/public_rating/" + tr_id + "'>View Complete Profile</a></u>")
        $("#display_public_profile").dialog "open"

      complete: (jqXHR, textStatus) ->

      error: (jqXHR, textStatus, errorThrown) ->
        setTimeout $.unblockUI
        $("#error_message").dialog "open"

#----------------------------------------------------------------------------------------------------------------------

  $("#display_public_profile").dialog
    autoOpen: false
    modal: true
    resizable: false
    draggable: false
    buttons:
      "Ok": ->
        $(this).dialog "close"

    open: (event, ui) ->
      $(":button:contains('Ok')").focus()

      