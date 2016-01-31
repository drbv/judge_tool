window.danceTimers = []
window.DanceTimer = class DanceTimer
  constructor: (@dance_team_id) ->
    @ms= 0
    @s=  0
    @m= 0
    @h= 0
    window.danceTimers[@dance_team_id] = this
    dance_team_id = @dance_team_id
    $('.dtimer[dance_team_id="' + @dance_team_id + '"] .btn.start').click ->
      danceTimer = window.danceTimers[dance_team_id]
      danceTimer.runTimer()
    $('.dtimer[dance_team_id="' + @dance_team_id + '"] .btn.stop').click ->
      danceTimer = window.danceTimers[dance_team_id]
      danceTimer.pauseTimer()
    $('.dtimer[dance_team_id="' + @dance_team_id + '"] .btn.reset').click ->
      danceTimer = window.danceTimers[dance_team_id]
      danceTimer.resetTimer()


  runTimer: ->
    dance_team_id = @dance_team_id
    @interval = setInterval((->
      danceTimer = window.danceTimers[dance_team_id]
      danceTimer.ms += 10
      if danceTimer.ms == 1000
        danceTimer.s++
        danceTimer.ms = 0
      if danceTimer.s == 60
        danceTimer.m++
        danceTimer.s = 0
      if danceTimer.m == 60
        danceTimer.h++
        danceTimer.m = 0
      danceTimer.display()
      return
    ), 10)
    return

  pauseTimer: ->
    clearInterval @interval
    # stop the interval
    @display()
    return

  resetTimer: ->
    clearInterval @interval
    @ms = 0
    @s = 0
    @m = 0
    @h = 0
    @display()
    return

  display: ->
    x = @ms
    if (x + '').length == 2
      x = '0' + x
    if (x + '').length == 1
      x = '00' + x
    if (@s + '').length == 1
      @s = '0' + @s
    if (@m + '').length == 1
      @m = '0' + @m
    if (@h + '').length == 1
      @h = '0' + @h
    $('.dtimer[dance_team_id="' + @dance_team_id + '"] .hours').text @h
    $('.dtimer[dance_team_id="' + @dance_team_id + '"] .minutes').text @m
    $('.dtimer[dance_team_id="' + @dance_team_id + '"] .seconds').text @s
    $('.dtimer[dance_team_id="' + @dance_team_id + '"] .milisecs').text x
    return
