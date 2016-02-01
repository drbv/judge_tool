# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ready = ->
  $(document).on 'click touchend', '.mistakes a', ->
    $(this).addClass('active')
    parentDiv = $(this).parent().parent().parent()
    parentDiv.find('.mistakes-list').append("<div class='btn-danger'>" + $(this).text() + "</div>")
    hiddenField = parentDiv.find('input[type="hidden"]')
    newVal = hiddenField.val()
    newVal += ',' if newVal != ""
    newVal += $(this).text()
    hiddenField.val(newVal)
    false
  $(document).on 'click touchend', '.mistakes-list div', ->
    mistakeList = $(this).parent()
    mistakeList.children().addClass('count')
    $(this).removeClass 'count'
    newVal = ''
    $.each mistakeList.children('.count'), (index, element) ->
      newVal += ',' if newVal != ""
      newVal += $(this).text()
      $(this).removeClass 'count'
    mistakeList.parent().parent().find('input[type="hidden"]').val(newVal)
    $(this).remove()
    false
$(document).ready ready
$(document).on('page:load', ready)
