class AcrobaticType < ActiveRecord::Base
  has_many :acrobatics
  validates :max_points, presence: true
end
