class DanceClass < ActiveRecord::Base
  has_many :dance_teams
  has_many :rounds

  def is_formation?
    name.include?("Formation")
  end

end
