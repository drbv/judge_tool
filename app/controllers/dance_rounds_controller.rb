class DanceRoundsController < ApplicationController
  def show
    if current_round
      if current_round.round_type.no_dance? || current_round.judges.empty?
        render :round_name, layout: "beamer"
      else
        if current_dance_round
          render :current_dance_round, layout: "beamer"
        else
          @dance_round = DanceRound.where(round_id: current_round.id, started: true, finished: true).order(:position).last
          if @dance_round
            @round = @dance_round.round
            if @round.round_type.name.include? 'KO'
              render :dance_round_KO, layout: "beamer"
            else
              @dance_team_result_list = @round.dance_teams.uniq.select{|dance_team| dance_team.has_danced?(@round)}.sort_by {|dance_team| dance_team.get_final_result(@round)}.reverse
              render :round_results, layout: "beamer"
            end

          else
            render :round_name, layout: "beamer"
          end
        end
      end
    else
      if Round.where(closed: true).count > 0
        render :end_of_tournament, layout: "beamer"
      else
        render :starting_tournament_soon, layout: "beamer"
      end
    end
  end
end
