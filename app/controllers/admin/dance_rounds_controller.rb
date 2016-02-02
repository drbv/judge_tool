class Admin::DanceRoundsController < ApplicationController

  def show
    @dance_team = DanceTeam.find params[:dance_team_id]
    @dance_round = DanceRound.find params[:id]
    authorize @dance_round, :admin_show?
    @round = @dance_round.round
    @dance_round_rating = DanceRoundRating.find_or_create(@dance_round, @dance_team, current_user)
  end

end
