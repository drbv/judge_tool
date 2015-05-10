class DanceRoundPolicy < ApplicationPolicy
  def show?
    user && user.has_role?(:judge)
  end

  def create?
    user && user.has_role?(:observer, record.round) && DanceRound.active.blank?
  end

  def update?
    user && record && user_is_judge_for_this_round? && user_has_not_rated_already?
  end

  def accept?
    user && user.has_role?(:observer, record.round) && record.ready?
  end

  def user_is_judge_for_this_round?
    (user.has_role?(:observer, record.round) || user.has_role?(:dance_judge, record.round) || user.has_role?(:acrobatics_judge, record.round))
  end

  def user_has_not_rated_already?
    !user.rated?(record)
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

  def permitted_acrobatic_attributes
    if user.has_role?(:observer, record.round)
      %i[dance_team_id acrobatic_id mistakes]
    elsif user.has_role?(:acrobatics_judge, record.round)
      %i(dance_team_id acrobatic_id rating mistakes)
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
