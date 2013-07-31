# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $("#address_locality").autocomplete 
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
      $("#address_state").val(ui.item.state)
      $("#address_city").val(ui.item.city)
      $("#address_pin").val(ui.item.pin)