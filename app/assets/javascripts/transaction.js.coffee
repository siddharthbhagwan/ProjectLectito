# # Place all the behaviors and hooks related to the matching controller here.
# # All this logic will automatically be available in application.js.
# # You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->

  # Hide tables if no data
  empty_table_checks = ->
    if $("#borrow_requests_table tr").length == 1
      $("#borrow_requests_div").hide()

    if $("#lend_requests_table tr").length == 1
      $("#lend_requests_div").hide()

    if $("#accepted_requests_table tr").length == 1
      $("#accepted_requests_div").hide()

    if $("#current_books_table tr").length == 1
      $("#current_books_div").hide()

#--------------------------------------------------------------------------------------------------------------------

  empty_table_checks()

#--------------------------------------------------------------------------------------------------------------------
  # Modal Dialog for 403 Errors
  $("#error_message_403").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    buttons:
      "Ok": ->
        $(this).dialog "close"


  # Modal Dialog for Generic Errors
  $("#error_message_generic").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    buttons:
      "Ok": ->
        $(this).dialog "close"      

#--------------------------------------------------------------------------------------------------------------------
  # Create a Transaction on borrowing a book
  $(document).on "click", ".borrow_button" ,->
    $("#borrow_confirm").data "inventory_id", $(this).attr("data-ubid")
    $("#borrow_confirm").data "city_id", $(this).attr("data-cityid")
    $("#borrow_confirm").data "user_id", $(this).attr("data-uid")
    $("#borrow_confirm").data "button_id", $(this).attr("id")
    $("#borrow_confirm").data "row_number", button_id = $(this).closest("tr")[0].rowIndex - 1
    $("#borrow_confirm_title").text($("#" + $(this).attr("data-cityid") + " td:nth-last-child(1)").text())
    selftodel = $(this).attr("data-selftodel")
    if selftodel == 'true'
      $("#selftodel").html("<b>Kindly note that a delivery charge of &#8377; 60 will be applicable<b>")

    $("#borrow_confirm").dialog "open"


  $("#borrow_confirm").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
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
                draggable: false

            success: (msg) ->

            complete: (jqXHR, textStatus) ->
              $("#" + button_id).attr("disabled","true").attr("value","Request Sent...")
              $("#city_" + city_id).hide()
              $("#" + city_id).attr("data-status","closed")
              setTimeout $.unblockUI

            error: ->
              setTimeout $.unblockUI
              $("#error_message").dialog "open"  

      Cancel: ->
        $(this).dialog "close"       

#----------------------------------------------------------------------------------------------------------------------
# Update a transaction on request being Accepted in delivery mode
  $(document).on "click", "#accept_delivery", ->
    tr_id = $(this).attr("data-trid")
    tr_id_s = "#lend_" + tr_id
    $("#accept_request_confirm").data "trid", tr_id
    $("#accept_request_confirm").data "trids", tr_id_s
    arr = []
    arr = $(tr_id_s).find("td").map(->
      @innerHTML
    ).get()
    html_data = "You are about to accept a request to borrow '" + arr[0] + "' from " + arr[1]
    $("#accept_info").html(html_data)
    $("#dispatch_date").datepicker
      showOn: "button"
      buttonImageOnly: true
    $("#accept_request_confirm").dialog "open"
    $("#accept_request_confirm").data "dispatch_date", $("#dispatch_date").val()
    $("#accept_request_confirm").data "dispatch_time", $("input[type='radio'][name='dispatchTime']:checked").val()


  $("#accept_request_confirm").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    buttons:
      "Ok": ->
        $(this).dialog "close"
        tr_id = $("#accept_request_confirm").data("trid")
        tr_id_s = $("#accept_request_confirm").data("trids")
        $.ajax
          url: "/transaction/update_request_status_accept.json"
          type: "post"
          context: "this"
          dataType: "json"
          data:
            tr_id: tr_id
            dispatch_date: $("#accept_request_confirm").data "dispatch_date"
            dispatch_time: $("#accept_request_confirm").data "dispatch_time"

          beforeSend: ->
            $.blockUI
              theme:     true, 
              title:    'Please Wait', 
              message:  '<p>Your request is being processed</p>'
              draggable: false

          success: (msg) ->

          complete: (jqXHR, textStatus) ->
            $(tr_id_s).fadeOut(500).remove()
            empty_table_checks()
            setTimeout $.unblockUI

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            $("#error_message").dialog "open"       

      Cancel: ->
        $(this).dialog "close"

    open: (event, ui) ->
      $(":button:contains('Ok')").focus()  

#--------------------------------------------------------------------------------------------------------------------

