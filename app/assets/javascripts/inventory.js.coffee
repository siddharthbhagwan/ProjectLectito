$(document).ready ->

# Search by book/author
  $("#search_books").on "click", ->
    search_city = $("#city").val()
    search_by_author = $("#search_by_author").val()
    search_by_book_name = $("#search_by_book_name").val()
    $("#search_results_table").remove() 
    $("#city_validation").empty()
    $("#author_book_validation").empty()
    $("#search_text").hide()
    fetch_search_data = ->
      $.ajax
        url: "/inventory/search_books.js"
        type: "get"
        dataType: "script"
        data:
          city: search_city
          search_by_author: search_by_author
          search_by_book_name: search_by_book_name

        success: (msg) ->
          $("#search_text").html("<h5>Click on one of the titles to check availability</h5>").hide()
          $("#search_text").fadeIn(500)
        error: (jqXHR, textStatus, errorThrown) ->
          $("#error_message").dialog "open"
          

    if search_city
      if search_by_author.length or search_by_book_name.length
        fetch_search_data()
      else
        $("#author_book_validation").html("<h5>Please Enter either a Book Name, or an Author, or Both</h5>").hide()
        $("#author_book_validation").fadeIn(500)
        $("#author_empty").hide()
        $("#book_name_empty").hide()
    else
      $("#city_validation").html("<h5>Please Select your city</h5>").hide()
      $("#city_validation").fadeIn(500)


#--------------------------------------------------------------------------------------------------------------------
# Search for book within the city
  $(document).on "click", "#search_results_table tbody tr", (event) ->
    book_id = undefined
    fetch_sub_search_data = undefined
    row_number = undefined
    city = undefined
    sub_table_id = undefined
    sub_table_id_s = undefined
    book_id = $(this).attr("id")
    row_number = $(this).closest("tr")[0].rowIndex - 1
    fetch_sub_search_data = ->
      city = $("#city").val()
      sub_table_id = "sub_search_results_table_" + book_id
      sub_table_id_s = "#" + sub_table_id
      $(sub_table_id_s).remove()
      $.ajax
        url: "/inventory/search_books_city.js"
        type: "get"
        context: "this"
        dataType: "script"
        data:
          book_id: book_id
          city: city
          row_number: row_number

        success: (msg) ->
         
        error: (jqXHR, textStatus, errorThrown) ->
          $("#error_message").dialog "open"


    #TODO Check Why && not working
    if $(this).attr("data-status") == "closed"
      if book_id != undefined
        if book_id != "sub_search"
          if book_id != "sub_search_results_table_header"
            if book_id.indexOf("city_") is -1
              $(this).attr("data-status", "open")
              fetch_sub_search_data()
    else
      $(this).attr("data-status", "closed")
      $("#city_" + book_id).hide()      


#--------------------------------------------------------------------------------------------------------------------
# Autocomplete for Author

  $("#search_by_author").autocomplete(
    source: (request, response) ->
      $.ajax
        url: "/inventory/autocomplete_author"
        dataType: "json"
        data:
          author: $("#search_by_author").val()
          
        success: (data) ->
          response(data)

    response: (e, ui) ->
      if ui.content.length is 0
        $("#author_empty").fadeIn(300)
      else
        $("#author_empty").hide()

    select: (e, ui) ->
      $("#search_by_author").data("selected_item", ui.item.label)

  ).blur ->
    value_typed = $("#search_by_author").val()
    value_selected = $("#search_by_author").data("selected_item")
    if value_typed != value_selected
      $("#search_by_author").val("")

    if value_selected == "No Matching Results Found"
      $("#search_by_author").val("")       


#--------------------------------------------------------------------------------------------------------------------
# Autocomplete for Book Name

  $("#search_by_book_name").autocomplete( 
    source: (request, response) ->
      $.ajax
        url: "/inventory/autocomplete_book_name"
        dataType: "json"
        data:
          author: $("#search_by_author").val()
          book_name: $("#search_by_book_name").val()
          
        success: (data) ->
          response(data)

    response: (e, ui) ->
      if ui.content.length is 0
        $("#book_name_empty").fadeIn(300)
      else
        $("#book_name_empty").hide()

    select: (e, ui) ->
      $("#search_by_book_name").data("selected_item", ui.item.label)

  ).blur ->
    value_typed = $("#search_by_book_name").val()
    value_selected = $("#search_by_book_name").data("selected_item")
    if value_typed != value_selected
      $("#search_by_book_name").val("")

    if value_selected == "No Matching Results Found"
      $("#search_by_book_name").val("")  


