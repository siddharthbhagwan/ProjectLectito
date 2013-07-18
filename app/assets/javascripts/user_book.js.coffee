# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $("#search_books").on "click", ->
    search_city = $("#city").val()
    search_by_author = $("#search_by_author").val()
    search_by_book_name = $("#search_by_book_name").val()
    $("#search_results_table").remove() 
    $("#city_validation").empty()
    $("#author_book_validation").empty()
    fetch_search_data = ->
      $.ajax
        url: "/user_book/search_books.js"
        type: "get"
        dataType: "script"
        data:
          city: search_city
          search_by_author: search_by_author
          search_by_book_name: search_by_book_name

        success: (msg) ->
          $("#search_text").html("<h5>Click on one of the titles to check availability</h5>").hide()
          $("#search_text").fadeIn(500)

        error: ->
          $("#error_message").dialog
            modal: true
            buttons:
              Ok: ->
                $(this).dialog "close"

    if search_city
      if search_by_author.length or search_by_book_name.length
        fetch_search_data()
      else
        $("#author_book_validation").html("<h5>Please Select either a Book Name, or an Author, or Both</h5>").hide()
        $("#author_book_validation").fadeIn(500)
    else
      $("#city_validation").html("<h5>Please Select your city</h5>").hide()
      $("#city_validation").fadeIn(500)


jQuery ->
  $(document).on "click", "#search_results_table tbody tr", (event) ->
    book_id = undefined
    fetch_sub_search_data = undefined
    rental_data = undefined
    row_number = undefined
    rental_data = undefined
    i = 0
    j = 0
    book_id = $(this).attr("id")
    row_number = $(this).closest("tr")[0].rowIndex - 1
    fetch_sub_search_data = ->
      $table = undefined
      city = undefined
      sub_table_id = undefined
      sub_table_id_s = undefined
      city = $("#city").val()
      $table = $("<table>")
      sub_table_id = "sub_search_results_table_" + book_id
      sub_table_id_s = "#" + sub_table_id
      $(sub_table_id_s).remove()
      $.ajax
        url: "/user_book/search_books_city.js?book_id=" + book_id + "&row_number=" + row_number
        type: "get"
        context: "this"
        dataType: "script"
        data:
          book_id: book_id
          city: city

        success: (msg) ->
          
        error: ->
          $("#error_message").dialog
            modal: true
            buttons:
              Ok: ->
                $(this).dialog "close"

    if book_id != (undefined && "sub_search" && "sub_search_results_table_header") && book_id.indexOf("city_") is -1 
      fetch_sub_search_data()

       
jQuery ->
  $(document).on "mouseenter", "#search_results_table tbody tr", ->
    if ($(this).attr("id") != undefined && $(this).attr("id") != 'sub_search_results_table_header')
      if ($(this).attr("id").indexOf("city_") == -1 )
        $(this).css('textDecoration', 'underline')
        $(this).css('font-size', '15px')


jQuery ->
  $(document).on "mouseleave", "#search_results_table tbody tr", ->
    $(this).css('textDecoration', 'none')
    $(this).css('font-size', '14px')



