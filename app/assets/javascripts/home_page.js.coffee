$ ->
  $(document).on "click", "input[id^='timeline_']", ->
    $(this).popover 
      placement: 'right'
      html: true
      trigger: 'click'
      container: 'body'
