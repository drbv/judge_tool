class Admin::DanceRoundsController < ApplicationController

  def show_dance_team
    @dance_team = DanceTeam.find params[:dance_team_id]
    @dance_round = DanceRound.find params[:dance_round_id]
    authorize DanceRound, :is_admin?
    #authorize Round, :admin_index?
    @round = @dance_round.round
    @dance_round_rating = DanceRoundRating.get_dance_round_rating(@dance_round,@dance_team,current_user) || DanceRoundRating.create(mistakes: '', dance_team_id: @dance_team.id, dance_round_id: @dance_round.id, user_id: current_user.id)

  end

  def update_dance_round_rating
  authorize DanceRound, :is_admin?
  @dance_round_rating = DanceRoundRating.find(params[:id])
  @dance_round_rating.update_attributes(dance_round_rating_params)
  flash[:success]="Abzüge gespeichert"
  redirect_to admin_show_dance_team_dance_round_path(@dance_round_rating.dance_round_id, @dance_round_rating.dance_team_id)
  end

  private

   def dance_round_rating_params
     params.require(:dance_round_rating).permit(:mistakes)
   end
end