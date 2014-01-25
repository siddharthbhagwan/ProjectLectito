# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  
  $("#sign_in").click ->
    $("#sign_in_div").dialog 'open'
    # Remove Title Bar
    $("#sign_in_div").parent().find(".ui-dialog-titlebar").remove();


  $("#sign_in_div").dialog
    autoOpen: false
    modal: true
    resizeable: false
    draggable: false
    minWidth: 600
    minHeight: 170 
