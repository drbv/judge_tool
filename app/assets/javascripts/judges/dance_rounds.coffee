ready = ->
  calculateOverallRating = ->

  $(document).on 'click', '.mistakes a', ->
    $(this).addClass('active')
    parentDiv = $(this).parent().parent().parent()
    parentDiv.find('.mistakes-list').append("<div class='btn-danger'>" + $(this).text() + "</div>")
    hiddenField = parentDiv.find('input[type="hidden"]')
    newVal = hiddenField.val()
    newVal += ',' if newVal != ""
    newVal += $(this).text()
    hiddenField.val(newVal)
    calculateOverallRating()
    false
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
    calculateOverallRating()
    false
  $(document).on 'click', '.rating div', ->
    $(this).parent().children().removeClass('active')
    $(this).addClass('active')
    $(this).prevAll().addClass('active')
    $(this).parent().parent().find('input[type=hidden]').val($(this).text())
    calculateOverallRating()
    false

$(document).ready ready
$(document).on('page:load', ready)