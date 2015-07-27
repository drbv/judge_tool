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
    mistakes.blank? ? '-' : mistakes
  end

  def punishment
    @punishment ||= mistakes.split(',').map { |malus| malus[1..-1].to_i }.sum
  end

  def points
    @points ||= [(female + male + dance - punishment), 0].max
  end

  def final!
    update_attributes final: true
  end

  def final?
    final
  end

  def female_max
    10
  end

  def male_max
    10
  end

  def dance_max
    20
  end

  def female
    10 * (1 - (female_base_rating + female_turn_rating).to_d / 200)
  end

  def male
    10 * (1 - (male_base_rating + male_turn_rating).to_d / 200)
  end

  def dance
    20 * (1 - (choreo_rating * 0.3 + dance_figure_rating * 0.3 + team_presentation_rating * 0.4).to_d / 100)
  end

  def diff_to_big?(attr)
    !observer_rating? && (dance_round.dance_ratings_average(attr, dance_team) - send(attr)).abs >= send("#{attr}_max") * 0.2
  end

  def diff(attr)
    dance_round.dance_ratings_average(attr, dance_team) - send(attr)
  end

  def observer_rating?
    user.has_role?(:observer, dance_round.round)
  end
  def discussable_attributes
    %i(female male dance)
  end

  def male_turn_rating_points
    (1 - 1 * male_turn_rating.to_d/100) * 5
  end

  def male_base_rating_points
    (1 - 1 * male_base_rating.to_d/100) *5
  end

  def female_turn_rating_points
    (1 - 1 * female_turn_rating.to_d/100) * 5
  end

  def female_base_rating_points
    (1 - 1 * female_base_rating.to_d/100) * 5
  end

  def choreo_rating_points
    (1 - 1 * choreo_rating.to_d/100 ) * 20/3
  end

  def dance_figure_rating_points
    (1 - 1 * dance_figure_rating.to_d/100) * 20/3
  end

  def team_presentation_rating_points
    (1 - 1 * team_presentation_rating.to_d/100) * 20/3
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
    %i(female male dance)
  end

  def attributes_groups
    {
      female: %i[female_base_rating female_turn_rating],
      male: %i[male_base_rating male_turn_rating],
      dance: %i[choreo_rating dance_figure_rating team_presentation_rating]
    }
  end

  def attributes_group(attribute)
    attributes_groups.keys.select {|key| attributes_groups[key].include? attribute.to_sym }.first
  end

end
