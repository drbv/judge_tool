class Acrobatic < ActiveRecord::Base
  belongs_to :dance_team
  belongs_to :dance_round
  belongs_to :acrobatic_type
  has_many :acrobatic_ratings
end
