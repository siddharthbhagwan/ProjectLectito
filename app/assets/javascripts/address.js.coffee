# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# Code to auto complete and populate remainder address/locality fields
jQuery ->
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

    select: (e, ui) ->
      $("#address_locality").val(ui.item.area)
      $("#address_state").val(ui.item.state)
      $("#address_city").val(ui.item.city)
      $("#address_pin").val(ui.item.pin)
      
      ).blur ->
        value_typed = $("#address_locality").val()
        value_selected = $("#address_locality").data("selected_item")
        if value_typed != value_selected
          $("#address_locality").val("")

        if value_selected == "No Matching Results Found"
          $("#address_locality").val("") 

#--------------------------------------------------------------------------------------------------------------------
# TODO Check how to propagate modal confirm accept/reject
jQuery ->
  $("#delete_buttonn").click ->
    $("#delete_confirm").dialog "open"


jQuery ->
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

