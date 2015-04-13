ready = ->
  $(document).on 'click', '.mistakes a', ->
    $(this).addClass('active')
    parentDiv = $(this).parent().parent().parent()
    parentDiv.find('.mistakes-list').append("<div class='btn btn-danger'>" + $(this).text() + "</div>")
    hiddenField = parentDiv.find('input[type="hidden"]')
    newVal = hiddenField.val()
    newVal += ',' if newVal != ""
    newVal += $(this).text()
    hiddenField.val(newVal)
  $(document).on 'click', '.mistakes-list div', ->
    mistakeList = $(this).parent()
    mistakeList.children().addClass('count')
    $(this).removeClass 'count'
    newVal = ''
    $.each mistakeList.children('.count'), (index, element) ->
      newVal += ',' if newVal != ""
      newVal += $(this).text()
      $(this).removeClass 'count'
    mistakeList.parent().find('input[type="hidden"]').val(newVal)
    $(this).remove()

$(document).ready ready
$(document).on('page:load', ready)