# Update a transaction on request being Accepted in self pick/drop mode
  $(document).on "click", "#accept_self", ->
    tr_id = $(this).attr("data-trid")
    tr_id_s = "#lend_" + tr_id
    $("#accept_self_confirm").data "trid", tr_id
    $("#accept_self_confirm").data "trids", tr_id_s
    $("#accept_self_confirm").dialog "open"
    
  $("#accept_self_confirm").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    buttons:
      "Ok": ->
        $(this).dialog "close"
        tr_id = $("#accept_self_confirm").data "trid"
        tr_id_s = $("#accept_self_confirm").data "trids"
        $.ajax
          url: "/transaction/update_request_status_accept.json"
          type: "post"
          context: "this"
          dataType: "json"
          data:
            tr_id: tr_id

          beforeSend: ->
            $.blockUI
              theme:     true, 
              title:    'Please Wait', 
              message:  '<p>Your request is being processed</p>'
              draggable: false

          success: (msg) ->
            console.log msg

          complete: (jqXHR, textStatus) ->
            $(tr_id_s).remove()
            empty_table_checks()
            setTimeout $.unblockUI

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            if jqXHR.status is 403
              $("#error_message_403").dialog "open"  
            else
              $("#error_message_generic").dialog "open"  

      Cancel: ->
        $(this).dialog "close"

    open: (event, ui) ->
      $(":button:contains('Ok')").focus()       

#--------------------------------------------------------------------------------------------------------------------
# Update a transaction on request being rejected
  $(document).on "click", "#reject", ->
    tr_id = $(this).attr("data-trid")
    tr_id_s = "#lend_" + tr_id
    $("#reject_request_confirm").data "trid", tr_id
    $("#reject_request_confirm").data "trids", tr_id_s
    $("#reject_request_confirm").dialog "open"


  $("#reject_request_confirm").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    buttons:
      "Ok": ->
        $(this).dialog "close"
        tr_id = $("#reject_request_confirm").data("trid")
        tr_id_s = $("#reject_request_confirm").data("trids")
        reject_reason = $('input[name=rejectReason]:radio:checked').val()
        $.ajax
          url: "/transaction/update_request_status_reject.json"
          type: "post"
          context: "this"
          dataType: "json"
          data:
            tr_id: tr_id
            reject_reason: reject_reason

          beforeSend: ->
            $.blockUI
              theme:     true, 
              title:    'Please Wait', 
              message:  '<p>Your request is being processed</p>'
              draggable: false  

          success: (msg) ->

          complete: (jqXHR, textStatus) ->
            $(tr_id_s).fadeOut(500).remove()
            empty_table_checks()
            setTimeout $.unblockUI

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            $("#error_message").dialog "open"         

      Cancel: ->
        $(this).dialog "close"

    open: (event, ui) ->
      $(":button:contains('Ok')").focus()

#--------------------------------------------------------------------------------------------------------------------
#Update transaction on request being cancelled
  $(document).on "click", ".cancel_trans", ->
    $("#cancel_transaction").data "tr_id", $(this).attr "data-trid"
    $("#cancel_transaction").dialog "open"      


  $("#cancel_transaction").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    buttons:
      "Ok": ->
        $(this).dialog "close"
        tr_id = $("#cancel_transaction").data("tr_id")
        $.ajax
          url: "/transaction/update_request_status_cancel.json"
          type: "post"
          context: "this"
          dataType: "json"
          data:
            tr_id: tr_id

          beforeSend: ->
            $.blockUI
              theme:     true, 
              title:    'Please Wait', 
              message:  '<p>Your request is being processed</p>'
              draggable: false

          success: (msg) ->

          complete: (jqXHR, textStatus) ->
            $("#borrow_" + tr_id).fadeOut(500).remove()
            empty_table_checks()
            setTimeout $.unblockUI

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            $("#error_message").dialog "open"                        

      Cancel: ->
        $(this).dialog "close"

