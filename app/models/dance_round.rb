class DanceRound < ActiveRecord::Base
  belongs_to :round
  belongs_to :dance_team

  def evaluate
    # compute rating from ratings
  end
end
