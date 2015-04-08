class DanceClass < ActiveRecord::Base
  has_many :dance_teams
  has_many :rounds

end
