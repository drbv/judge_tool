class AcrobaticRating < ActiveRecord::Base
  include ReopenedAttributes
  before_save :calc_result
  belongs_to :acrobatic
  belongs_to :dance_team
  has_one :dance_round, through: :acrobatic

  belongs_to :user
  has_many :acrobatic_rating_history_entries

  validates_presence_of :dance_team, :acrobatic, :user, :rating
  validates_format_of :mistakes, with: /\A((S2|S10|S20|U2|U10|U20|V5|P0)(,(S2|S10|S20|U2|U10|U20|V5|P0))*)?\Z/
  validates_uniqueness_of :acrobatic_id, scope: %i[user_id dance_team_id]
  validate :team_belongs_to_dance_round
  after_save :add_history_entry

  def full_mistakes
    mistakes.blank? ? '-' : mistakes
  end

  def punishment
    @punishment ||= mistakes.split(',').map {|malus| malus[1..-1].to_i}.sum
  end

  def points
    result
  end

  def points_without_punishment
    if full_mistakes.include?('P0')
      # P0 = showed wrong acrobatic
      0
    else
      acrobatic.acrobatic_type.max_points * (1 - rating.to_d / 100)
    end
  end

  def danced?
    danced
  end

  def diff_to_big?
    !observer_rating? && (acrobatic.ratings_average - rating).abs >= 20
  end

  def observer_rating?
    user.has_role?(:observer, acrobatic.dance_round.round)
  end

  private

  def add_history_entry
    acrobatic_rating_history_entries.create rating: rating, mistakes: mistakes, danced: danced, reopened: reopened
  end

  def team_belongs_to_dance_round
    errors.add :dance_team unless acrobatic.dance_round.dance_teams.include?(dance_team)
  end

  def discussable_attributes
    %i[rating]
  end

  def calc_result
    @punishment = nil
    if full_mistakes.include?('P0')
      self.result = 0
    else
      self.result = acrobatic.acrobatic_type.max_points * (1 - rating.to_d / 100)
    end
  end

end