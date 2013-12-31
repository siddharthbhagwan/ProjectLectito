$(document).ready ->

  asInitVals = new Array()

  # DataTables For Book History
  oTable_book_history = ($("table[id$='_book_history']")).dataTable(
    oLanguage: sSearch: "Search All : "    
  )

  $("tfoot input").keyup ->    
    # Filter on the column (the index) of this element 
    oTable_book_history.fnFilter @value, $("tfoot input").index(this)
    

  # $("tfoot input").each (i) ->
  #   asInitVals[i] = @value


  # $("tfoot input").focus ->
  #   console.log "called"
  #   console.log @classname
  #   if @className is "search_init"
  #     @className = ""
  #     @value = ""

  # $("tfoot input").blur (i) ->
  #   if @value is ""
  #     @className = "search_init"
  #     @value = asInitVals[$("tfoot input").index(this)]
    

  # $("#bookdetail_table tbody tr").click ->
  #   book_id = undefined
  #   row_number = undefined
  #   row_number = $(this).closest("tr")[0].rowIndex - 1
  #   book_id = $(this).attr("id")
  #   if $(this).attr("data-general_stats") is "closed"
  #     $(this).attr "data-general_stats", "open"
  #     $.ajax
  #       url: "/book/book_status.js"
  #       type: "get"
  #       dataType: "script"
  #       data:
  #         book_id: book_id
  #         row_number: row_number

  #       success: (msg) ->

  #       error: (jqXHR, textStatus, errorThrown) ->

  #   else
  #     $("#book_count_status_" + book_id).hide()
  #     $(this).attr "data-general_stats", "closed"

#----------------------------------------------------------------------------------------------------------------------

  # $(document).on "mouseenter", "#bookdetail_table tbody tr", ->
  #   if ($(this).attr("id") != undefined && $(this).attr("id") != 'sub_search_results_table_header')
  #     $(this).css('cursor', 'pointer')

#----------------------------------------------------------------------------------------------------------------------      

  # $(document).on "click", "td[id^='available_']", ->
  #   id = $(this).attr('id').substring(10).toString()
  #   if  $(this).parent("tr").attr("data-specific_stats") is "closed"
  #     $(this).parent("tr").attr("data-specific_stats", "open")
  #     $.ajax
  #       url: "/book/available_book_stats.js"
  #       type: "get"
  #       dataType: "script"
  #       data:
  #         book_id: id

  #       success: (msg) ->

  #   else    
  #     $("#sub_available_list_" + id).hide()
  #     $("#sub_borrowed_list_" + id).hide()
  #     $(this).parent("tr").attr("data-specific_stats", "closed")

#----------------------------------------------------------------------------------------------------------------------

  # $(document).on "click", "td[id^='borrowed_']", ->
  #   id = $(this).attr('id').substring(9).toString()
  #   if  $(this).parent("tr").attr("data-specific_stats") is "closed"
  #     $(this).parent("tr").attr("data-specific_stats", "open")
  #     $.ajax
  #       url: "/book/borrowed_book_stats.js"
  #       type: "get"
  #       dataType: "script"
  #       data:
  #         book_id: id

  #       success: (msg) ->

  #   else    
  #     $("#sub_available_list_" + id).hide()
  #     $("#sub_borrowed_list_" + id).hide()
  #     $(this).parent("tr").attr("data-specific_stats", "closed")
    		