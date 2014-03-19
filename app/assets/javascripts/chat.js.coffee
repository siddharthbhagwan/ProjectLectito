# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

chat_boxes = new Array()
exports = this
exports.chat_boxes = chat_boxes

$(document).ready ->
  
  # Send chat on clicking send
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
  # Press Enter key to send chat
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
  # Initiating box chat when user clicks chat button, or green dot
  $(document).on "click", "input[id^='chatbox_'], img[id^='online_']", ->
    trid =  $(this).attr("data-trid")
    if !$("#chat_div_" + trid).length
      $("#chat_divs").append("<div id='chat_div_" + trid + "''></div>")

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

    # If Box has been initiated, just toggle
    if jQuery.inArray(trid, exports.chat_boxes) != -1
      $("#chat_div_" + trid).chatbox("option", "boxManager").toggleBox()
      $("#chat_div_" + trid).next().find('textarea').eq(0).focus()
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

          $("#chat_div_" + trid).chatbox("option", "boxManager").addMsg you, msg, '', false
        
        # When the box is closed, move each box after it to the left to fill in the gap     
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

          $("#chat_div_" + trid).remove()
      )

      # here
      if $("#chat_div_" + trid + " #chat_history_div").children().length == 0
        $.ajax
          url: "/chat/box_chat_history.json"
          type: "get"
          context: "this"
          dataType: "json"
          data:
            trid: trid

          success: (msg) ->
            i = 0
            while i < msg.length
              # Trim last 2 characters from each chat => \n
              # FIXME - check if \n is being appended in controller. If so, dont append , so no need to trim
              $("#chat_div_" + trid).chatbox("option", "boxManager").addMsg msg[i], msg[i+1].substring(0, msg[i+1].length - 2), "ct_" + msg[i+2], true
              i = i + 3

          complete: (jqXHR, textStatus) ->  

          error: (jqXHR, textStatus, errorThrown) ->

      $("#chat_div_" + trid).next().find('textarea').eq(0).focus()

#-------------------------------------------------------------------------------------------------------------------- 
  # Listening for chat messages sent toog user
  $.ajax
    url: "/transaction/user_id.json"
    type: "get"
    context: "this"
    dataType: "json"
    #TODO Remove duplication on code - if and else for initiated and initiating box chat
    success: (msg) ->
      id = msg.user_id
      myFirebase = new Firebase("https://projectlectito.firebaseio.com/transaction_listener_" + id)
      # Listener for Firebase messages
      myFirebase.on "child_added", (childSnapshot, prevChildName) ->
        pData = $.parseJSON(childSnapshot.val())
        # Listening for chat messages [ other cold be accepted_self, borrow_request etc]
        if pData[0] == "chat"
          # Box Type Chat [ other could be message ]
          if pData[1].type == 'box'
            # Check if div for this particular transaction id exists, if not, create it
            if !$("#chat_div_" + pData[1].trid).length
              $("#chat_divs").append("<div id='chat_div_" + pData[1].trid + "'></div>")

            # Check if chat box for this transaction already Inititated or not
            if jQuery.inArray(pData[1].trid, exports.chat_boxes) is -1

              # Chat box isnt initialzed , initalize it
              # Box Intitialize start
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

                  $("#chat_div_" + pData[1].trid).chatbox("option", "boxManager").addMsg pData[1].other, msg, '', false

                # When the box is closed, move each box after it to the left to fill in the gap
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

                  $("#chat_div_" + pData[1].trid).remove()
              )
              # Box Initialize end

              $("#chat_div_" + pData[1].trid).chatbox("option", "boxManager").addMsg pData[1].you, pData[1].text, pData[1].id, false

              # No child elements i.e, no texts displayed in the box ( since box is newly initialized), retrieve history along with last ping, else just display last ping
              $.ajax
                url: "/chat/box_chat_history.json"
                type: "get"
                context: "this"
                dataType: "json"
                data:
                  trid: pData[1].trid
                  id: pData[1].id

                success: (msg) ->
                  i = 0
                  while i < msg.length
                    # Trim last 2 characters from each chat => \n
                    # FIXME - check if \n is being appended in controller. If so, dont append , so no need to trim
                    $("#chat_div_" + pData[1].trid).chatbox("option", "boxManager").addMsg msg[i], msg[i+1].substring(0, msg[i+1].length - 2), "ct_" + msg[i+2], true
                    i = i + 3

                complete: (jqXHR, textStatus) -> 

                error: (jqXHR, textStatus, errorThrown) ->

              # If another chat box is active, dont focus on new one, focus stays on old one
              if $("div[id^='chat_div_']").length is 1
                $("#chat_div_" + pData[1].trid).next().find('textarea').eq(0).focus()

            # Chat box already initialized 
            else
              $("#chat_div_" + pData[1].trid).chatbox(
                id: "chatbox_" + pData[1].trid
                title: "Chat - " + pData[1].title
                # Ajax Request when message is sent
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

                  # Display the sent message with your initials
                  $("#chat_div_" + pData[1].trid).chatbox("option", "boxManager").addMsg pData[1].other, msg, '', false

                # When the box is closed, move each box after it to the left to fill in the gap
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

                  $("#chat_div_" + pData[1].trid).remove()
              )
              
              # if $("#chat_div_" + pData[1].trid).has("#" + pData[1].id).length
              $("#chat_div_" + pData[1].trid).chatbox("option", "boxManager").addMsg pData[1].you, pData[1].text, "ct_" + pData[1].id, false

              # If another chat box is active, dont focus on new one, focus stays on old one
              if $("div[id^='chat_div_']").length is 1
                $("#chat_div_" + pData[1].trid).next().find('textarea').eq(0).focus()

          else #if pData[1].type == 'page'
            $('#chat_box').val($('#chat_box').val() + "\n" + pData[1].you + " : " + pData[1].text)
            psconsole = $("#chat_box")
            psconsole.scrollTop psconsole[0].scrollHeight - psconsole.height()

          myFirebase.child(childSnapshot.bc.path.m[1]).remove()
          # If myFirebase.remove() is called, -> If there are multiple calues udner a single key, only the last value
          # is delivered, the others are read from Firebase, but dont reach. So instead of removing the entire parent,
          # traverse the above path and find the key, and individually remove each. Strangely, placing this comment
          # Above the line causes the code to stop working, so be careful.
              
    complete: (jqXHR, textStatus) ->

    error: (jqXHR, textStatus, errorThrown) ->
      # setTimeout $.unblockUI
      # $("#error_message").dialog "open" 

#--------------------------------------------------------------------------------------------------------------------
  # Keep page chat text box scrolled down
  jQuery ->
    psconsole = $("#chat_box")
    psconsole.scrollTop psconsole[0].scrollHeight - psconsole.height()     

#--------------------------------------------------------------------------------------------------------------------

  # If Esc is pressed in any chat box, it is closed by simulating a click on the cross box, and 
  # if another chatbox is open, it is focussed upon
  $(document).on "keydown", ".ui-widget-content .ui-chatbox-input", (e) ->
    if e.which is 27
      $(this).parent().prev().children().eq(1).click()
      if $('div[id^="chat_div_"]').length isnt 0
        $('div[id^="chat_div_"]').next().find('textarea').eq(0).focus()

#---------------------------------------------------------------------------------------------------------------------

