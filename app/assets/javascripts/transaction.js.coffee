# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
    $ ->
        if $("#borrow_requests_table tr").length == 1
            $("#borrow_requests_div").hide()

        if $("#lend_requests_table tr").length == 1
            $("#lend_requests_div").hide()          


jQuery ->
  $(document).on "click", ".borrow_button" ,->
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

        success: (msg) -> 
        	$(button_id_s).attr("disabled", true) 
        	$(button_id_s).attr("value","Request Sent...")
      

jQuery ->
    updateBorrowRequests = ->
        if $("#borrow_requests_table").length > 0
          after = $("#borrow_requests_table tbody tr:last-child").attr("data-time")
        else
          after = "0"
        $.getScript("/transaction/get_latest_borrowed.js?after=" + after)
        #setTimeout updateBorrowRequests, 10000
    $ ->
        #setTimeout updateBorrowRequests, 10000  if $("#borrow_requests_table").length > 0


jQuery ->
    updateLendRequests = ->
        if $("#lend_requests_table").length > 0
          after = $("#lend_requests_table tbody tr:last-child").attr("data-time")
        else
          after = "0"  
        $.getScript("/transaction/get_latest_lent.js?after=" + after)
        setTimeout updateLendRequests, 5000
    $ ->
        setTimeout updateLendRequests, 5000  if $("#lend_requests_table").length > 0        
