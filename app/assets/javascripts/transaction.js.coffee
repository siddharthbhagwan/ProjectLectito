# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

  # Hide tables if no data
    empty_table_checks = ->
      if $("#borrow_requests_table tr").length == 1
        $("#borrow_requests_div").hide()

      if $("#lend_requests_table tr").length == 1
        $("#lend_requests_div").hide().hide()

      if $("#accept_requests_table tr").length == 1
        $("#accept_requests_div").hide().hide()      


    jQuery ->
      empty_table_checks()

#--------------------------------------------------------------------------------------------------------------------
  # Modal Dialog for Errors
    jQuery ->
      $("#error_message").dialog
        autoOpen: false
        modal: true
        buttons:
          "Ok": ->
            $(this).dialog "close"


#--------------------------------------------------------------------------------------------------------------------
  # Create a Transaction on borrowing a book
    jQuery ->
      $(document).on "click", ".borrow_button" ,->
        $("#borrow_confirm").data "inventory_id", $(this).attr("data-ubid")
        $("#borrow_confirm").data "city_id", $(this).attr("data-cityid")
        $("#borrow_confirm").data "user_id", $(this).attr("data-uid")
        $("#borrow_confirm").data "button_id", $(this).attr("id")
        $("#borrow_confirm").data "row_number", button_id = $(this).closest("tr")[0].rowIndex - 1
        $("#borrow_confirm").dialog "open"


    jQuery ->
      $("#borrow_confirm").dialog
        autoOpen: false
        modal: true
        buttons:
          "Ok": ->
            $(this).dialog "close"
            i = 0
            j = 0
            inventory_id = $("#borrow_confirm").data("inventory_id")   
            rental_data = $("#borrow_confirm").data("rental_data")
            row_number = $("#borrow_confirm").data("row_number")
            button_id = $("#borrow_confirm").data("button_id")
            user_id = $("#borrow_confirm").data("user_id")
            city_id = $("#borrow_confirm").data("city_id")
            if $("#borrow_requests_table tr").length == 1
              after_b = "0"
            else
              after_b = $("#borrow_requests_table tbody tr:last-child").attr("data-time")
              
            if $("#lend_requests_table tr").length == 1
                after_l = "0"
            else
              after_l = $("#lend_requests_table tbody tr:last-child").attr("data-time")
            $.ajax
                url: "/transaction.js"
                type: "post"
                context: "this"
                dataType: "script"
                data:
                  inventory_id: inventory_id
                  user_id: user_id
                  after_b: after_b
                  after_l: after_l

                beforeSend: ->
                  $.blockUI
                    theme:     true, 
                    title:    'Please Wait', 
                    message:  '<p>Your request is being processed</p>'   

                success: (msg) ->
            
                complete: ->
                  $("#" + button_id).attr("disabled","true").attr("value","Request Sent...")
                  setTimeout $.unblockUI
                  $("#city_" + city_id).hide()
                  $("#" + city_id).attr("data-status","closed")

                error: ->
                  setTimeout $.unblockUI
                  $("#error_message").dialog "open"  

          Cancel: ->
            $(this).dialog "close"              

 
#--------------------------------------------------------------------------------------------------------------------
  # Update a transaction on request being Accepted
    jQuery ->
      $(document).on "click", "#accept", ->
        tr_id = $(this).attr("data-trid")
        tr_id_s = "#lend_" + tr_id
        $("#accept_request_confirm").data "trid", tr_id
        $("#accept_request_confirm").data "trids", tr_id_s
        arr = []
        arr = $(tr_id_s).find("td").map(->
          @innerHTML
        ).get()
        html_data = "You are about to accept a request to borrow " + arr[0] + " from " + arr[1]
        $("#accept_info").html(html_data)
        $("#date_test").datepicker()
        $("#dispatch_date").focus()
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
              url: "/transaction/update_request_status_accept.js"
              type: "get"
              context: "this"
              dataType: "script"
              data:
                tr_id: tr_id

              success: (msg) ->

              complete: (msg) ->
                $(tr_id_s).fadeOut(500).remove()
                empty_table_checks()
              error: ->
                setTimeout $.unblockUI
                $("#error_message").dialog "open"       

          Cancel: ->
            $(this).dialog "close"          



