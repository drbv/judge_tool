class DanceRating < ActiveRecord::Base
  before_save :calc_result
  include ReopenedAttributes
  belongs_to :dance_team
  belongs_to :dance_round
  belongs_to :user
  has_many :dance_rating_history_entries

  validates_presence_of :dance_team, :dance_round, :user
  validates_presence_of :female_base_rating, :female_turn_rating, :male_base_rating, :male_turn_rating, :choreo_rating, :dance_figure_rating, :team_presentation_rating, unless: -> { user.has_role?(:observer, dance_round.round) }
  validates_format_of :mistakes, with: /\A(?:(?:T2|T10|T20|S2|S10|S20|U2|U10|U20|V5|A20)(?:,(T2|T10|T20|S2|S10|S20|U2|U10|U20|V5|A20))*)?\Z/
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
    result
  end

  def final!
    update_attributes final: true
  end

  def final?
    final
  end

  def female_max
    dance_class_sepcific_max_value
  end

  def male_max
    dance_class_sepcific_max_value
  end

  def dance_max
    dance_class_sepcific_max_value * 2
  end

  def female
    dance_class_sepcific_max_value * (1 - (female_base_rating + female_turn_rating).to_d / 200)
  end

  def male
    dance_class_sepcific_max_value * (1 - (male_base_rating + male_turn_rating).to_d / 200)
  end

  def dance
    dance_class_sepcific_max_value * 2 * (1 - (choreo_rating * 0.3 + dance_figure_rating * 0.3 + team_presentation_rating * 0.4).to_d / 100)
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
    (1 - male_turn_rating.to_d/100) * 10
  end

  def male_base_rating_points
    (1 - male_base_rating.to_d/100) * 10
  end

  def female_turn_rating_points
    (1 - female_turn_rating.to_d/100) * 10
  end

  def female_base_rating_points
    (1 - female_base_rating.to_d/100) * 10
  end

  def choreo_rating_points
    (1 - choreo_rating.to_d/100 ) * 10
  end

  def dance_figure_rating_points
    (1 - dance_figure_rating.to_d/100) * 10
  end

  def team_presentation_rating_points
    (1 - team_presentation_rating.to_d/100) * 10
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

  def dance_class_sepcific_max_value
    case self.dance_round.round.dance_class.name
      when "RR_A"
        if round_type.include?('End_r') || round_type.include?('KO_r') || round_type.include?('Stich_r_1pl')
          8.75
        else
          12.5
        end
      when "RR_B"
        if round_type.include?('End_r') || round_type.include?('KO_r') || round_type.include?('Stich_r_1pl')
          8.75
        else
          12.5
        end
      when "RR_C"
        12
      when "RR_J"
        9
      else
        9
    end
  end

  def attributes_group(attribute)
    attributes_groups.keys.select {|key| attributes_groups[key].include? attribute.to_sym }.first
  end

  def calc_result
    @punishment = nil
    self.result = [(female + male + dance - punishment), 0].max
  end

end
