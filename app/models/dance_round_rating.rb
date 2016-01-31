class DanceRoundRating < ActiveRecord::Base
  belongs_to :dance_team
  belongs_to :dance_round
  belongs_to :user
end
