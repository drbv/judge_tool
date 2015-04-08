class AcrobaticRating < ActiveRecord::Base
  belongs_to :acrobatic
  belongs_to :dance_team
  belongs_to :user
end
