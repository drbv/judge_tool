class AcrobaticRating < ActiveRecord::Base
  belongs_to :acrobatic
  belongs_to :dance_team
  belongs_to :user

  validates_presence_of :dance_team, :acrobatic, :user, :rating
  validates_format_of :mistakes, with: /\A((S2|S10|S20|U2|U10|U20)(,(S2|S10|S20|U2|U10|U20))*)?\Z/
end