#--------------------------------------------------------------------------------------------------------------------
  #SSE Listener for creating a transaction
  #TODO Remove bracket element so its no more an element
  $.ajax
    url: "/transaction/user_id.json"
    type: "get"
    context: "this"
    dataType: "json"

    success: (msg) ->
      id = msg.user_id
      myFirebase = new Firebase("https://projectlectito.firebaseio.com/")
      myChild = myFirebase.child("transaction_listener_" + id)
      myChild.on "child_added", (childSnapshot, prevChildName) ->
        pData = $.parseJSON(childSnapshot.val())
        # Summary of Requests for Books users want to borrow from you (lender)
        if pData[0] == "create"
          if !$("#lend_" + pData[1].id).length and !$("#accepted_" + pData[1].id).length
            noty
              text: pData[1].name + " would like to borrow '" + pData[1].book_name + "' from you"
              layout: "topRight"
              closeWith: ["click"]
              callback:
                onClose: ->
                  noty_confirm()

            tr_id = "<tr id='lend_" + pData[1].id + "'>"
            td_book_name = "<td>" + pData[1].book_name + "</td>"
            td_borrower = "<td><a href='javascript:void(0)' id='public_rating_" + pData[1].id + "'>" + pData[1].borrower + "</td>"
            
            if pData[1].delivery_mode
              td_delivery_mode = "<td>Delivery</td>"
              td_accept = "<td><input class='btn btn-small' type='button' value='Accept' id='accept_delivery' data-trid=" + pData[1].id + "></td>"
            else
              td_delivery_mode = "<td>Self Pick/Drop</td>"
              td_accept = "<td><input class='btn btn-small' type='button' value='Accept' id='accept_self' data-trid=" + pData[1].id + "></td>"

            td_requested_from = "<td>" + pData[1].requested_from + "</td>"
            td_requested_date = "<td>" + pData[1].requested_date + "</td>"
            td_status = "<td>" + pData[1].status + "</td>"
            td_reject = "<td><input class='btn btn-small' type='button' value='Reject' id='reject' data-trid=" + pData[1].id + "></td></tr>"
            table_row_data = tr_id + td_book_name + td_borrower + td_requested_from + td_delivery_mode + td_requested_date + td_status + td_accept + td_reject
            $("#lend_requests_table > tbody:last").append(table_row_data);
            if (!$("#lend_requests_div").is(":visible"))
              $("#lend_requests_div").show(500)  

        #Summary of Requests for Books you've lent out (lender)
        else if pData[0] == "accepted_borrower"
          if !$("#accepted_" + pData[1].id).length
            tr_id = "<tr id='accepted_" + pData[1].id + "'>"
            td_book_name = "<td>" + pData[1].book_name + "</td>"
            
            if pData[1].online == "Online"
              td_b_base = "<img width='10' height='6' src='/assets/online_dot.png' data-trid='" + pData[1].id + "' id='online_" + pData[1].id + "' "  
            else
              td_b_base = "<img width='10' height='6' hidden='true' src='/assets/online_dot.png' data-trid='" + pData[1].id + "' id='online_" + pData[1].id + "' "  

            td_b_ccn = "data-currentcn='" + pData[1].currentcn + "' "
            td_b_bcn = "data-borrowercn='" + pData[1].borrowercn + "' "
            td_b_lcn = "data-lendercn='" + pData[1].lendercn + "' "  
            td_b_title = "data-title='" + pData[1].title + "' "
            online_dot = td_b_base + td_b_ccn + td_b_bcn + td_b_lcn + td_b_title + "/>"
            profile_link = "<td><a href='javascript:void(0)' id='public_rating_" + pData[1].id + "'>" + pData[1].borrower + "</a>"
            td_borrower = profile_link + "&nbsp;&nbsp;" + online_dot

            if pData[1].delivery_mode
              td_delivery_mode = "<td>Delivery</td>"
              td_status = "<td><p id='p_accepted_" + pData[1].id + "'> Sent to Borrower</p><input class='btn btn-small' type='button' disabled='true' value='Received' id='received_lender_" + pData[1].id + "' data-trid=" + pData[1].id + "></td></tr>"
            else
              td_delivery_mode = "<td>Self Pick/Drop</td>"
              td_status = "<td><p id='p_accepted_" + pData[1].id + "'> Meetup as decided</p><input class='btn btn-small' type='button' value='Handed Over' id='handed_over_" + pData[1].id + "' data-trid=" + pData[1].id + "></td></tr>"

            td_acceptance_date = "<td>" + pData[1].acceptance_date + "</td>"
            td_returned_date = "<td>Pending</td>"
            td_received_date = "<td>Pending</td>"
            table_row_data = tr_id + td_book_name + td_borrower + td_delivery_mode + td_acceptance_date + td_received_date + td_returned_date + td_status
            $("#accepted_requests_table > tbody:last").append(table_row_data)
            if (!$("#accepted_requests_div").is(":visible"))
              $("#accepted_requests_div").show(500)

            $("#chat_divs").append("<div id='chat_div_" + pData[1].id + "''></div>")   
        
        #Summary of Books currently with you (borrower)
        else if pData[0] == "accepted_lender"
          if !$("#current_" + pData[1].id).length
            noty
              text: pData[1].lender + " has agreed to lend you '" + pData[1].book_name + "'"
              layout: "topRight"
              closeWith: ["click"]
              callback:
                onClose: ->
                  noty_confirm()

            $("#borrow_" + pData[1].id).remove()
            empty_table_checks()
            tr_id = "<tr id='current_" + pData[1].id + "'>"
            td_book_name = "<td>" + pData[1].book_name + "</td>"

            if pData[1].online == "Online"
              td_c_base = "<img width='10' height='6' src='/assets/online_dot.png' data-trid='" + pData[1].id + "' id='online_" + pData[1].id + "' "  
            else
              td_c_base = "<img width='10' hidden='true' height='6' src='/assets/online_dot.png' data-trid='" + pData[1].id + "' id='online_" + pData[1].id + "' "

            td_c_ccn = "data-currentcn='" + pData[1].currentcn + "' "
            td_c_bcn = "data-borrowercn='" + pData[1].borrowercn + "' "
            td_c_lcn = "data-lendercn='" + pData[1].lendercn + "' "  
            td_c_title = "data-title='" + pData[1].title + "' "
            online_dot = td_c_base + td_c_ccn + td_c_bcn + td_c_lcn + td_c_title + "/>"
            lender_link = "<td><a href='javascript:void(0)' id='public_rating_" + pData[1].id + "'>" + pData[1].lender + "</a>"
            td_lender = lender_link + "&nbsp;&nbsp;" + online_dot

            if pData[1].delivery_mode
              td_delivery_mode = "<td>Delivery</td>"
              td_status = "<td><p id='p_current_" + pData[1].id + "'> Sent by Lender</p><input class='btn btn-small' type='button' value='Received' id='received_borrower_" + pData[1].id + "' data-trid='" +  pData[1].id + "'/></td></tr>"
            else
              td_delivery_mode = "<td>Self Pick/Drop</td>"
              td_status = "<td><p id='p_current_" + pData[1].id + "'> Meetup as decided</p><input class='btn btn-small' type='button' value='Received' id='received_borrower_" + pData[1].id + "' data-trid='" +  pData[1].id + "'/></td></tr>"

            td_acceptance_date = "<td>" + pData[1].acceptance_date + "</td>"
            td_received_date = "<td>Pending</td>"
            td_return_date = "<td>Pending</td>"
            #td_status = "<td><p id='p_current_" + pData[1].id + "'> Sent by Lender</p><input class='btn btn-small' type='button' value='Received' id='received_borrower_" + pData[1].id + "' data-trid='" +  pData[1].id + "'/></td></tr>"
            table_row_data = tr_id + td_book_name + td_lender + td_delivery_mode + td_acceptance_date + td_received_date + td_return_date + td_status       
            $("#current_books_table > tbody:last").append(table_row_data)
            if (!$("#current_books_div").is(":visible"))
              $("#current_books_div").show(500)

            $("#chat_divs").append("<div id='chat_div_" + pData[1].id + "''></div>")    

        #Summary of Requests for Books you've lent out ( recvd button activates )
        else if pData[0] == "returned" #FIXME
          if $("#received_lender_" + pData[1].id).attr("disabled") == "disabled"
            noty
                text: pData[1].name + " has initiated the return of '" + pData[1].book_name + "'"
                layout: "topRight"
                closeWith: ["click"]
                callback:
                  onClose: ->
                    noty_confirm()

            $("#received_lender_" + pData[1].id).removeAttr("disabled")
            $("#p_accepted_" + pData[1].id).text("Returned by Borrower ").fadeIn(300)
            $("#accepted_" + pData[1].id + " td:nth-last-child(2)").text(pData[1].returned_date).fadeIn(300) 

        else if pData[0] == "rejected_lender"
          $("#lend_" + pData[1].id).remove()
          empty_table_checks()

        else if pData[0] == "rejected_borrower"
          $("#borrow_" + pData[1].id).remove()
          empty_table_checks()

          noty
            text: "Your request to borrow '" + pData[1].book_name + "' has been rejected as the book has been lent out"
            layout: "topRight"
            closeWith: ["click"]
            callback:
              onClose: ->
                noty_confirm()

        else if pData[0] == "cancelled"
          noty
            text: "A request to borrow '" + pData[1].book_name + "' from you has been cancelled"
            layout: "topRight"
            closeWith: ["click"]
            callback:
              onClose: ->
                noty_confirm()

          $("#lend_" + pData[1].id).remove()
          empty_table_checks()

        else if pData[0] == "rejected"
          if pData[1].reason == "Unavailable"
            noty
              text: "Your request to borrow '" + pData[1].book_name + "' has been rejected as " + pData[1].name + " is Unavailable"
              layout: "topRight"
              closeWith: ["click"]
              callback:
                onClose: ->
                  noty_confirm()

          else
            noty
              text: "Your request to borrow '" + pData[1].book_name + "' has been rejected"
              layout: "topRight"
              closeWith: ["click"]
              callback:
                onClose: ->
                  noty_confirm()

          $("#borrow_" + pData[1].id).remove()
          empty_table_checks()

        else if pData[0] == "received_lender"
          noty
            text: pData[1].name + " has received " + "'" + pData[1].book_name 
            layout: "topRight"
            closeWith: ["click"]
            callback:
              onClose: ->
                noty_confirm()

          $("chat_div_" + pData[1].id).remove()  

        #Lender triggers that book's been handed over in self/pick drop.
        else if pData[0] == "received_borrower_by_lender"
          if  $("#received_borrower_" + pData[1].id).attr("value") != "Return"
            $("#current_" + pData[1].id + " td:nth-last-child(3)").text(pData[1].received_date)
            noty
              text: pData[1].name + " has handed over '" + pData[1].book_name + "'"
              layout: "topRight"
              closeWith: ["click"]
              callback:
                onClose: ->
                  noty_confirm()

              if pData[1].delivery_mode
                $("#received_borrower_" + pData[1].id).attr("value", "Return")
                $("#received_borrower_" + pData[1].id).attr("id", "return_delivery")

              else
                $("#p_current_" + pData[1].id).text("Received by You. Meetup to Return")
                $("#received_borrower_" + pData[1].id).attr("value", "Returned")
                $("#received_borrower_" + pData[1].id).attr("id", "return_self")


        #Borrower triggers that the books been received. If its by self Pic and drop, coln change on lender's side
        else if pData[0] == "received_borrower_by_borrower"
          if $("#accepted_" + pData[1].id + " td:nth-last-child(3)").text() == "Pending"
            $("#accepted_" + pData[1].id + " td:nth-last-child(3)").text(pData[1].received_date)
            $("#p_accepted_" + pData[1].id).text("Received by Borrower")
            noty
              text: pData[1].name + " has successfully received '" + pData[1].book_name + "'"
              layout: "topRight"
              closeWith: ["click"]
              callback:
                onClose: ->
                  noty_confirm()

            if !pData[1].delivery_mode
              $("#handed_over_" + pData[1].id).attr("value", "Received")
              $("#handed_over_" + pData[1].id).attr("disabled", "true")
              $("#handed_over_" + pData[1].id).attr("id", "received_lender_" + pData[1].id)

        else if pData[0] == "received_borrower_by_borrower_lender"
          $("#current_" + pData[1].id + " td:nth-last-child(3)").text(pData[1].received_date)

        else if pData[0] == "received_borrower_by_lender_borrower"
          $("#accepted_" + pData[1].id + " td:nth-last-child(3)").text(pData[1].received_date)  

        # else if pData[0] == "offline"
        #   $("#online_" + pData[1].id).attr("hidden", "true")

        # else if pData[0] == "online"
        #   $("#online_" + pData[1].id).removeAttr("hidden")

        myChild.remove()  

    complete: (jqXHR, textStatus) ->

    error: (jqXHR, textStatus, errorThrown) ->
      # setTimeout $.unblockUI
      # $("#error_message").dialog "open" 

           
