# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

asInitVals = new Array()
$(document).ready ->
  oTable = $("#admin_view").dataTable(
    oLanguage: sSearch: "Search All : "    
  )

  $("tfoot input").keyup ->    
    # Filter on the column (the index) of this element 
    oTable.fnFilter @value, $("tfoot input").index(this)
  
  #
  #	 * Support functions to provide a little bit of 'user friendlyness' to the textboxes in 
  #	 * the footer
  #	 
  $("tfoot input").each (i) ->
    asInitVals[i] = @value


  $("tfoot input").focus ->
    if @className is "search_init"
      @className = ""
      @value = ""

  $("tfoot input").blur (i) ->
    if @value is ""
      @className = "search_init"
      @value = asInitVals[$("tfoot input").index(this)]
   
#--------------------------------------------------------------------------------------------------------------------


jQuery ->
  $(document).on "click", "#bar_user", ->
    $("#bar_user_confirm").dialog "open"


jQuery ->
  $("#bar_user_confirm").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    buttons:
      "Bar": ->
        $(this).dialog "close"
        $.ajax
          url: "bar_user"
          type: "POST"
          context: "this"
          dataType: "json"
          data:
            bar_user_id: $("#bar_user").attr("data-uid")

          beforeSend: ->
            $.blockUI
              theme:     true, 
              title:    'Please Wait', 
              message:  '<p>Your request is being processed</p>'
            
          success: (data, textStatus, XHR) ->
            $("#bar_user_success").dialog "open"
            $("#bar_user").val("Un Bar User").attr("id","unbar_user")
            $("#user_current_status").text("Locked").fadeIn(500)
          complete: (jqXHR, textStatus) -> 
            setTimeout $.unblockUI            
          error: (XHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            $("#custom_error").html(XHR.responseText)
            $("#error_message").dialog "open"
      Cancel: ->
        $(this).dialog "close"  


jQuery ->
  $("#bar_user_success").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    buttons:
      "Ok": ->
        $(this).dialog "close" 


#--------------------------------------------------------------------------------------------------------------------
# Un bar User
jQuery ->
  $(document).on "click", "#unbar_user", ->
    $("#unbar_user_confirm").dialog "open"


jQuery ->
  $("#unbar_user_confirm").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    buttons:
      "Un-Bar": ->
        $(this).dialog "close"
        $.ajax
          url: "unbar_user.js"
          type: "post"
          context: "this"
          dataType: "script"
          data:
            unbar_user_id: $("#unbar_user").attr("data-uid")

          beforeSend: ->
            $.blockUI
              theme:     true, 
              title:    'Please Wait', 
              message:  '<p>Your request is being processed</p>'
            
          success: (msg) ->
            $("#unbar_user_success").dialog "open"
            $("#unbar_user").val("Bar User").attr("id","bar_user")
            $("#user_current_status").text("Active").fadeIn(500)
          complete: (jqXHR, textStatus) -> 
            setTimeout $.unblockUI         
          error: (jqXHR, textStatus, errorThrown)  ->
            setTimeout $.unblockUI
            $("#custom_error").html("Unblocking Unsuccessful. Please contact admin")
            $("#error_message").dialog "open"
      Cancel: ->
        $(this).dialog "close"         


jQuery ->
  $("#unbar_user_success").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    buttons:
      "Ok": ->
        $(this).dialog "close"

#--------------------------------------------------------------------------------------------------------------------
# Error Message
jQuery ->
  $("#error_message").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    buttons:
      "Ok": ->
        $(this).dialog "close"           
         