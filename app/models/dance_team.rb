class DanceTeam < ActiveRecord::Base
  belongs_to :club
  has_and_belongs_to_many :dancers
end
