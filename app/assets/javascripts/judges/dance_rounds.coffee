ready = ->
  calculateOverallRating = ->
    $('#dance_teams > div.dance_team').each ->
      $danceTeam = $(this)
      points = 0
      $danceTeam.find('.points').each ->
        max = 0
        maxRating = 0
        rating = 0
        punishment = 0
        if $(this).attr('max')
          max = parseInt $(this).attr('max')
        $(this).find('input').each ->
          if $(this).attr('id').match(/rating$/)
            maxRating += 100
            rating += 100 - parseInt($(this).val())
          if $(this).attr('id').match(/mistakes$/)
            if $(this).val() != ''
              $.each $(this).val().split(','), (index, val) ->
                punishment += parseInt(val.substring(1, val.length))
        if $(this).attr('mistake_type') == 'rel'
          points += Math.max.apply(Math, [0, ((rating / maxRating * max) - punishment)])
        else
          if maxRating > 0
            points += (rating / maxRating * max) - punishment
          else
            points -= punishment
          points = Math.max.apply(Math, [0, points])
          $danceTeam.find('.total').text(points.toFixed(2))

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
  $(document).on 'click', 'td.markable', ->
    if $(this).hasClass('info')
      $(this).removeClass('info')
      $(this).find('input').val('0')
    else
      $(this).removeClass('danger')
      $(this).addClass('info')
      $(this).find('input').val('1')

$(document).ready ready
$(document).on('page:load', ready)