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

  def dance_rating_tablecell(attr, rating)
    html_classes = []
    if attr != :full_mistakes
      html_classes << 'markable' if current_dance_round.ready?(current_user)
      html_classes << 'danger' if rating.diff_to_big?(attr)
    end
    html_classes.empty? && html_classes.join(' ')
  end

  def acrobatic_rating_tablecell(rating)
    html_classes = []
    html_classes << 'markable' if current_dance_round.ready?(current_user)
    html_classes << 'danger' if rating.diff_to_big?
    html_classes.empty? && html_classes.join(' ')
  end
end
