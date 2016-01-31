class Admin::DanceRoundsController < ApplicationController

  def show_dance_team
    @dance_team = DanceTeam.find params[:dance_team_id]
    @dance_round = DanceRound.find params[:dance_round_id]
    @round = @dance_round.round
    #TODO:
    # Wie setzt ich das um ?
    # authorize @round
  end
end