#--------------------------------------------------------------------------------------------------------------------
# Initiate Return from borrowers side with pickup time
  $(document).on "click", "#return_delivery", ->
    tr_id = $(this).attr("data-trid")
    tr_id_s = "#current_" + tr_id
    $("#return_request_confirm").data "trid", tr_id
    $("#return_request_confirm").data "trids", tr_id_s
    # arr = []
    # arr = $(tr_id_s).find("td").map(->
    #   @innerHTML
    # ).get()
    # html_data = "You are about to accept a request to borrow " + arr[0] + " from " + arr[1]
    # $("#accept_info").html(html_data)
    $("#borrower_returned_book_confirm").data "trid", tr_id
    $("#borrower_returned_book_confirm").data "trids", tr_id_s
    $("#borrower_returned_book_confirm").data "mode", "delivery"
    $("#borrower_returned_book_confirm").dialog "open"
    $("#return_pickup_date").datepicker
      showOn: "button"
      buttonImageOnly: true
    $("#return_request_confirm").dialog "open"
    $("#return_request_confirm").data "return_date", $("#dispatch_date").val()
    $("#return_request_confirm").data "return_time", $("input[type='radio'][name='return_time']:checked").val()


  $("#return_request_confirm").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    buttons:
      "Ok": ->
        $(this).dialog "close"
        tr_id = $("#return_request_confirm").data("trid")
        tr_id_s = $("#return_request_confirm").data("trids")
        $.ajax
          url: "/transaction/update_request_status_return.json"
          type: "post"
          context: "this"
          dataType: "json"
          data:
            tr_id: tr_id
            return_date: $("#return_request_confirm").data "return_date"
            return_time: $("#return_request_confirm").data "return_time"

          beforeSend: ->
            $.blockUI
              theme:     true, 
              title:    'Please Wait', 
              message:  '<p>Your request is being processed</p>'
              draggable: false

          success: (msg) ->
            
          complete: (jqXHR, textStatus) ->
            setTimeout $.unblockUI

          error:  (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            $("#error_message").dialog "open"       

      Cancel: ->
        $(this).dialog "close"
        $("#borrower_returned_book_confirm").dialog "close"

    beforeClose: (event) ->
      if event.keyCode is $.ui.keyCode.ESCAPE
        $(this).dialog "close"
        $("#borrower_returned_book_confirm").dialog "close"    

#--------------------------------------------------------------------------------------------------------------------
# Initiate Return from borrowers side in self delivery mode
  $(document).on "click", "#return_self", ->  
    tr_id = $(this).attr("data-trid")
    tr_id_s = "#current_" + tr_id
    $("#borrower_returned_book_confirm").data "trid", tr_id
    $("#borrower_returned_book_confirm").data "trids", tr_id_s
    $("#borrower_returned_book_confirm").data "mode", "self"
    $("#borrower_returned_book_confirm").dialog "open"


  $("#borrower_returned_book_confirm").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    buttons:
      "Ok": ->
        $(this).dialog "close"
        tr_id = $("#borrower_returned_book_confirm").data("trid")
        tr_id_s = $("#borrower_returned_book_confirm").data("trids")
        $.ajax
          url: "/transaction/update_request_status_return.json"
          type: "post"
          context: "this"
          dataType: "json"
          data:
            tr_id: tr_id
            borrower_feedback: $("input[type='radio'][name='borrower_feedback']:checked").val()
            borrower_comments: $("#borrower_comments").val()

          beforeSend: ->
            $.blockUI
              theme:     true, 
              title:    'Please Wait', 
              message:  '<p>Your request is being processed</p>'
              draggable: false  

          success: (msg) ->

          complete: (jqXHR, textStatus) ->
            noty
              text: "You have initiated the return of '" + $("#current_" + tr_id + " td:nth-last-child(7)").text() + "' " 
              layout: "topRight"
              closeWith: ["click"]
              callback:
                onClose: ->
                  noty_confirm()

            $(tr_id_s).remove()
            $('input:radio[name=borrower_feedback]').val(['neutral']);
            $("#borrower_comments").val("")
            if $("#current_books_table tr").length == 1
              $("#current_books_div").hide()  

            setTimeout $.unblockUI  

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            $("#error_message").dialog "open"       

      "Skip": ->
        $(this).dialog "close"
        tr_id = $("#borrower_returned_book_confirm").data("trid")
        tr_id_s = $("#borrower_returned_book_confirm").data("trids")
        $.ajax
          url: "/transaction/update_request_status_return.json"
          type: "post"
          context: "this"
          dataType: "json"
          data:
            tr_id: tr_id
            borrower_feedback: ""
            borrower_comments: ""

          beforeSend: ->
            $.blockUI
              theme:     true, 
              title:    'Please Wait', 
              message:  '<p>Your request is being processed</p>'
              draggable: false

          success: (msg) ->

          complete: (jqXHR, textStatus) ->
            noty
              text: "You have initiated the return of '" + $("#current_" + tr_id + " td:nth-last-child(7)").text() + "'" 
              layout: "topRight"
              closeWith: ["click"]
              callback:
                onClose: ->
                  noty_confirm()
                  
            $(tr_id_s).remove()
            $('input:radio[name=borrower_feedback]').val(['neutral']);
            $("#borrower_comments").val("")
            if $("#current_books_table tr").length == 1
              $("#current_books_div").hide()

            setTimeout $.unblockUI  

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            $("#error_message").dialog "open"       
  

      Cancel: ->
        tr_id = $("#borrower_returned_book_confirm").data("trid")
        tr_id_s = $("#borrower_returned_book_confirm").data("trids")
        noty
          text: "You have initiated the return of '" + $("#current_" + tr_id + " td:nth-last-child(7)").text() + "'" 
          layout: "topRight"  
          closeWith: ["click"]
          callback:
            onClose: ->
              noty_confirm()

        $(this).dialog "close"
        tr_id_s = $("#borrower_returned_book_confirm").data("trids")
        $(tr_id_s).remove()
        if $("#current_books_table tr").length == 1
          $("#current_books_div").hide()


    beforeClose: (event) ->
      if event.keyCode is $.ui.keyCode.ESCAPE
        mode = $("#borrower_returned_book_confirm").data("mode")
        tr_id = $("#borrower_returned_book_confirm").data("trid")
        tr_id_s = $("#borrower_returned_book_confirm").data("trids")
        if mode == "delivery"
          noty
            text: "You have initiated the return of '" + $("#current_" + tr_id + " td:nth-last-child(7)").text() + "'" 
            layout: "topRight"
            closeWith: ["click"]
            callback:
              onClose: ->
                noty_confirm()

          tr_id_s = $("#borrower_returned_book_confirm").data("trids")
          $(tr_id_s).remove()
          if $("#current_books_table tr").length == 1
            $("#current_books_div").hide()


    open: (event, ui) ->
      $(":button:contains('Ok')").focus()

#--------------------------------------------------------------------------------------------------------------------
# Initiate Compelte transaction from lender side

  $(document).on "click", "input[id^='received_lender_']", ->
    tr_id = $(this).attr("data-trid")
    tr_id_s = "#accepted_" + tr_id
    $("#lender_received_book_confirm").data "trid", tr_id
    $("#lender_received_book_confirm").data "trids", tr_id_s
    # arr = []
    # arr = $(tr_id_s).find("td").map(->
    #   @innerHTML
    # ).get()
    # html_data = "You are about to accept a request to borrow " + arr[0] + " from " + arr[1]
    # $("#accept_info").html(html_data)
    $("#lender_received_book_confirm").dialog "open"

#TODO write a fn for ajax call
  $("#lender_received_book_confirm").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    buttons:
      "Ok": ->
        $(this).dialog "close"
        tr_id = $("#lender_received_book_confirm").data("trid")
        tr_id_s = $("#lender_received_book_confirm").data("trids")
        $.ajax
          url: "/transaction/update_request_status_receive_lender.json"
          type: "post"
          context: "this"
          dataType: "json"
          data:
            tr_id: tr_id
            lender_feedback: $("input[type='radio'][name='lender_feedback']:checked").val()
            lender_comments: $("#lender_comments").val()

          beforeSend: ->
            $.blockUI
              theme:     true,
              title:    'Please Wait',
              message:  '<p>Your request is being processed</p>'
              draggable: false

          success: (msg) ->

          complete: (jqXHR, textStatus) ->
            $(tr_id_s).remove()
            $("#lender_comments").val("")
            $('input:radio[name=lender_feedback]').val(['neutral'])
            if $("#accepted_requests_table tr").length == 1
              $("#accepted_requests_div").hide()

            setTimeout $.unblockUI  

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            $("#error_message").dialog "open"       

      "Skip": ->
        $(this).dialog "close"
        tr_id = $("#lender_received_book_confirm").data("trid")
        tr_id_s = $("#lender_received_book_confirm").data("trids")
        $.ajax
          url: "/transaction/update_request_status_receive_lender.json"
          type: "post"
          context: "this"
          dataType: "json"
          data:
            tr_id: tr_id
            lender_feedback: ""
            lender_comments: ""
            
          beforeSend: ->
            $.blockUI
              theme:     true,
              title:    'Please Wait',
              message:  '<p>Your request is being processed</p>'
              draggable: false

          success: (msg) ->

          complete: (jqXHR, textStatus) ->
            $(tr_id_s).remove()
            if $("#accepted_requests_table tr").length == 1
              $("#accepted_requests_div").hide()

            setTimeout $.unblockUI  

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            $("#error_message").dialog "open"

      Cancel: ->
        $(this).dialog "close"

    open: (event, ui) ->
      $(":button:contains('Ok')").focus()      

#-------------------------------------------------------------------------------------------------------------------- 
  $(document).on "click", "input[id^='received_borrower_']", ->
    tr_id = $(this).attr("data-trid")
    tr_id_s = "#received_borrower_" + tr_id
    $("#received_borrower_confirm").data "trid", tr_id
    $("#received_borrower_confirm").data "trids", tr_id_s
    # arr = []
    # arr = $(tr_id_s).find("td").map(->
    #   @innerHTML
    # ).get()
    # html_data = "You are about to accept a request to borrow " + arr[0] + " from " + arr[1]
    # $("#accept_info").html(html_data)
    $("#received_borrower_confirm").dialog "open"


  $("#received_borrower_confirm").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    buttons:
      "Yes": ->
        $(this).dialog "close"
        tr_id = $("#received_borrower_confirm").data("trid")
        $.ajax
          url: "/transaction/update_request_status_receive_borrower.json"
          type: "post"
          context: "this"
          dataType: "json"
          data:
            tr_id: tr_id
            called_by: 'borrower'
       
          beforeSend: ->
            $.blockUI
              theme:     true,
              title:    'Please Wait',
              message:  '<p>Your request is being processed</p>'
              draggable: false

          success: (msg) ->
            if msg
              $("#received_borrower_" + tr_id).attr("value","Return")
              $("#received_borrower_" + tr_id).attr("id","return_delivery")
              $("#p_current_" + tr_id).text("Received by You")

            else
              $("#received_borrower_" + tr_id).attr("value","Returned")
              $("#received_borrower_" + tr_id).attr("id","return_self")
              $("#p_current_" + tr_id).text("Received by You. Meetup to Return")

            #$("#current_" + tr_id + " td:nth-last-child(4)").text($.now())
          complete: (jqXHR, textStatus) ->
            setTimeout $.unblockUI

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            $("#error_message").dialog "open"

      Cancel: ->
        $(this).dialog "close"

    open: (event, ui) ->
      $(":button:contains('Ok')").focus()      

#-------------------------------------------------------------------------------------------------------------------- 
  $(document).on "click", "input[id^='handed_over_']", ->
    tr_id = $(this).attr("data-trid")
    tr_id_s = "#accepted_" + tr_id
    $("#handed_over_confirm").data "trid", tr_id
    $("#handed_over_confirm").dialog "open"


  $("#handed_over_confirm").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    buttons:
      "Yes": ->
        $(this).dialog "close"
        tr_id = $("#handed_over_confirm").data "trid"
        $.ajax
          url: "/transaction/update_request_status_receive_borrower.json"
          type: "post"
          context: "this"
          dataType: "json"
          data:
            tr_id: tr_id
            called_by: 'lender'

          beforeSend: ->
            $.blockUI
              theme:     true, 
              title:    'Please Wait', 
              message:  '<p>Your request is being processed</p>'
              draggable: false  
            
          success: (msg) ->

          complete: (jqXHR, textStatus) ->
            $("#p_accepted_" + tr_id).text("Received by Borrower")
            $("#handed_over_" + tr_id).attr("value","Received")
            $("#handed_over_" + tr_id).attr("disabled","true")
            $("#handed_over_" + tr_id).attr("id","received_lender_" + tr_id)
            setTimeout $.unblockUI

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            $("#error_message").dialog "open"

       Cancel: ->
        $(this).dialog "close"

    open: (event, ui) ->
      $(":button:contains('Ok')").focus()

#-------------------------------------------------------------------------------------------------------------------- 
  $(document).on "click", ".borrow_button_offline" ,->
    $("#login").dialog "open"


  $("#login").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    buttons:
      "Ok": ->
        $(this).dialog "close"

#-------------------------------------------------------------------------------------------------------------------- 
  $.ajax
    url: "/profile/update_profile_status.json"
    type: "post"
    context: "this"
    dataType: "json"

    success: (msg) ->

    complete: (jqXHR, textStatus) ->
       
    error: (jqXHR, textStatus, errorThrown) ->
#---------------------------------------------------------------------------------------------------------------------
  # Fn to check of current page has any editing activity, and prompt with a second conformation noty
  noty_confirm = ->
    if (window.location.pathname isnt "/home") and (window.location.pathname isnt "/")
      profile_edit = (/^\/profile\/\d+\/edit$/.test(window.location.pathname))
      address_edit = (/^\/address\/\d+\/edit$/.test(window.location.pathname))
      inventory_edit = (/^\/inventory\/\d+\/edit$/.test(window.location.pathname))
      address_new = (/^\/address\/new$/.test(window.location.pathname))
      inventory_new  = (/^\/inventory\/new$/.test(window.location.pathname))
      if profile_edit or address_edit  or inventory_edit or address_new or inventory_new
        noty
          text: "Unsaved changes will be lost. Proceed?"
          layout: "topRight"
          buttons: [
            addClass: "btn btn-primary"
            text: "Ok"
            onClick: ($noty) ->
              window.location.replace($("#home_link").attr("href"))
          ,
            addClass: "btn btn-danger"
            text: "Cancel"
            onClick: ($noty) ->
              $noty.close()
          ]
      else
        window.location.replace($("#home_link").attr("href"))

