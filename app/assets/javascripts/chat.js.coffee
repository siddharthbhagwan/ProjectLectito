# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  chat_boxes = new Array()
  exports = this
  exports.chat_boxes = chat_boxes 


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

#--------------------------------------------------------------------------------------------------------------------- 

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

#--------------------------------------------------------------------------------------------------------------------- 

  $(document).on "click", "input[id^='chat_']", ->
    trid =  $(this).attr("data-trid")
    if $(this).attr("data-title").length > 20
      title = $(this).attr("data-title").substring(0,20) + "..."
    else
      title = $(this).attr("data-title")

    if jQuery.inArray(trid, exports.chat_boxes) != -1
      $("#chat_div_" + trid).chatbox("option", "boxManager").toggleBox()
    else
      offset = exports.chat_boxes.length * 315
      exports.chat_boxes.push(trid)
      $("#chat_div_" + trid).chatbox(
        id: "chatbox_" + trid
        offset: offset
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
          $("#chat_div_" + trid).chatbox("option", "boxManager").addMsg "You", msg
              
        boxClosed: ->
          closed_offset = $("#chat_div_" + trid).chatbox("option", "offset")       
          exports.chat_boxes = jQuery.grep(exports.chat_boxes, (value) ->
            value isnt trid
          )
          i = 0
          while i < exports.chat_boxes.length
            current_offset = $("#chat_div_" + exports.chat_boxes[i]).chatbox("option", "offset")
            if current_offset > closed
              $("#chat_div_" + exports.chat_boxes[i]).chatbox("option", "offset", current_offset - 315)
            i++
      )

  #-------------------------------------------------------------------------------------------------------------------- 
  
  $.ajax
    url: "/transaction/user_id"
    type: "get"
    context: "this"
    dataType: "json"

    success: (msg) ->
        id = msg
        source = new EventSource('transaction/transaction_status')
        source.addEventListener 'transaction_listener_' + id, (e) ->
          pData = $.parseJSON(e.data)
          if pData[0] == "chat"
            $("#chat_div_" + pData[1].trid).chatbox(
              id: "chatbox_" + pData[1].trid
              offset: $(".ui-chatbox").length * 315
              user:
                key: "value"

              title: "Chat - " + pData[1].title
              messageSent: (id, user, msg) ->
                $.ajax
                  url: "/transaction/new_chat"
                  type: "post"
                  context: "this"
                  dataType: "json"
                  data:
                    chat: msg
                    ref: pData[1].trid

                  success: (msg) ->
                    
                  error: (jqXHR, textStatus, errorThrown) ->

                $("#chat_div_" + pData[1].trid).chatbox("option", "boxManager").addMsg "You", msg

              boxClosed: ->
                chat_boxes = jQuery.grep(chat_boxes, (value) ->
                value isnt trid
                )   
                i = 0
                while i < chat_boxes.length
                  $("#chat_div_" + chat_boxes[i]).chatbox("option", "offset", 0)
                  i++            
            )
            $("#chat_div_" + pData[1].trid).chatbox("option", "boxManager").addMsg "Other Person", pData[1].text

    complete: (jqXHR, textStatus) ->

    error: (jqXHR, textStatus, errorThrown) ->
      setTimeout $.unblockUI
      $("#error_message").dialog "open" 
