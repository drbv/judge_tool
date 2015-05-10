class DanceRating < ActiveRecord::Base
  include ReopenedAttributes
  
  belongs_to :dance_team
  belongs_to :dance_round
  belongs_to :user
  has_many :dance_rating_history_entries

  validates_presence_of :dance_team, :dance_round, :user
  validates_presence_of :female_base_rating, :female_turn_rating, :male_base_rating, :male_turn_rating, :choreo_rating, :dance_figure_rating, :team_presentation_rating, unless: -> { user.has_role?(:observer, dance_round.round) }
  validates_format_of :mistakes, with: /\A(?:(?:T2|T10|T20|S2|S10|S20|U2|U10|U20|V5)(?:,(T2|T10|T20|S2|S10|S20|U2|U10|U20|V5))*)?\Z/
  validates_uniqueness_of :dance_round_id, scope: %i[user_id dance_team_id]
  validate :team_belongs_to_dance_round
  after_save :add_history_entry

  def full_mistakes
    mistakes.blank? ? 'Keine Fehler' : mistakes
  end

  def punishment
    @punishment ||= mistakes.split(',').map {|malus| malus[1..-1].to_i}.sum
  end

  def points
    @points ||= [(10 * (1 - (female_base_rating + female_turn_rating).to_d / 200) + 10 * (1 - (male_base_rating + male_turn_rating).to_d / 200) + 20 * (1 - (choreo_rating + dance_figure_rating + team_presentation_rating).to_d / 300)) - punishment, 0].max
  end

  def final!
    update_attributes final: true
  end

  def final?
    final
  end
  
  private

  def add_history_entry
    dance_rating_history_entries.create female_base_rating: female_base_rating,
                                        female_turn_rating: female_turn_rating,
                                        male_base_rating: male_base_rating,
                                        male_turn_rating: male_turn_rating,
                                        choreo_rating: choreo_rating,
                                        dance_figure_rating: dance_figure_rating,
                                        team_presentation_rating: team_presentation_rating,
                                        mistakes: mistakes,
                                        reopened: reopened,
                                        final: final
  end

  def team_belongs_to_dance_round
    errors.add :dance_team unless dance_round.dance_teams.include?(dance_team)
  end
  
  def discussable_attributes
    %i(female_base_rating female_turn_rating male_base_rating male_turn_rating choreo_rating dance_figure_rating team_presentation_rating)
  end
end
