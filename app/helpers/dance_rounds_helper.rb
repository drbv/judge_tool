module DanceRoundsHelper

  def dance_round_header
    "#{@dance_round.round.round_type.name} #{@dance_round.round.dance_class.name} " +
        "#{@dance_round.position} / #{@dance_round.round.dance_rounds.count}"
  end
end
