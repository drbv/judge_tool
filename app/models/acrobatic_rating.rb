class AcrobaticRating < ActiveRecord::Base
  include ReopenedAttributes
  belongs_to :acrobatic
  belongs_to :dance_team
  belongs_to :user

  validates_presence_of :dance_team, :acrobatic, :user, :rating
  validates_format_of :mistakes, with: /\A((S2|S10|S20|U2|U10|U20|V5)(,(S2|S10|S20|U2|U10|U20|V5))*)?\Z/
  validates_uniqueness_of :acrobatic_id, scope: %i[user_id dance_team_id]
  validate :team_belongs_to_dance_round

  def full_mistakes
    mistakes.blank? ? 'Keine Fehler' : mistakes
  end

  def punishment
    @punishment ||= mistakes.split(',').map {|malus| malus[1..-1].to_i}.sum
  end

  def points
    @points ||= [acrobatic.acrobatic_type.max_points * (1 - rating.to_d / 100) - punishment, 0].max
  end

  def danced?
    danced
  end

  private

  def team_belongs_to_dance_round
    errors.add :dance_team unless acrobatic.dance_round.dance_teams.include?(dance_team)
  end

  def discussable_attributes
    %i[rating]
  end

end