#--------------------------------------------------------------------------------------------------------------------
  # Update a transaction on request being rejected
    jQuery ->
      $(document).on "click", "#reject", ->
        tr_id = $(this).attr("data-trid")
        tr_id_s = "#lend_" + tr_id
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
            $.ajax
              url: "/transaction/update_request_status_reject.js?"
              type: "get"
              context: "this"
              dataType: "script"
              data:
                tr_id: tr_id
                reject_reason: reject_reason

              success: (msg) ->

              complete: (msg) ->
                $(tr_id_s).fadeOut(500).remove()
                empty_table_checks()
              error: ->
                setTimeout $.unblockUI
                $("#error_message").dialog "open"         

          Cancel: ->
            $(this).dialog "close"   



#--------------------------------------------------------------------------------------------------------------------
  # Update  transaction on request being cancelled
    jQuery ->
      $(document).on "click", ".cancel_trans", ->
        $("#cancel_transaction").data "tr_id", $(this).attr "data-trid"
        $("#cancel_transaction").dialog "open"
        console.log("Cancelling Tranaction with id " + $(this).attr "data-trid")      



    jQuery ->
      $("#cancel_transaction").dialog
        autoOpen: false
        modal: true
        buttons:
          "Ok": ->
            $(this).dialog "close"
            tr_id = $("#cancel_transaction").data("tr_id")
            $.ajax
              url: "/transaction/update_request_status_cancel.js"
              type: "post"
              context: "this"
              dataType: "script"
              data:
                tr_id: tr_id

              success: (msg) ->

              complete: (msg) ->
                $("#borrow_" + tr_id).fadeOut(500).remove()
                empty_table_checks()
              error: ->
                setTimeout $.unblockUI
                $("#error_message").dialog "open"                        

          Cancel: ->
            $(this).dialog "close"    


#--------------------------------------------------------------------------------------------------------------------
  # Poll to check for new requests
    jQuery ->
        updateLendRequests = ->
            if $("#lend_requests_table tr").length > 1
              after = $("#lend_requests_table tbody tr:last-child").attr("data-time")
            else
              after = "0"
            $.getScript("/transaction/latest_lent.js?after=" + after)
            #setTimeout updateLendRequests, 500000
        $ ->
            #setTimeout updateLendRequests, 500000  #if $("#lend_requests_table").length > 0  

#--------------------------------------------------------------------------------------------------------------------
  #SSE Listener  #TODO Remove bracket element so its no more an element
    jQuery ->
      id = $(".testxyz").attr("id")
      source = new EventSource('transaction/latest_lent')
      source.addEventListener 'transaction_created_' + id, (e) ->
        pData = $.parseJSON(e.data)
        tr_id = "<tr id= 'lend_'" + pData[0].ID + "' data-time='" + pData[0].updated_at  + "'>"
        td_book_name = "<td>" + pData[0].book_name + "</td>"
        td_requested_from = "<td>" + pData[0].requested_from + "</td>"
        td_requested_date = "<td>" + pData[0].requested_date + "</td>"
        td_status = "<td>" + pData[0].status + "</td>"
        td_accept = "<td><input class='btn btn-small' type='button' value='Accept' id='accept' data-trid=" + pData[0].id + "/></td>"
        td_reject = "<td><input class='btn btn-small' type='button' value='Reject' id='reject' data-trid=" + pData[0].id + "/></td></tr>"  
        table_row_data = tr_id + td_book_name + td_requested_from + td_requested_date + td_status + td_accept + td_reject
        $("#lend_requests_table > tbody:last").append(table_row_data);
        if (!$("#lend_requests_div").is(":visible"))
          $("#lend_requests_div").show(500)

#--------------------------------------------------------------------------------------------------------------------
  #SSE Listener  
    jQuery ->
      id = $(".testxyz").attr("id")
      source = new EventSource('transaction/latest_cancelled')
      source.addEventListener 'transaction_cancelled_' + id, (e) ->
        console.log $("#lend_requests_table tr").length
        if $("#lend_requests_table tr").length == 2
          $("#lend_requests_div").hide()
          $("#lend_" + e.data).remove()
        else
          $("#lend_" + e.data).remove() 


#--------------------------------------------------------------------------------------------------------------------
  #SSE Listener  
    jQuery ->
      id = $(".testxyz").attr("id")
      source = new EventSource('transaction/latest_cancelled')
      source.addEventListener 'transaction_cancelled_' + id, (e) ->
        console.log $("#lend_requests_table tr").length
        if $("#lend_requests_table tr").length == 2
          $("#lend_requests_div").hide()
          $("#lend_" + e.data).remove()
        else
          $("#lend_" + e.data).remove() 


           