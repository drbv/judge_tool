class Round < ActiveRecord::Base
  belongs_to :round_type
  belongs_to :dance_class
end
