# # Place all the behaviors and hooks related to the matching controller here.
# # All this logic will automatically be available in application.js.
# # You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  # Hide tables if no data
  empty_table_checks = ->
    if $('#borrow_requests_table tr').length == 1
      $('#borrow_requests_div').hide()

    if $('#lend_requests_table tr').length == 1
      $('#lend_requests_div').hide()

    if $('#accepted_requests_table tr').length == 1
      $('#accepted_requests_div').hide()

    if $('#current_books_table tr').length == 1
      $('#current_books_div').hide()

#--------------------------------------------------------------------------------------------------------------------

  $(document).on 'mouseenter', '.fa-user', ->
    $(this).css('cursor', 'pointer')


#--------------------------------------------------------------------------------------------------------------------
  # Modal Dialog for 403 Errors
  $('#error_message_403').dialog
    autoOpen: false
    modal: true
    resizable: false
    draggable: false
    buttons:
      'Ok': ->
        $(this).dialog 'close'

#--------------------------------------------------------------------------------------------------------------------

  # Modal Dialog for Generic Errors
  $('#error_message_generic').dialog
    autoOpen: false
    modal: true
    resizable: false
    draggable: false
    buttons:
      'Ok': ->
        $(this).dialog 'close'

#--------------------------------------------------------------------------------------------------------------------

  # Fn to decide what error to display
  display_error = (statusCode) ->
    if statusCode is 403
      $('#error_message_403').dialog 'open'
    else
      $('#error_message_generic').dialog 'open'

#--------------------------------------------------------------------------------------------------------------------

  # Fn to block UI while processing ajax calls
  before_send = ->
    $.blockUI
      theme:     true, 
      title:    'Please Wait', 
      message:  '<p>Your request is being processed</p>'
      draggable: false

#--------------------------------------------------------------------------------------------------------------------

  empty_table_checks()


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
    resizable: false
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
              before_send()

            success: (msg) ->

            complete: (jqXHR, textStatus) ->
              $("#" + button_id).attr("disabled","true").attr("value","Request Sent...")
              $("#city_" + city_id).hide()
              $("#" + city_id).attr("data-status","closed")
              $("input[id^='timeline_']").popover
                placement: 'right'
                html: true
                trigger: 'hover'
                container: 'body'

              setTimeout $.unblockUI

            error: (jqXHR, textStatus, errorThrown) ->
              setTimeout $.unblockUI
              display_error(jqXHR.status) 

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


  $('#accept_request_confirm').dialog
    autoOpen: false
    modal: true
    resizable: false
    draggable: false
    buttons:
      'Ok': ->
        $(this).dialog 'close'
        tr_id = $('#accept_request_confirm').data('trid')
        tr_id_s = $('#accept_request_confirm').data('trids')
        $.ajax
          url: '/transaction/update_request_status_accept.json'
          type: 'patch'
          context: 'this'
          dataType: 'json'
          data:
            tr_id: tr_id
            dispatch_date: $('#accept_request_confirm').data 'dispatch_date'
            dispatch_time: $('#accept_request_confirm').data 'dispatch_time'

          beforeSend: ->
            before_send()

          success: (msg) ->

          complete: (jqXHR, textStatus) ->
            $(tr_id_s).fadeOut(500).remove()
            empty_table_checks()
            setTimeout $.unblockUI

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            display_error(jqXHR.status)     

      Cancel: ->
        $(this).dialog 'close'

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
    
  $('#accept_self_confirm').dialog
    autoOpen: false
    modal: true
    resizable: false
    draggable: false
    buttons:
      'Ok': ->
        $(this).dialog 'close'
        tr_id = $('#accept_self_confirm').data 'trid'
        tr_id_s = $('#accept_self_confirm').data 'trids'
        $.ajax
          url: '/transaction/update_request_status_accept.json'
          type: 'patch'
          context: 'this'
          dataType: 'json'
          data:
            tr_id: tr_id

          beforeSend: ->
            before_send()

          success: (msg) ->

          complete: (jqXHR, textStatus) ->
            $(tr_id_s).remove()
            empty_table_checks()
            # Destroy popover with same id, which was referring to the old button, which has been removed,
            # recreate the popover
            $('#timeline_' + tr_id).popover('destroy')
            $('#timeline_' + tr_id).popover
              placement: 'right'
              html: true
              trigger: 'hover'
              container: 'body'

            setTimeout $.unblockUI

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            display_error(jqXHR.status)

      Cancel: ->
        $(this).dialog 'close'

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


  $('#reject_request_confirm').dialog
    autoOpen: false
    modal: true
    resizable: false
    draggable: false
    buttons:
      'Ok': ->
        $(this).dialog 'close'
        tr_id = $('#reject_request_confirm').data('trid')
        tr_id_s = $('#reject_request_confirm').data('trids')
        reject_reason = $('input[name=rejectReason]:radio:checked').val()
        $.ajax
          url: '/transaction/update_request_status_reject.json'
          type: 'patch'
          context: 'this'
          dataType: 'json'
          data:
            tr_id: tr_id
            reject_reason: reject_reason

          beforeSend: ->
            before_send()  

          success: (msg) ->

          complete: (jqXHR, textStatus) ->
            $('#timeline_' + tr_id).popover('destroy')
            $(tr_id_s).fadeOut(500).remove()
            empty_table_checks()
            setTimeout $.unblockUI

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            display_error(jqXHR.status)

      Cancel: ->
        $(this).dialog 'close'

    open: (event, ui) ->
      $(":button:contains('Ok')").focus()

