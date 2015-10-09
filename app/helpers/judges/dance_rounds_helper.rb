module Judges::DanceRoundsHelper
  def dance_rating_class(attr, dance_round, team)
    html_classes = []
    if attr == :full_mistakes
      'observer-related'
    else
      if dance_round.dance_ratings.where(dance_team_id: team.id).any? { |rating| rating.diff_to_big?(attr) }
        html_classes << 'danger'
        html_classes << 'markable' if current_dance_round.ready?(current_user)
      end
    end
    !html_classes.empty? && html_classes.join(' ')
  end

  def acrobatic_rating_class(acrobatic, team)
    html_classes = []
    if acrobatic.acrobatic_ratings.where(dance_team_id: team.id).any? { |rating| rating.diff_to_big? }
      html_classes << 'danger'
      html_classes << 'markable' if current_dance_round.ready?(current_user)
    end
    !html_classes.empty? && html_classes.join(' ')
  end

  def any_mistakes_adjusting?
    current_user.dance_teams(current_dance_round).any? { |team| current_dance_round.mistakes_adjusting?(team) }
  end
end
