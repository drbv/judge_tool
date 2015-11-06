# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'click touchend', 'table .clickable', ->
  $('.'+$(this)[0].id).each ->
    if $(this).hasClass('collapse')
      $(this).removeClass('collapse')
      $(this).addClass('expanded')
    else
      $(this).removeClass('expanded')
      $(this).addClass('collapse')