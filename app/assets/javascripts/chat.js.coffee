# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $("#chat_send").click ->
    chat_text = $("#chat_text").val()
    $("#chat_text").val("")
    $.ajax
      url: "/transaction/new_chat"
      type: "post"
      context: "this"
      dataType: "json"
      data:
        chat: chat_text
        ref: window.location.pathname

      success: (msg) ->
      
      error: (jqXHR, textStatus, errorThrown) ->


jQuery ->
  $("#chat_text").keydown (e) ->
    if e.keyCode is 13
      chat_text = $("#chat_text").val()
      $("#chat_text").val("")
      $.ajax
        url: "/transaction/new_chat"
        type: "post"
        context: "this"
        dataType: "json"
        data:
          chat: chat_text
          ref: window.location.pathname

        success: (msg) ->
        
        error: (jqXHR, textStatus, errorThrown) ->

