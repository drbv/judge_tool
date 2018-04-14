class RoundType < ActiveRecord::Base
  has_many :rounds

  def is_final_round
     name.include?("Endrunde")
  end

  def with_short_rating?
    !name.include?("Endrunde")
  end

end
