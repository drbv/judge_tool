class Round < ActiveRecord::Base
  belongs_to :round_type
  belongs_to :dance_class
  has_many :dance_rounds
end