#--------------------------------------------------------------------------------------------------------------------
#Update transaction on request being cancelled
  $(document).on 'click', '.cancel_trans', ->
    $('#cancel_transaction').data 'tr_id', $(this).attr 'data-trid'
    $('#cancel_transaction').dialog 'open'      


  $('#cancel_transaction').dialog
    autoOpen: false
    modal: true
    resizable: false
    draggable: false
    buttons:
      'Ok': ->
        $(this).dialog 'close'
        tr_id = $('#cancel_transaction').data('tr_id')
        $.ajax
          url: '/transaction/update_request_status_cancel.json'
          type: 'patch'
          context: 'this'
          dataType: 'json'
          data:
            tr_id: tr_id

          beforeSend: ->
            before_send()

          success: (msg) ->

          complete: (jqXHR, textStatus) ->
            $('#timeline_' + tr_id).popover('destroy')
            $('#borrow_' + tr_id).fadeOut(500).remove()
            empty_table_checks()
            setTimeout $.unblockUI

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            display_error(jqXHR.status)                    

      Cancel: ->
        $(this).dialog 'close'

           
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
    $('#borrower_returned_book_confirm').data 'trid', tr_id
    $('#borrower_returned_book_confirm').data 'trids', tr_id_s
    $('#borrower_returned_book_confirm').data 'mode', 'delivery'
    $('#borrower_returned_book_confirm').dialog 'open'
    $('#return_pickup_date').datepicker
      showOn: "button"
      buttonImageOnly: true
    $('#return_request_confirm').dialog 'open'
    $('#return_request_confirm').data 'return_date', $('#dispatch_date').val()
    $('#return_request_confirm').data 'return_time', $("input[type='radio'][name='return_time']:checked").val()


  $('#return_request_confirm').dialog
    autoOpen: false
    modal: true
    resizable: false
    draggable: false
    buttons:
      'Ok': ->
        $(this).dialog 'close'
        tr_id = $('#return_request_confirm').data('trid')
        tr_id_s = $('#return_request_confirm').data('trids')
        $.ajax
          url: '/transaction/update_request_status_return.json'
          type: 'patch'
          context: 'this'
          dataType: 'json'
          data:
            tr_id: tr_id
            return_date: $('#return_request_confirm').data 'return_date'
            return_time: $('#return_request_confirm').data 'return_time'

          beforeSend: ->
            before_send()

          success: (msg) ->
            
          complete: (jqXHR, textStatus) ->
            setTimeout $.unblockUI

          error:  (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            display_error(jqXHR.status)

      Cancel: ->
        $(this).dialog 'close'
        $('#borrower_returned_book_confirm').dialog 'close'

    beforeClose: (event) ->
      if event.keyCode is $.ui.keyCode.ESCAPE
        $(this).dialog 'close'
        $('#borrower_returned_book_confirm').dialog 'close'    

#--------------------------------------------------------------------------------------------------------------------
# Initiate Return from borrowers side in self delivery mode
  $(document).on 'click', '#return_self', ->  
    tr_id = $(this).attr('data-trid')
    tr_id_s = '#current_' + tr_id
    $('#borrower_returned_book_confirm').data 'trid', tr_id
    $('#borrower_returned_book_confirm').data 'trids', tr_id_s
    $('#borrower_returned_book_confirm').data 'mode', 'self'
    $('#borrower_returned_book_confirm').dialog 'open'


  $('#borrower_returned_book_confirm').dialog
    autoOpen: false
    modal: true
    resizable: false
    draggable: false
    buttons:
      'Ok': ->
        $(this).dialog 'close'
        tr_id = $('#borrower_returned_book_confirm').data('trid')
        tr_id_s = $('#borrower_returned_book_confirm').data('trids')
        $.ajax
          url: '/transaction/update_request_status_return.json'
          type: 'patch'
          context: 'this'
          dataType: 'json'
          data:
            tr_id: tr_id
            borrower_feedback: $("input[type='radio'][name='borrower_feedback']:checked").val()
            borrower_comments: $("#borrower_comments").val()

          beforeSend: ->
            before_send()  

          success: (msg) ->

          complete: (jqXHR, textStatus) ->
            noty
              text: "You have initiated the return of '" + $('#current_' + tr_id + " td:nth-last-child(5)").text() + "' " 
              layout: 'topRight'
              closeWith: ['click']
              callback:
                onClose: ->
                  noty_confirm()

            $('#timeline_' + tr_id).popover('destroy')
            $(tr_id_s).remove()
            $('input:radio[name=borrower_feedback]').val(['neutral']);
            $('#borrower_comments').val('')
            if $('#current_books_table tr').length == 1
              $('#current_books_div').hide()  

            setTimeout $.unblockUI  

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            display_error(jqXHR.status)      

      'Skip': ->
        $(this).dialog 'close'
        tr_id = $('#borrower_returned_book_confirm').data('trid')
        tr_id_s = $('#borrower_returned_book_confirm').data('trids')
        $.ajax
          url: '/transaction/update_request_status_return.json'
          type: 'patch'
          context: 'this'
          dataType: 'json'
          data:
            tr_id: tr_id
            borrower_feedback: '
            borrower_comments: '

          beforeSend: ->
            before_send()

          success: (msg) ->

          complete: (jqXHR, textStatus) ->
            noty
              text: "You have initiated the return of '" + $('#current_' + tr_id + " td:nth-last-child(5)").text() + "'" 
              layout: 'topRight'
              closeWith: ['click']
              callback:
                onClose: ->
                  noty_confirm()
                  
            $(tr_id_s).remove()
            $('input:radio[name=borrower_feedback]').val(['neutral']);
            $('#borrower_comments').val('')
            if $('#current_books_table tr').length == 1
              $('#current_books_div').hide()

            setTimeout $.unblockUI  

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            display_error(jqXHR.status)       
  

      Cancel: ->
        tr_id = $('#borrower_returned_book_confirm').data('trid')
        tr_id_s = $('#borrower_returned_book_confirm').data('trids')
        noty
          text: "You have initiated the return of '" + $('#current_' + tr_id + " td:nth-last-child(5)").text() + "'" 
          layout: 'topRight'  
          closeWith: ['click']
          callback:
            onClose: ->
              noty_confirm()

        $(this).dialog 'close'
        tr_id_s = $('#borrower_returned_book_confirm').data('trids')
        $(tr_id_s).remove()
        if $('#current_books_table tr').length == 1
          $('#current_books_div').hide()


    beforeClose: (event) ->
      if event.keyCode is $.ui.keyCode.ESCAPE
        mode = $('#borrower_returned_book_confirm').data('mode')
        tr_id = $('#borrower_returned_book_confirm').data('trid')
        tr_id_s = $('#borrower_returned_book_confirm').data('trids')
        if mode == 'delivery'
          noty
            text: "You have initiated the return of '" + $('#current_' + tr_id + " td:nth-last-child(5)").text() + "'" 
            layout: 'topRight'
            closeWith: ['click']
            callback:
              onClose: ->
                noty_confirm()

          tr_id_s = $('#borrower_returned_book_confirm').data('trids')
          $(tr_id_s).remove()
          if $('#current_books_table tr').length == 1
            $('#current_books_div').hide()


    open: (event, ui) ->
      $(":button:contains('Ok')").focus()

#--------------------------------------------------------------------------------------------------------------------
# Initiate Compelte transaction from lender side

  $(document).on 'click', "input[id^='received_lender_']", ->
    tr_id = $(this).attr('data-trid')
    tr_id_s = '#accepted_' + tr_id
    $('#lender_received_book_confirm').data 'trid', tr_id
    $('#lender_received_book_confirm').data 'trids', tr_id_s
    # arr = []
    # arr = $(tr_id_s).find('td').map(->
    #   @innerHTML
    # ).get()
    # html_data = "You are about to accept a request to borrow " + arr[0] + " from " + arr[1]
    # $("#accept_info").html(html_data)
    $('#lender_received_book_confirm').dialog 'open'

#TODO write a fn for ajax call
  $('#lender_received_book_confirm').dialog
    autoOpen: false
    modal: true
    resizable: false
    draggable: false
    buttons:
      'Ok': ->
        $(this).dialog 'close'
        tr_id = $('#lender_received_book_confirm').data('trid')
        tr_id_s = $('#lender_received_book_confirm').data('trids')
        $.ajax
          url: '/transaction/update_request_status_receive_lender.json'
          type: 'patch'
          context: 'this'
          dataType: 'json'
          data:
            tr_id: tr_id
            lender_feedback: $("input[type='radio'][name='lender_feedback']:checked").val()
            lender_comments: $('#lender_comments').val()

          beforeSend: ->
            before_send()

          success: (msg) ->

          complete: (jqXHR, textStatus) ->
            $('#timeline_' + tr_id).popover('destroy')
            $(tr_id_s).remove()
            $('#lender_comments').val('')
            $('input:radio[name=lender_feedback]').val(['neutral'])
            if $('#accepted_requests_table tr').length == 1
              $('#accepted_requests_div').hide()

            setTimeout $.unblockUI  

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            display_error(jqXHR.status)

      'Skip': ->
        $(this).dialog 'close'
        tr_id = $('#lender_received_book_confirm').data('trid')
        tr_id_s = $('#lender_received_book_confirm').data('trids')
        $.ajax
          url: '/transaction/update_request_status_receive_lender.json'
          type: 'patch'
          context: 'this'
          dataType: 'json'
          data:
            tr_id: tr_id
            lender_feedback: ''
            lender_comments: ''
            
          beforeSend: ->
            before_send()

          success: (msg) ->

          complete: (jqXHR, textStatus) ->
            $(tr_id_s).remove()
            if $('#accepted_requests_table tr').length == 1
              $('#accepted_requests_div').hide()

            setTimeout $.unblockUI  

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            display_error(jqXHR.status)
            
      Cancel: ->
        $(this).dialog 'close'

    open: (event, ui) ->
      $(":button:contains('Ok')").focus()      

#-------------------------------------------------------------------------------------------------------------------- 
  $(document).on 'click', "input[id^='received_borrower_']", ->
    tr_id = $(this).attr('data-trid')
    tr_id_s = '#received_borrower_' + tr_id
    $('#received_borrower_confirm').data 'trid', tr_id
    $('#received_borrower_confirm').data 'trids', tr_id_s
    # arr = []
    # arr = $(tr_id_s).find('td').map(->
    #   @innerHTML
    # ).get()
    # html_data = "You are about to accept a request to borrow " + arr[0] + " from " + arr[1]
    # $("#accept_info").html(html_data)
    $('#received_borrower_confirm').dialog 'open'


  $('#received_borrower_confirm').dialog
    autoOpen: false
    modal: true
    resizable: false
    draggable: false
    buttons:
      'Yes': ->
        $(this).dialog 'close'
        tr_id = $('#received_borrower_confirm').data('trid')
        $.ajax
          url: '/transaction/update_request_status_receive_borrower.json'
          type: 'patch'
          context: 'this'
          dataType: 'json'
          data:
            tr_id: tr_id
            called_by: 'borrower'
       
          beforeSend: ->
            before_send()

          success: (msg) ->
            if msg
              $('#received_borrower_' + tr_id).attr('value','Return')
              $('#received_borrower_' + tr_id).attr('id','return_delivery')
              $('#p_current_' + tr_id).text('Received by You')

            else
              $('#received_borrower_' + tr_id).attr('value',"I've Returned the Book")
              $('#received_borrower_' + tr_id).attr('id','return_self')
              $('#p_current_' + tr_id).text("You've got the book. Meetup to Return")

          complete: (jqXHR, textStatus) ->

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            display_error(jqXHR.status)
            
      Cancel: ->
        $(this).dialog 'close'

    open: (event, ui) ->
      $(":button:contains('Ok')").focus()      

#-------------------------------------------------------------------------------------------------------------------- 
  $(document).on 'click', "input[id^='handed_over_']", ->
    tr_id = $(this).attr("data-trid")
    tr_id_s = '#accepted_' + tr_id
    $('#handed_over_confirm').data 'trid', tr_id
    $('#handed_over_confirm').dialog 'open'


  $('#handed_over_confirm').dialog
    autoOpen: false
    modal: true
    resizable: false
    draggable: false
    buttons:
      'Yes': ->
        $(this).dialog 'close'
        tr_id = $('#handed_over_confirm').data 'trid'
        $.ajax
          url: '/transaction/update_request_status_receive_borrower.json'
          type: 'patch'
          context: 'this'
          dataType: 'json'
          data:
            tr_id: tr_id
            called_by: 'lender'

          beforeSend: ->
            before_send()  
            
          success: (msg) ->

          complete: (jqXHR, textStatus) ->
            $('#p_accepted_' + tr_id).text("Borrower has it. Meetup once he's done reading")
            $('#handed_over_' + tr_id).attr('value',"I've Received the Book")
            $('#handed_over_' + tr_id).attr('disabled','true')
            $('#handed_over_' + tr_id).attr('id','received_lender_' + tr_id)
            setTimeout $.unblockUI

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            display_error(jqXHR.status)

       Cancel: ->
        $(this).dialog 'close'

    open: (event, ui) ->
      $(":button:contains('Ok')").focus()

#-------------------------------------------------------------------------------------------------------------------- 
  $(document).on 'click', '.borrow_button_offline' ,->
    $('#sign_in_or_sign_up').dialog 'open'


  $('#sign_in_or_sign_up').dialog
    autoOpen: false
    modal: true
    resizable: false

#---------------------------------------------------------------------------------------------------------------------

  # Fn to check of current page has any editing activity, and prompt with a second conformation noty
  noty_confirm = ->
    if (window.location.pathname isnt '/home') and (window.location.pathname isnt '/') and (window.location.pathname isnt '/inventory/search')
      profile_edit = (/^\/profile\/\d+\/edit$/.test(window.location.pathname))
      address_edit = (/^\/address\/\d+\/edit$/.test(window.location.pathname))
      inventory_edit = (/^\/inventory\/\d+\/edit$/.test(window.location.pathname))
      address_new = (/^\/address\/new$/.test(window.location.pathname))
      inventory_new  = (/^\/inventory\/new$/.test(window.location.pathname))
      if profile_edit or address_edit  or inventory_edit or address_new or inventory_new
        noty
          text: 'Unsaved changes will be lost. Proceed?'
          layout: 'topRight'
          buttons: [
            addClass: 'btn btn-primary'
            text: 'Ok'
            onClick: ($noty) ->
              window.location.replace($('#home_link').attr('href'))
          ,
            addClass: 'btn btn-danger'
            text: 'Cancel'
            onClick: ($noty) ->
              $noty.close()
          ]
      else
        window.location.replace($('#home_link').attr('href'))

#--------------------------------------------------------------------------------------------------------------------
  # SSE Listener for creating a transaction
  #TODO Remove bracket element so its no more an element
  $.ajax
    url: '/transaction/user_id.json'
    type: 'get'
    context: 'this'
    dataType: 'json'
    data:
      fbhandle: true

    success: (msg) ->
      id = msg.user_id
      myFirebase = new Firebase(msg.fburl.replace(/\"/g, "") + 'transaction_listener_' + id)
      # myChild = myFirebase.child('transaction_listener_' + id)
      myFirebase.on 'child_added', (childSnapshot, prevChildName) ->
        pData = $.parseJSON(childSnapshot.val())
        # Summary of Requests for Books users want to borrow from you (lender)
        if pData[0] == 'create'
          if !$('#lend_' + pData[1].id).length and !$('#accepted_' + pData[1].id).length
            noty
              text: pData[1].name + " would like to borrow '" + pData[1].book_name + "' from you"
              layout: 'topRight'
              closeWith: ['click']
              callback:
                onClose: ->
                  noty_confirm()

            tr_id = "<tr id='lend_" + pData[1].id + "'>"
            td_book_name = '<td>' + pData[1].book_name + '</td>'
            td_fa_user = "<td>&nbsp;<i class='fa fa-user' id='public_rating_" + pData[1].id + "'>&nbsp;</i>"
            td_borrower = " " + pData[1].borrower + "</td>"
            td_accept = "<td class='manage'><input class='btn btn-default' type='button' value='Accept' id='accept_self' data-trid=" + pData[1].id + "></td>"

            # if pData[1].delivery_mode
            #   td_delivery_mode = "<td>Delivery</td>"
            #   td_accept = "<td><input class='btn btn-default' type='button' value='Accept' id='accept_delivery' data-trid=" + pData[1].id + "></td>"
            # else
            #   td_delivery_mode = "<td>Self Pick/Drop</td>"
            #   td_accept = "<td><input class='btn btn-default' type='button' value='Accept' id='accept_self' data-trid=" + pData[1].id + "></td>"

            td_requested_from = '<td>' + pData[1].requested_from + '</td>'
            td_status = '<td>' + pData[1].status + '</td>'
            td_reject = "<td class='manage'><input class='btn btn-default' type='button' value='Reject' id='reject' data-trid=" + pData[1].id + "></td>"
            td_timeline_button = "<td class='manage'><input class='btn btn-default' type='button' value='View' id='timeline_" + pData[1].id + "' data-title='Timeline' rel='popover' 
              data-content='<div style=font-size:90%;><u>Requested</u><br/>" + pData[1].requested_date + "<br/></div>'></td></tr>"
            table_row_data = tr_id + td_book_name + td_fa_user + td_borrower + td_requested_from + td_status + td_accept + td_reject + td_timeline_button
            $("#lend_requests_table > tbody:last").append(table_row_data);

            $("#timeline_" + pData[1].id).popover
              placement: 'right'
              html: true
              trigger: 'hover'
              container: 'body'

            if (!$('#lend_requests_div').is(':visible'))
              $('#lend_requests_div').show(500)

        # Summary of Requests for Books you've lent out (lender)
        # Changes on lenders page after lender accepts the request
        else if pData[0] == 'accepted_lender'
          if !$('#accepted_' + pData[1].id).length
            tr_id = "<tr id='accepted_" + pData[1].id + "'>"
            td_book_name = '<td>' + pData[1].book_name + '</td>'
            
            if pData[1].online == 'Online'
              td_b_base = "<img width='10' height='10' class='img-cirlce' src='/assets/online_dot.png' data-trid='" + pData[1].id + "' id='online_" + pData[1].id + "' "  
            else
              td_b_base = "<img width='10' height='10' class='img-circle' hidden='true' src='/assets/online_dot.png' data-trid='" + pData[1].id + "' id='online_" + pData[1].id + "' "  

            td_b_ccn = "data-currentcn='" + pData[1].currentcn + "' "
            td_b_bcn = "data-borrowercn='" + pData[1].borrowercn + "' "
            td_b_lcn = "data-lendercn='" + pData[1].lendercn + "' "  
            td_b_title = "data-title='" + pData[1].title + "' "
            online_dot = td_b_base + td_b_ccn + td_b_bcn + td_b_lcn + td_b_title + "/>"
            td_fa_user = "<td>&nbsp;<i class='fa fa-user' id='public_rating_" + pData[1].id + "'>&nbsp;</i>"
            name_chat_link = " <a href='javascript:void(0)' id='name_chat_" + pData[1].id + "'>" + pData[1].borrower + "</a>"
            td_borrower = name_chat_link + "&nbsp;&nbsp;" + online_dot

            # if pData[1].delivery_mode
            #   td_delivery_mode = "<td>Delivery</td>"
            #   td_status = "<td><span id='p_accepted_" + pData[1].id + "'> Sent to Borrower</span><input class='btn btn-default' type='button' disabled='true' value='Received' id='received_lender_" + pData[1].id + "' data-trid=" + pData[1].id + "></td></tr>"
            # else
            #   td_delivery_mode = "<td>Self Pick/Drop</td>"
            #   td_status = "<td><span id='p_accepted_" + pData[1].id + "'> Meetup as decided</span><input class='btn btn-default' type='button' value='Handed Over' id='handed_over_" + pData[1].id + "' data-trid=" + pData[1].id + "></td></tr>"

            td_status_text = "<td class='text-center'><span id='p_accepted_" + pData[1].id + "'>Meetup as decided</span></td>"
            td_status_button = "<td class='manage'><input class='btn btn-default' type='button' value='I&apos;ve Handed Over the book' id='handed_over_" + pData[1].id + "' data-trid=" + pData[1].id + "></td>"
            td_acceptance_date = "<td>" + pData[1].acceptance_date + "</td>"
            td_timeline_button = "<td class='manage'><input class='btn btn-default' type='button' value='View' id='timeline_" + pData[1].id + "' data-title='Timeline' rel='popover' 
              data-content='<div style=font-size:90%;><u>Requested</u><br/>" + pData[1].requested_date + "<br/><u>Accepted</u><br/>" + pData[1].acceptance_date + "<br/></div>'></td></tr>"
            table_row_data = tr_id + td_book_name + td_fa_user + td_borrower + td_status_text + td_status_button + td_timeline_button
            $('#accepted_requests_table > tbody:last').append(table_row_data)

            if (!$('#accepted_requests_div').is(':visible'))
              $('#accepted_requests_div').show(500)

            $('#chat_divs').append("<div id='chat_div_" + pData[1].id + "''></div>")

        
        # Summary of Books currently with you (borrower)
        # Changes on the borrowers page after lender accepts the request
        else if pData[0] == 'accepted_borrower'
          if !$('#current_' + pData[1].id).length
            noty
              text: pData[1].lender + " has agreed to lend you '" + pData[1].book_name + "'"
              layout: "topRight"
              closeWith: ["click"]
              callback:
                onClose: ->
                  noty_confirm()

            $('#timeline_' + pData[1].id).popover('destroy')
            $('#borrow_' + pData[1].id).remove()
            empty_table_checks()
            tr_id = "<tr id='current_" + pData[1].id + "'>"
            td_book_name = '<td>' + pData[1].book_name + '</td>'

            if pData[1].online == 'Online'
              td_c_base = "<img width='10' height='10' class='img-circle' src='/assets/online_dot.png' data-trid='" + pData[1].id + "' id='online_" + pData[1].id + "' "  
            else
              td_c_base = "<img width='10' height='10' class='img-circle' hidden='true' src='/assets/online_dot.png' data-trid='" + pData[1].id + "' id='online_" + pData[1].id + "' "

            td_c_ccn = "data-currentcn='" + pData[1].currentcn + "' "
            td_c_bcn = "data-borrowercn='" + pData[1].borrowercn + "' "
            td_c_lcn = "data-lendercn='" + pData[1].lendercn + "' "
            td_c_title = "data-title='" + pData[1].title + "' "
            online_dot = td_c_base + td_c_ccn + td_c_bcn + td_c_lcn + td_c_title + "/>"
            td_fa_user = "<td>&nbsp;<i class='fa fa-user' id='public_rating_" + pData[1].id + "'>&nbsp;</i>"
            lender_link = " <a href='javascript:void(0)' id='name_chat_" + pData[1].id + "'>" + pData[1].lender + "</a>"
            td_lender = lender_link + "&nbsp;&nbsp;" + online_dot

            # if pData[1].delivery_mode
            #   td_delivery_mode = "<td>Delivery</td>"
            #   td_status = "<td><span id='p_current_" + pData[1].id + "'> Sent by Lender</span><input class='btn btn-default' type='button' value='Received' id='received_borrower_" + pData[1].id + "' data-trid='" +  pData[1].id + "'/></td></tr>"
            # else
            #   td_delivery_mode = "<td>Self Pick/Drop</td>"
            #   td_status = "<td><span id='p_current_" + pData[1].id + "'> Meetup as decided</span><input class='btn btn-default' type='button' value='Received' id='received_borrower_" + pData[1].id + "' data-trid='" +  pData[1].id + "'/></td></tr>"

            td_status_text = "<td class='text-center'><span id='p_current_" + pData[1].id + "'>Meetup as decided</span></td>"
            td_status_button = "<td class='manage'><input class='btn btn-default' type='button' value='I&apos;ve Received the book' id='received_borrower_" + pData[1].id + "' data-trid='" +  pData[1].id + "'/></td>"
            td_acceptance_date = "<td>" + pData[1].acceptance_date + "</td>"
            td_timeline_button = "<td class='manage'><input class='btn btn-default' type='button' value='View' id='timeline_" + pData[1].id + "' data-title='Timeline' rel='popover' 
              data-content='<div style=font-size:90%;><u>Requested</u><br/>" + pData[1].requested_date + "<br/><u>Accepted</u><br/>" + pData[1].acceptance_date + "<br/></div>'></td></tr>"
            table_row_data = tr_id + td_book_name + td_fa_user + td_lender + td_status_text + td_status_button + td_timeline_button      
            $("#current_books_table > tbody:last").append(table_row_data)

            $('#timeline_' + pData[1].id).popover('destroy')
            $('#timeline_' + pData[1].id).popover
              placement: 'right'
              html: true
              trigger: 'hover'
              container: 'body'

            if (!$('#current_books_div').is(':visible'))
              $('#current_books_div').show(500)

            $('#chat_divs').append("<div id='chat_div_" + pData[1].id + "''></div>")

        # Summary of Requests for Books you've lent out ( recvd button activates )
        else if pData[0] == 'returned' #FIXME
          if $('#received_lender_' + pData[1].id).attr('disabled') == 'disabled'
            noty
                text: pData[1].name + " has initiated the return of '" + pData[1].book_name + "'"
                layout: 'topRight'
                closeWith: ['click']
                callback:
                  onClose: ->
                    noty_confirm()

            timeline_data_content = $('#timeline_' + pData[1].id).attr('data-content')
            timeline_data_content = timeline_data_content.substring(0, timeline_data_content.length - 6)
            timeline_data_content = timeline_data_content + '<u>Returned</u><br/>' + pData[1].returned_date + '</div>'
            timeline_data_content = $('#timeline_' + pData[1].id).attr('data-content', timeline_data_content)
            $('#received_lender_' + pData[1].id).removeAttr('disabled')
            $('#p_accepted_' + pData[1].id).text('Returned by Borrower ').fadeIn(300)

        else if pData[0] == 'rejected_lender'
          $('#timeline_' + pData[1].id).popover('destroy')
          $('#lend_' + pData[1].id).remove()
          empty_table_checks()

        else if pData[0] == 'rejected_borrower'
          $('#timeline_' + pData[1].id).popover('destroy')
          $('#borrow_' + pData[1].id).remove()
          empty_table_checks()

          noty
            text: "Your request to borrow '" + pData[1].book_name + "' has been rejected as the book has been lent out"
            layout: 'topRight'
            closeWith: ['click']
            callback:
              onClose: ->
                noty_confirm()

        # Request has been cancelled by borrower. On lenders page, the entry is removed, empty table check is called,
        # and popover is destroyed
        else if pData[0] == 'cancelled'
          noty
            text: "A request to borrow '" + pData[1].book_name + "' from you has been cancelled"
            layout: 'topRight'
            closeWith: ['click']
            callback:
              onClose: ->
                noty_confirm()

          $('#timeline_' + pData[1].id).popover('destroy')
          $('#lend_' + pData[1].id).remove()          
          empty_table_checks()

        else if pData[0] == 'rejected'
          if pData[1].reason == 'Unavailable'
            noty
              text: "Your request to borrow '" + pData[1].book_name + "' has been rejected as " + pData[1].name + " is Unavailable"
              layout: 'topRight'
              closeWith: ['click']
              callback:
                onClose: ->
                  noty_confirm()

          else
            noty
              text: "Your request to borrow '" + pData[1].book_name + "' has been rejected"
              layout: 'topRight'
              closeWith: ['click']
              callback:
                onClose: ->
                  noty_confirm()

          $('#timeline_' + pData[1].id).popover('destroy')
          $('#borrow_' + pData[1].id).remove()
          empty_table_checks()

        else if pData[0] == 'received_lender'
          noty
            text: pData[1].name + " has received '" + pData[1].book_name + "'"
            layout: 'topRight'
            closeWith: ['click']
            callback:
              onClose: ->
                noty_confirm()

          $('chat_div_' + pData[1].id).remove()

        # Lender triggers that book's been handed over in self/pick drop.
        # Notifiation for borrower
        else if pData[0] == 'received_borrower_by_lender'
          timeline_data_content = $('#timeline_' + pData[1].id).attr('data-content')
          timeline_data_content = timeline_data_content.substring(0, timeline_data_content.length - 6)
          timeline_data_content = timeline_data_content + '<u>Received</u><br/>' + pData[1].received_date + '<br/></div>'
          timeline_data_content = $('#timeline_' + pData[1].id).attr('data-content', timeline_data_content)

          noty
            text: pData[1].name + " has handed over '" + pData[1].book_name + "'"
            layout: 'topRight'
            closeWith: ['click']
            callback:
              onClose: ->
                noty_confirm()

            if pData[1].delivery_mode
              $('#received_borrower_' + pData[1].id).attr('value', 'Return')
              $('#received_borrower_' + pData[1].id).attr('id', 'return_delivery')

            else
              $('#p_current_' + pData[1].id).text("You've got the book. Meetup to Return")
              $('#received_borrower_' + pData[1].id).attr('value', "I've Returned the book")
              $('#received_borrower_' + pData[1].id).attr('id', 'return_self')


        # Borrower triggers that the books been received. If its by self Pic and drop, coln change on lender's side
        # Called when borrower clicks on received, push notification for lender
        else if pData[0] == 'received_borrower_by_borrower'
          timeline_data_content = $('#timeline_' + pData[1].id).attr('data-content')
          timeline_data_content = timeline_data_content.substring(0, timeline_data_content.length - 6)
          timeline_data_content = timeline_data_content + '<u>Received</u><br/>' + pData[1].received_date + '</div>'
          timeline_data_content = $('#timeline_' + pData[1].id).attr('data-content', timeline_data_content)
          $('#p_accepted_' + pData[1].id).text("Borrower has it. Meetup once he's done reading")
          noty
            text: pData[1].name + " has successfully received '" + pData[1].book_name + "'"
            layout: 'topRight'
            closeWith: ['click']
            callback:
              onClose: ->
                noty_confirm()

          if !pData[1].delivery_mode
            $('#handed_over_' + pData[1].id).attr('value', "I've Received the Book")
            $('#handed_over_' + pData[1].id).attr('disabled', 'true')
            $('#handed_over_' + pData[1].id).attr('id', 'received_lender_' + pData[1].id)

        # Called when borrower clicks received, push notification for borrower himself
        else if pData[0] == 'received_borrower_by_borrower_lender'
          timeline_data_content = $('#timeline_' + pData[1].id).attr('data-content')
          timeline_data_content = timeline_data_content.substring(0, timeline_data_content.length - 6)
          timeline_data_content = timeline_data_content + '<u>Received</u><br/>' + pData[1].received_date + '<br/></div>'
          timeline_data_content = $('#timeline_' + pData[1].id).attr('data-content', timeline_data_content)
          # Block set in ajax is removed here because after controller updates, theres a push back to the caller itself
          setTimeout $.unblockUI

        # Lender clicks 'Handed Over', Controller updates data, action to be carried out on lenders page itself
        else if pData[0] == 'received_borrower_by_lender_borrower'
          timeline_data_content = $('#timeline_' + pData[1].id).attr('data-content')
          timeline_data_content = timeline_data_content.substring(0, timeline_data_content.length - 6)
          timeline_data_content = timeline_data_content + '<u>Received</u><br/>' + pData[1].received_date + '<br/></div>'
          timeline_data_content = $('#timeline_' + pData[1].id).attr('data-content', timeline_data_content)
          

        myFirebase.child(childSnapshot.bc.path.m[1]).remove()
        # Refer line 316 in chat.js for comments 

    complete: (jqXHR, textStatus) ->

    error: (jqXHR, textStatus, errorThrown) ->
      # setTimeout $.unblockUI
      # $('#error_message').dialog 'open' 

