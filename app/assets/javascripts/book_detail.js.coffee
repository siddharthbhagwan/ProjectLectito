jQuery ->
	$("#bookdetail_table tr").click ->
		row_number = $(this).closest("tr")[0].rowIndex
		book_detail_id = $(this).attr('id')
		if $(this).attr('data-status') == "open"
			$(this).attr('data-status','closed')
			
			$.ajax
		        url: "/book_detail/book_status.js?row_number=" + row_number
		        type: "get"
		        dataType: "script"
		        data:
		          book_detail_id: book_detail_id

		        success: (msg) ->

		        error: ->

		else
			$("#book_count_status_" + book_detail_id).hide()
			$(this).attr('data-status','open')


jQuery ->
  $(document).on "mouseenter", "#bookdetail_table tr", ->
    if ($(this).attr("id") != undefined && $(this).attr("id") != 'sub_search_results_table_header')
      $(this).css('cursor', 'pointer')
      $(this).css('font-size', '14.5px')


jQuery ->
  $(document).on "click", "td[id^='available_']", ->
    id = $(this).attr('id').substring(10).toString()
    $.ajax
      url: "/book_detail/available_book_stats.js"
      type: "get"
      dataType: "script"
      data:
        book_detail_id: id

      success: (msg) ->

	  error: ->


jQuery ->
  $(document).on "click", "td[id^='borrowed_']", ->
    id = $(this).attr('id').substring(9).toString()
    $.ajax
      url: "/book_detail/borrowed_book_stats.js"
      type: "get"
      dataType: "script"
      data:
        book_detail_id: id

      success: (msg) ->

	  error: ->	  	

    		