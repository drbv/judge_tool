class DanceTeamsController < ApplicationController
  def show
    @dance_team = DanceTeam.find(params[:id])
  end
end
