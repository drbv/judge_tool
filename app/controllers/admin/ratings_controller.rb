class Admin::RatingsController < ApplicationController

  def update
    @dance_round_rating = DanceRoundRating.find(params[:id])
    authorize @dance_round_rating
    if @dance_round_rating.update_attributes(dance_round_rating_params)
      flash[:success] = 'Abzüge gespeichert'
    else
      flash[:danger] = 'Konnte nicht gespeichert werden'
    end
    redirect_to admin_show_dance_team_dance_round_path(@dance_round_rating.dance_round_id, @dance_round_rating.dance_team_id)
  end

  private

  def dance_round_rating_params
    params.require(:dance_round_rating).permit(:mistakes)
  end
end
