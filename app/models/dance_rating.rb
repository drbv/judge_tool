class DanceRating < ActiveRecord::Base
  belongs_to :dance_team
  belongs_to :dance_round
  belongs_to :user

  validates_presence_of :dance_team, :dance_round, :user
  validates_presence_of :female_base_rating, :female_turn_rating, :male_base_rating, :male_turn_rating, :choreo_rating, :dance_figure_rating, :team_presentation_rating, unless: -> { user.has_role?(:observer, dance_round.round) }
  validates_format_of :mistakes, with: /\A(?:(?:S2|S10|S20|U2|U10|U20)(?:,(S2|S10|S20|U2|U10|U20))*)?\Z/
end
