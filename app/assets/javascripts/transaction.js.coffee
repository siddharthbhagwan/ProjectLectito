# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
    empty_table_checks = ->
      if $("#borrow_requests_table tr").length == 1
        $("#borrow_requests_div").remove()

      if $("#lend_requests_table tr").length == 1
        $("#lend_requests_div").hide().remove()

      if $("#accept_requests_table tr").length == 1
        $("#accept_requests_div").hide().remove()      


    jQuery ->
      empty_table_checks()


    jQuery ->
      $("#error_message").dialog
        autoOpen: false
        modal: true
        buttons:
          "Ok": ->
            $(this).dialog "close"

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

                error: ->
                  setTimeout $.unblockUI
                  $("#error_message").dialog "open"  

          Cancel: ->
            $(this).dialog "close"              



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


    jQuery ->
      $(document).on "click", "#accept", ->
        tr_id = $(this).attr("data-trid")
        tr_id_s = "#" + tr_id
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


    jQuery ->
        updateLendRequests = ->
            if $("#lend_requests_table tr").length > 1
              after = $("#lend_requests_table tbody tr:last-child").attr("data-time")
            else
              after = "0"
            $.getScript("/transaction/get_latest_lent.js?after=" + after)
            setTimeout updateLendRequests, 10000000
        $ ->
            setTimeout updateLendRequests, 10000000  #if $("#lend_requests_table").length > 0  

