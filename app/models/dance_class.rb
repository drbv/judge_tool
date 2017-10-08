class DanceClass < ActiveRecord::Base
  has_many :dance_teams
  has_many :rounds

  def is_formation?
    name.include?("Formation")
  end

  def is_boogie?
    name.include?("BW") || name.include?("Boogie") || name.include?("Woogie")
  end

end
