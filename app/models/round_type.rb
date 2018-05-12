class RoundType < ActiveRecord::Base
  has_many :rounds

  def is_final_round
     name.include?("Endrunde")
  end

  def is_semi_final_round?
    name.include?("Semifinale")
  end

  def with_short_rating?
    !name.include?("Endrunde")
  end

end
