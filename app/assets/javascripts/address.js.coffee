# Code to auto complete and populate remainder address/locality fields
$(document).ready ->

  $("#address_locality").autocomplete(
    source: (request, response) ->
      $.ajax
        url: "autocomplete_area"
        dataType: "json"
        data:
          area: $("#address_locality").val()
          
        success: (data) ->
          response $.map(data, (item) ->
            label: item.area
            state: item.state
            city: item.city
            pin: item.pincode
            ) 

    response: (e, ui) ->
      if ui.content.length is 0
        $("#locality_empty").fadeIn(300)
        $("#address_state").val("")
        $("#address_city").val("")
        $("#address_pin").val("")
      else
        $("#locality_empty").hide()

    select: (e, ui) ->
      $("#address_locality").val(ui.item.area)
      $("#address_state").val(ui.item.state)
      $("#address_city").val(ui.item.city)
      $("#address_pin").val(ui.item.pin)
      
  ).blur ->
  # ).blur ->
  #   value_typed = $("#address_locality").val()
  #   value_selected = $("#address_locality").data("selected_item")
  #   if value_typed != value_selected
  #     $("#address_locality").val("")

  #   if value_selected == "No Matching Results Found"
  #     $("#address_locality").val("") 

#--------------------------------------------------------------------------------------------------------------------
# TODO Check how to propagate modal confirm accept/reject into html comfirm

  $("#delete_buttonn").click ->
    $("#delete_confirm").dialog "open"


  $("#delete_confirm").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    buttons:
      "Ok": ->
        $(this).dialog "close"

      Cancel: ->
        $(this).dialog "close"

#--------------------------------------------------------------------------------------------------------------------

  $("#add_address").click ->  
    # if $("#address_locality").length isnt 0
    #   if !$("#locality_empty").is(":visible")
    $("#new_address").submit()

#--------------------------------------------------------------------------------------------------------------------

  $("#update_address").click ->  
    # if $("#address_locality").length isnt 0
    #   if !$("#locality_empty").is(":visible")
    $(".edit_address").submit()
    
#--------------------------------------------------------------------------------------------------------------------

