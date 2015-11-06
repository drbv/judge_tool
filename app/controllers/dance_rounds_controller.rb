class DanceRoundsController < ApplicationController
  def show
    if current_round
      if current_round.round_type.no_dance? || current_round.judges.empty?
        render_xhr :round_name
      else
        if current_dance_round
          render_xhr :current_dance_round
        else
          @dance_round = DanceRound.where(round_id: current_round.id, started: true, finished: true).order(:position).last
          if @dance_round
            render_xhr :dance_round_result
          else
            render_xhr :round_name
          end
        end
      end
    else
      if Round.where(closed: true).count > 0
        render_xhr :end_of_tournament
      else
        render_xhr :starting_tournament_soon
      end
    end
  end
end
