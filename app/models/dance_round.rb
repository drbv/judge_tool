class DanceRound < ActiveRecord::Base
  belongs_to :round
  has_and_belongs_to_many :dance_teams
  has_many :acrobatics
  has_many :acrobatic_ratings, through: :acrobatics
  has_many :dance_ratings

  def self.active
    find_by(started: true, finished: false)
  end

  def active?
    started && !finished
  end

  def start!
    update_attributes started: true, started_at: Time.now
  end

  def judges
    round.judges
  end

end
