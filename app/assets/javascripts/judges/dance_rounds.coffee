ready = ->
  startReload = ->
    $.get window.location.pathname, (data) ->
      # TODO: Figure out, why comparision fails always
      unless document.getElementById('reload')
        clearInterval intervalHandler
      if $('#main').html() != data
        $('#main').html(data)

  if document.getElementById('reload')
      intervalHandler = setInterval startReload, Math.floor(Math.random() * 5000 + 1000)

  checkJudgeStatus = (judgeStatus) ->
    $.get judgeStatus.attr('update_uri'), (data) ->
      unless judgeStatus.hasClass(data)
        judgeStatus.removeClass('alert-info').removeClass('alert-danger')
        judgeStatus.addClass(data)
      if data == 'alert-info' || data == 'alert-danger'
        setTimeout(
          ->
            checkJudgeStatus(judgeStatus)
        , 1000
        )
      else
        if $('#mark_ratings').length > 0 || judgeStatus.parent().parent().children('alert-info, alert-danger').length <= 0
          #This will reload the site without the previos post request
          # And will also kill the INtervalHandler to relaod contant, not nice but functianal
          window.location.href = window.location.href


  $('#judge_statusses .alert.alert-danger, #judge_statusses .alert.alert-info').each (loading) ->
    judgeStatus = $(this)
    setTimeout(
      ->
        checkJudgeStatus(judgeStatus)
      , 1000
    )
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

  $(document).on 'click touchend', '.enabled .mistakes a', ->
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
  $(document).on 'click touchend', '.enabled .mistakes-list div', ->
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
    calculateOverallRating()
    false
  $(document).on 'click touchend', '.enabled .rating div', ->
    $(this).parent().children().removeClass('active')
    $(this).addClass('active')
    $(this).prevAll().addClass('active')
    $(this).parent().parent().find('input[type=hidden]').val($(this).text())
    calculateOverallRating()
    false

  $("input.mistakes_inputs").on 'change', ->
    found_broken_mistake_input = false
    $("input.mistakes_inputs").each ->
      if !(/^((T2|T10|T20|S2|S10|S20|U2|U10|U20|V5|P0|A20)(,(T2|T10|T20|S2|S10|S20|U2|U10|U20|V5|P0|A20))*)?$/).test(this.value)
        alert "Fehlereingabe prüfen"
        found_broken_mistake_input = true
    if(found_broken_mistake_input)
      $("input#observer_button").prop('disabled', true);
    else
      $("input#observer_button").prop('disabled', false);


  $(document).on 'click touchend', 'tr.markable', ->
    if $(this).hasClass('info')
      $(this).removeClass('info')
      $(this).addClass('danger')
      $(this).find('input').val('0')
    else
      $(this).removeClass('danger')
      $(this).addClass('info')
      $(this).find('input').val('1')
    submit = $('#mark_ratings input[type="submit"]')
    if $('tr.markable.info').size() > 0
      if submit.val() != 'Fehler korrigieren und markierte Zeilen zur Diskussion freigeben!'
        submit.attr('oldText', submit.val())
        submit.val('Fehler korrigieren und markierte Zeilen zur Diskussion freigeben!')
    else
      if submit.val() == 'Fehler korrigieren und markierte Zeilen zur Diskussion freigeben!'
        submit.val(submit.attr('oldText'))

$(document).ready ready
$(document).on('page:load', ready)
