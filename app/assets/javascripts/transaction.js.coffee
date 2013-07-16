# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

empty_table_checks = ->
  if $("#borrow_requests_table tr").length == 1
    $("#borrow_requests_div").hide()

  if $("#lend_requests_table tr").length == 1
    $("#lend_requests_div").hide()

  if $("#accept_requests_table tr").length == 1
    $("#accept_requests_div").hide()              


jQuery ->
  empty_table_checks()


jQuery ->
  $(document).on "click", ".borrow_button" ,->
    if(confirm("You are about to send a request borrow this book"))
      i = 0
      j = 0
      user_book_id = undefined    
      rental_data = undefined
      row_number = undefined
      rental_data = undefined
      button_id = undefined
      user_book_id = $(this).attr("data-ubid")
      user_id = $(this).attr("data-uid")
      button_id = $(this).attr("id")
      button_id_s = "#" + button_id
      button_id = $(this).attr("id")
      row_number = $(this).closest("tr")[0].rowIndex - 1
      if $("#borrow_requests_table").length > 0
            after_b = $("#borrow_requests_table tbody tr:last-child").attr("data-time")
          else
            after_b = "0"

      if $("#lend_requests_table").length > 0
            after_l = $("#lend_requests_table tbody tr:last-child").attr("data-time")
          else
            after_l = "0"  

      $.ajax
          url: "/transaction.js"
          type: "post"
          context: "this"
          dataType: "script"
          data:
            user_book_id: user_book_id
            user_id: user_id
            after_b: after_b
            after_l: after_l

          beforeSend: ->
            #TODO add loading.gif  

          success: (msg) -> 
          	$(button_id_s).attr("disabled", true) 
          	$(button_id_s).attr("value","Request Sent...")
      
          complete: ->
            #TODO add loading.gif



jQuery ->
  $(document).on "click", "#reject", ->
    tr_id = $(this).attr("data-trid")
    tr_id_s = "#" + tr_id
    $("#reject_request_confirm").data "trid", tr_id
    $("#reject_request_confirm").data "trids", tr_id_s
    $("#reject_request_confirm").dialog "open"


jQuery ->
  $("#reject_request_confirm").dialog
    autoOpen: false
    modal: true
    buttons:
      "Ok": ->
        $(this).dialog "close"
        tr_id = $("#reject_request_confirm").data("trid")
        tr_id_s = $("#reject_request_confirm").data("trids")
        reject_reason = $('input[name=rejectReason]:radio:checked').val()
        alert reject_reason
        $.ajax
          url: "/transaction/update_request_status_reject.js?tr_id=" + tr_id + "&reject_reason=" + reject_reason
          type: "get"
          context: "this"
          dataType: "script"
          data:
            tr_id: tr_id

          success: (msg) ->
            #TODO Add error handling
          complete: (msg) ->
            $(tr_id_s).fadeOut 500, ->
              $(tr_id_s).remove()     

      Cancel: ->
        $(this).dialog "close"    
      

      Cancel: ->
        $(this).dialog "close"

    close: ->
      $(this).dialog "close" 



jQuery ->
  $(document).on "click", "#accept", ->
    tr_id = $(this).attr("data-trid")
    tr_id_s = "#" + tr_id
    $("#accept_request_confirm").data "trid", tr_id
    $("#accept_request_confirm").data "trids", tr_id_s
    $("#accept_request_confirm").dialog "open"


jQuery ->
  $("#accept_request_confirm").dialog
    autoOpen: false
    modal: true
    buttons:
      "Ok": ->
        $(this).dialog "close"
        tr_id = $("#accept_request_confirm").data("trid")
        tr_id_s = $("#accept_request_confirm").data("trids")
        $.ajax
          url: "/transaction/update_request_status_accept.js?tr_id=" + tr_id 
          type: "get"
          context: "this"
          dataType: "script"
          data:
            tr_id: tr_id

          success: (msg) ->
            #TODO Add error handling
          complete: (msg) ->
            $(tr_id_s).fadeOut 500, ->
              $(tr_id_s).remove()     

      Cancel: ->
        $(this).dialog "close"    
      


jQuery ->
    updateLendRequests = ->
        if $("#lend_requests_table").length > 0
          after = $("#lend_requests_table tbody tr:last-child").attr("data-time")
        else
          after = "0"  
        $.getScript("/transaction/get_latest_lent.js?after=" + after)
        setTimeout updateLendRequests, 500000
    $ ->
        setTimeout updateLendRequests, 500000  if $("#lend_requests_table").length > 0     
