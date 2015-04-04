class DanceTeam < ActiveRecord::Base
  belongs_to :club
  belongs_to :dance_class
  has_and_belongs_to_many :dancers
  has_many :dance_ratings
  has_many :acrobatic_ratings
end