#--------------------------------------------------------------------------------------------------------------------
# Autocomplete for Adding Inventory
  $("#book_name").autocomplete( 
    source: (request, response) ->
      $.ajax
        url: "/autocomplete_book_details"
        dataType: "json"
        data:
          book_name: $("#book_name").val()
          
        success: (data) ->
          response $.map(data, (item) ->
            label: item.book_name
            id: item.id
            mrp: item.mrp
            isbn: item.isbn
            author: item.author
            language: item.language
            genre: item.genre
            version: item.version
            pages: item.pages
            publisher: item.publisher
            edition: item.edition
            ) 

    response: (e, ui) ->
      if ui.content.length is 0
        $("#mrp").hide()
        $("#isbn").hide()
        $("#author").hide()
        $("#language").hide()
        $("#genre").hide()
        $("#version").hide()
        $("#pages").hide()
        $("#publisher").hide()
        $("#edition").hide()
        $("#book_name_empty").hide()
        $("#book_name_empty").fadeIn(600)
        $("#add_book").attr('disabled', true)
      else 
        $("#book_name_empty").hide()

    select: (e, ui) ->
      $("#mrp").val(ui.item.mrp).fadeIn(500)
      $("#isbn").val(ui.item.isbn).fadeIn(500)
      $("#author").val(ui.item.author).fadeIn(500)
      $("#language").val(ui.item.language).fadeIn(500)
      $("#genre").val(ui.item.genre).fadeIn(500)
      $("#version").val(ui.item.version).fadeIn(500)
      $("#pages").val(ui.item.pages).fadeIn(500)
      $("#publisher").val(ui.item.publisher).fadeIn(500)
      $("#edition").val(ui.item.edition).fadeIn(500)
      $("#book_id").val(ui.item.id)
      $("#book_name").data("selected_item",ui.item.label)
      $("#add_book").attr('disabled', false)

  ).blur ->
    $("#book_name").trigger("autocompleteselect")   


#--------------------------------------------------------------------------------------------------------------------
# Highlight rows and make pointer clickable

  $(document).on "mouseenter", "#search_results_table tbody tr", ->
    if ($(this).attr("id") != undefined && $(this).attr("id") != 'sub_search_results_table_header')
      if ($(this).attr("id").indexOf("city_") == -1 )
        $(this).css('cursor', 'pointer');
        $(this).css('font-size', '14.5px')


  $(document).on "mouseleave", "#search_results_table tbody tr", ->
    $(this).css('textDecoration', 'none')
    $(this).css('font-size', '14px')

#--------------------------------------------------------------------------------------------------------------------
# Hide Book Details by default till book name is selected

  $("#isbn").hide() 
  $("#author").hide()  
  $("#language").hide() 
  $("#genre").hide() 
  $("#version").hide()
  $("#edition").hide() 
  $("#publisher").hide()
  $("#pages").hide() 
  $("#mrp").hide() 

#--------------------------------------------------------------------------------------------------------------------

  $(".edit_inventory").show() 

#--------------------------------------------------------------------------------------------------------------------
  $("#add_book").click ->
    if ("#book_name").length isnt 0
      if !$("#book_name_empty").is(":visible")
        $("#add_book_form").submit()

#--------------------------------------------------------------------------------------------------------------------
  # Online Status Updater    

  updateComments = ->
    $.ajax
      url: "/profile/online.json"
      type: "post"
      dataType: "script"
      data:
        page: window.location.pathname

      success: (msg) ->
        if (window.location.pathname is "/home" ) || (window.location.pathname is "/" ) || (window.location.pathname is "/inventory/search" ) 
          id_elements_on_page = $('[id^="online_"]')
          # Get id of each object and strip it of the 'online_' text, leaving just the transaction id
          $.each id_elements_on_page, (index, value) ->
            online_id = id_elements_on_page[index].id.substring(id_elements_on_page[index].id.indexOf("_") + 1)
            if msg.indexOf(online_id) is -1
              $("#" + id_elements_on_page[index].id).hide()
            else
              $("#" + id_elements_on_page[index].id).show()

        else if window.location.pathname.indexOf("/transaction/history") isnt -1
          id_elements_on_page = $('[id^="online_"]')
          ids_list = new Array
          # Get id of each object, and strip it of the 'online_' text, leaving just the user id (lender or borrower)
          $.each id_elements_on_page, (index, value) ->
            id_without_text = id_elements_on_page[index].id.substring(id_elements_on_page[index].id.indexOf("_") + 1)
            if ids_list.indexOf(id_without_text) is -1
              ids_list.push(id_without_text)

          $.each ids_list, (index, value) ->
            # action is carried upon class as if multiple obj with same id have an operation 
            # performed on it, only the first one would work, remaining elements stay untouched
            # in history.html, class and id have been given the same value 
            if msg.indexOf(ids_list[index]) is -1
              $(".online_" + ids_list[index]).hide()
            else
              $(".online_" + ids_list[index]).show()

      error: (jqXHR, textStatus, errorThrown) ->

    setTimeout updateComments, 5000

  setTimeout updateComments, 5000  

#--------------------------------------------------------------------------------------------------------------------
# Highlight rows and make pointer clickable

  $(document).on "mouseenter", "img[id^='online_']", ->
    $(this).css('cursor', 'pointer');

#--------------------------------------------------------------------------------------------------------------------
