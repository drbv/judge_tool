class DanceRound < ActiveRecord::Base
  belongs_to :round
  has_and_belongs_to_many :dance_teams
  has_many :acrobatics
  has_many :dance_ratings

  def evaluate
    # compute rating from ratings
  end
end
