class Club < ActiveRecord::Base
  has_many :dance_teams
  has_many :users
end
