class RoundType < ActiveRecord::Base
  has_many :rounds

  def is_final_round
    if name == "Endrunde"
      true
    else
      false
    end
  end
end
