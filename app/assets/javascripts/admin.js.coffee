asInitVals = new Array()

# Fn to decide what error to display
display_error = (statusCode) ->
  if statusCode is 403
    $('#error_message_403').dialog 'open'
  else
    $('#error_message_generic').dialog 'open'

#--------------------------------------------------------------------------------------------------------------------

# Fn to block UI while processing ajax calls
before_send = ->
  $.blockUI
    theme:     true,
    title:    'Please Wait',
    message:  '<p>Your request is being processed</p>'
    draggable: false

#--------------------------------------------------------------------------------------------------------------------    

# Datatables req date range filter
# Last 2 else return true means display the row ( fn is called for each row)
$.fn.dataTableExt.afnFiltering.push (oSettings, aData, iDataIndex) ->
  if $('#min_req').val() isnt undefined and $('#max_req').val() isnt undefined
    if $('#min_req').val() isnt '' or $('#max_req').val() isnt ''
      iMin_temp = $('#min_req').val()
      iMin_temp = '2013-12-20'  if iMin_temp is ''

      iMax_temp = $('#max_req').val()
      iMax_temp = '2016-01-01'  if iMax_temp is ''

      arr_min = iMin_temp.split('-')
      arr_max = iMax_temp.split('-')
      arr_date = aData[4].split('-')

      iMin = new Date(arr_min[0], arr_min[1], arr_min[2], 0, 0, 0, 0)
      iMax = new Date(arr_max[0], arr_max[1], arr_max[2], 0, 0, 0, 0)
      iDate = new Date(arr_date[0], arr_date[1], arr_date[2], 0, 0, 0, 0)

      if iMin is '' and iMax is ''
        return true
      else if iMin is '' and iDate < iMax
        return true
      else if iMin <= iDate and '' is iMax
        return true
      else return true  if iMin <= iDate and iDate <= iMax
    else
      true
  else
    true

#--------------------------------------------------------------------------------------------------------------------

$(document).ready ->

# DataTables For All tables with class as datatable
  oTable_admin_view = $('.datatable').dataTable(
    oLanguage: sSearch: 'Search All : '
  )

  $('tfoot input').keyup ->    
    # Filter on the column (the index) of this element 
    oTable_admin_view.fnFilter @value, $('tfoot input').index(this)

  $('#min_req').keyup ->
    oTable_admin_view.fnDraw()

  $('#max_req').keyup ->
    oTable_admin_view.fnDraw()

#--------------------------------------------------------------------------------------------------------------------
jQuery ->
  $('#dates_filter_toggle').click ->
    $('#dates_filter_div').slideToggle 'slow', ->

#--------------------------------------------------------------------------------------------------------------------

jQuery ->
  $(document).on 'click', '#bar_user', ->
    $('#bar_user_confirm').dialog 'open'


jQuery ->
  $('#bar_user_confirm').dialog
    autoOpen: false
    modal: true
    resizable: false
    draggable: false
    buttons:
      'Bar': ->
        $(this).dialog 'close'
        $.ajax
          url: '/admin/bar_user'
          type: 'patch'
          context: 'this'
          dataType: 'json'
          data:
            bar_user_id: $('#bar_user').attr('data-uid')

          beforeSend: ->
            before_send()
            
          success: (data, textStatus, XHR) ->
            $('#bar_user_success').dialog 'open'
            $('#bar_user').val('Un Bar User').attr('id','unbar_user')
            $('#user_current_status').text('Locked').fadeIn(500)

          complete: (jqXHR, textStatus) ->
            setTimeout $.unblockUI

          error: (jqXHR, textStatus, errorThrown) ->
            setTimeout $.unblockUI
            display_error(jqXHR.status)

      Cancel: ->
        $(this).dialog 'close'

#--------------------------------------------------------------------------------------------------------------------
# Bar User Success Modal
jQuery ->
  $('#bar_user_success').dialog
    autoOpen: false
    modal: true
    resizable: false
    draggable: false
    buttons:
      'Ok': ->
        $(this).dialog 'close'


#--------------------------------------------------------------------------------------------------------------------
# Un bar User
jQuery ->
  $(document).on 'click', '#unbar_user', ->
    $('#unbar_user_confirm').dialog 'open'


jQuery ->
  $('#unbar_user_confirm').dialog
    autoOpen: false
    modal: true
    resizable: false
    draggable: false
    buttons:
      'Un-Bar': ->
        $(this).dialog 'close'
        $.ajax
          url: '/admin/unbar_user.json'
          type: 'patch'
          context: 'this'
          dataType: 'json'
          data:
            unbar_user_id: $('#unbar_user').attr('data-uid')

          beforeSend: ->
            before_send()
            
          success: (msg) ->
            $('#unbar_user_success').dialog 'open'
            $('#unbar_user').val('Bar User').attr('id','bar_user')
            $('#user_current_status').text('Active').fadeIn(500)

          complete: (jqXHR, textStatus) ->
            setTimeout $.unblockUI

          error: (jqXHR, textStatus, errorThrown)  ->
            setTimeout $.unblockUI
            $('#custom_error').html('Unblocking Unsuccessful. Please contact admin')
            $('#error_message').dialog 'open'

      Cancel: ->
        $(this).dialog 'close'

#--------------------------------------------------------------------------------------------------------------------
# UnBar User modal
jQuery ->
  $('#unbar_user_success').dialog
    autoOpen: false
    modal: true
    resizable: false
    draggable: false
    buttons:
      'Ok': ->
        $(this).dialog 'close'

#--------------------------------------------------------------------------------------------------------------------
# Error Message
jQuery ->
  $('#error_message_generic').dialog
    autoOpen: false
    modal: true
    resizable: false
    draggable: false
    buttons:
      'Ok': ->
        $(this).dialog 'close'
         
#--------------------------------------------------------------------------------------------------------------------
# Span fix for sign in page
jQuery ->
  if $('.jumbotron').length
    $('.col-md-12').removeClass('col-md-offset-1')
