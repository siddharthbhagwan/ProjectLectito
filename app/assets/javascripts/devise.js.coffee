# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  
# Modal dialog for Sign in . Title bar is removed. And toggle code added
  $('.modal_login').click ->
    # Remove Title Bar
    $('#sign_in_div').parent().find('.ui-dialog-titlebar').remove();
    # If called via search Results, close already open dialog
    if $('#sign_in_or_sign_up').dialog('isOpen')
      $('#sign_in_or_sign_up').dialog 'close'
    $('#sign_in_div').dialog 'open'


  $('#sign_in_div').dialog
    autoOpen: false
    modal: true
    resizable: false
    draggable: false
    minWidth: 600
    height: 230

# Code to add padding to jumbotron in case any label appears
  if ($('.label-success') || $('.label-important') || $('.label-info') || $('.label-error'))
    $('.jumbotron').addClass('jtp')

# Hide Frontpage Div
  $('.frontpagesb').hide()
