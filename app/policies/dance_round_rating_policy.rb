class DanceRoundRatingPolicy < ApplicationPolicy
  def update?
    user && user.has_role?(:admin)
  end

  def permitted_dance_attributes
    if user.has_role?(:observer, record.round)
      %i[dance_team_id mistakes]
    elsif user.has_role?(:dance_judge, record.round)
      %i[female_base_rating female_turn_rating male_base_rating male_turn_rating choreo_rating dance_figure_rating team_presentation_rating dance_team_id mistakes]
    else
      []
    end
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
