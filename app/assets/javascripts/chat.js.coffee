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


$(document).ready ->
  box = null
  $("input[id^='chat_']").click (event, ui) ->
    trid =  $(this).attr("data-trid")
    if $(this).attr("data-title").length > 20
      title = $(this).attr("data-title").substring(0,20) + "..."
    else
      title = $(this).attr("data-title")

    if box
      box.chatbox("option", "boxManager").toggleBox()
    else
      box = $("#chat_div").chatbox(
        id: "You"
        user:
          key: "value"

        title: "Chat - " + title
        messageSent: (id, user, msg) ->
          $.ajax
            url: "/transaction/new_chat"
            type: "post"
            context: "this"
            dataType: "json"
            data:
              chat: msg
              ref: trid
              title: title

            success: (msg) ->
              
            error: (jqXHR, textStatus, errorThrown) ->

          $("#chat_div").chatbox("option", "boxManager").addMsg id, msg    
          
      )

#-------------------------------------------------------------------------------------------------------------------- 
