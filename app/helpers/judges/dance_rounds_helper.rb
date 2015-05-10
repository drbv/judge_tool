module Judges::DanceRoundsHelper
  def judge_status_class(judge)
    if judge.rated?(current_dance_round)
      if judge.open_discussions?(current_dance_round)
        'alert-info'
      else
        'alert-success'
      end
    else
      'alert-danger'
    end
  end
end
