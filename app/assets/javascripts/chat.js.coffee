# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

chat_boxes = new Array()
exports = this
exports.chat_boxes = chat_boxes

$(document).ready ->
  
  $("#chat_send").click ->
    you = $("#chat_text").attr("data-you")
    chat_text = $("#chat_text").val()
    $("#chat_text").val("")
    $("#chat_box").val($('#chat_box').val() +  '\n' + you + " : " + chat_text)
    psconsole = $("#chat_box")
    psconsole.scrollTop psconsole[0].scrollHeight - psconsole.height()
    $.ajax
      url: "/transaction/new_chat"
      type: "post"
      context: "this"
      dataType: "json"
      data:
        chat: chat_text
        ref: window.location.pathname.replace('/chat/','')
        type: 'page'
        you: you

      success: (msg) ->
                
      error: (jqXHR, textStatus, errorThrown) ->

#--------------------------------------------------------------------------------------------------------------------- 

  $("#chat_text").keydown (e) ->
    if e.keyCode is 13
      you = $("#chat_text").attr("data-you")
      chat_text = $("#chat_text").val()
      $("#chat_text").val("")
      $('#chat_box').val($('#chat_box').val() +  '\n' + you + " : " + chat_text)
      psconsole = $("#chat_box")
      psconsole.scrollTop psconsole[0].scrollHeight - psconsole.height()
      $.ajax
        url: "/transaction/new_chat"
        type: "post"
        context: "this"
        dataType: "json"
        data:
          chat: chat_text
          ref: window.location.pathname.replace('/chat/','')
          type: 'page'
          you: you

        success: (msg) ->          
          
        error: (jqXHR, textStatus, errorThrown) ->

#--------------------------------------------------------------------------------------------------------------------- 

  $(document).on "click", "input[id^='chatbox_']", ->
    trid =  $(this).attr("data-trid")
    if $(this).attr("data-title").length > 20
      title = $(this).attr("data-title").substring(0,20) + "..."
    else
      title = $(this).attr("data-title")

    ccn = $(this).attr("data-currentcn")
    bcn = $(this).attr("data-lendercn")
    lcn = $(this).attr("data-borrowercn")

    you = ccn
    if ccn == bcn
      othercn = lcn
    else
      othercn = bcn

    if jQuery.inArray(trid, exports.chat_boxes) != -1
      $("#chat_div_" + trid).chatbox("option", "boxManager").toggleBox()
    else
      offset = exports.chat_boxes.length * 315
      exports.chat_boxes.push(trid)
      $("#chat_div_" + trid).chatbox(
        id: "chatbox_" + trid
        offset: offset
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
              you: you
              other: othercn
              type: 'box'

            success: (msg) ->
              
            error: (jqXHR, textStatus, errorThrown) ->
          $("#chat_div_" + trid).chatbox("option", "boxManager").addMsg you, msg
              
        boxClosed: ->
          closed_offset = $("#chat_div_" + trid).chatbox("option", "offset")
          exports.chat_boxes = jQuery.grep(exports.chat_boxes, (value) ->
            value isnt trid
          )
          i = 0
          while i < exports.chat_boxes.length
            current_offset = $("#chat_div_" + exports.chat_boxes[i]).chatbox("option", "offset")
            if current_offset > closed_offset
              $("#chat_div_" + exports.chat_boxes[i]).chatbox("option", "offset", current_offset - 315)
            i++
      )

  #-------------------------------------------------------------------------------------------------------------------- 
  
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
          if pData[0] == "chat"
            if pData[1].type == 'box'
              if jQuery.inArray(pData[1].trid, exports.chat_boxes) is -1    
                exports.chat_boxes.push(pData[1].trid)
                $("#chat_div_" + pData[1].trid).chatbox(
                  id: "chatbox_" + pData[1].trid
                  offset: (exports.chat_boxes.length-1) * 315
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
                        title: pData[1].title
                        you: pData[1].other
                        other: pData[1].you
                        type: 'box'

                      success: (msg) ->
                        
                      error: (jqXHR, textStatus, errorThrown) ->

                    $("#chat_div_" + pData[1].trid).chatbox("option", "boxManager").addMsg pData[1].other, msg

                  boxClosed: ->
                    closed_offset = $("#chat_div_" + pData[1].trid).chatbox("option", "offset")
                    exports.chat_boxes = jQuery.grep(exports.chat_boxes, (value) ->
                      value isnt pData[1].trid
                    )
                    i = 0
                    while i < exports.chat_boxes.length
                      current_offset = $("#chat_div_" + exports.chat_boxes[i]).chatbox("option", "offset")
                      if current_offset > closed_offset
                        $("#chat_div_" + exports.chat_boxes[i]).chatbox("option", "offset", current_offset - 315)
                      i++
                )
                $("#chat_div_" + pData[1].trid).chatbox("option", "boxManager").addMsg pData[1].you, pData[1].text

              else
                $("#chat_div_" + pData[1].trid).chatbox(
                  id: "chatbox_" + pData[1].trid
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
                        title: pData[1].title
                        you: pData[1].other
                        other: pData[1].you
                        type: 'box'

                      success: (msg) ->
                        
                      error: (jqXHR, textStatus, errorThrown) ->

                    $("#chat_div_" + pData[1].trid).chatbox("option", "boxManager").addMsg pData[1].other, msg

                  boxClosed: ->
                    closed_offset = $("#chat_div_" + pData[1].trid).chatbox("option", "offset")
                    exports.chat_boxes = jQuery.grep(exports.chat_boxes, (value) ->
                      value isnt pData[1].trid
                    )
                    i = 0
                    while i < exports.chat_boxes.length
                      current_offset = $("#chat_div_" + exports.chat_boxes[i]).chatbox("option", "offset")
                      if current_offset > closed
                        $("#chat_div_" + exports.chat_boxes[i]).chatbox("option", "offset", current_offset - 315)
                      i++
                )
                $("#chat_div_" + pData[1].trid).chatbox("option", "boxManager").addMsg pData[1].you, pData[1].text

            else #if pData[1].type == 'page'
              $('#chat_box').val($('#chat_box').val() + "\n" + pData[1].you + " : " + pData[1].text);
              psconsole = $("#chat_box")
              psconsole.scrollTop psconsole[0].scrollHeight - psconsole.height()

            myChild.remove()  
              
    complete: (jqXHR, textStatus) ->

    error: (jqXHR, textStatus, errorThrown) ->
      # setTimeout $.unblockUI
      # $("#error_message").dialog "open" 
